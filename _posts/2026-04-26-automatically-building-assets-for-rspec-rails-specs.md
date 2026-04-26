---
title: Automatically building assets when using the RSpec CLI
date: 2026-04-26 15:13
category: programming
---

Let's say your Rails app is using [propshaft][], [jsbundling-rails][], and [cssbundling-rails][] to build assets.

[propshaft]: https://github.com/rails/propshaft
[jsbundling-rails]: https://github.com/rails/jsbundling-rails
[cssbundling-rails]: https://github.com/rails/cssbundling-rails

And let's say you're using [rspec-rails][] as your testing library.

[rspec-rails]: https://github.com/rspec/rspec-rails

And let's say you're writing [system specs][] (RSpec's wrapper around [Rails system tests][]) to test how your Rails app works when you visit it in a browser and click around.

[system specs]: https://rspec.info/features/8-0/rspec-rails/system-specs/system-specs/
[Rails system tests]: https://guides.rubyonrails.org/testing.html#system-testing


It's important that, when those system specs run, your front-end assets have already been built, or the test will fail hard, with errors indicating that the assets are unavailable.

It's also important that, when those system specs run, those front-end assets are _up-to-date_. propshaft will be looking for assets in `app/assets/builds`. If you haven't built your front-end assets in a few days, maybe some of your source code has changed, and those built assets don't include the latest changes. In this case, your tests may fail in confusing ways. propshaft is able to find and serve `app/assets/builds/application.js` but your test fails because the script is missing some critical new feature that was added this morning.

So how to avoid these annoying and confusing situations?

One option is to consider _how_ you're running RSpec. Let's think about the difference between these different ways to run an RSpec test suite:

```
$ bin/rspec
$ bin/rails spec
```

In the former, you're using the [RSpec CLI][] directly[^1] and in the latter you're using a [rake task defined by the rspec-rails gem][rails-rspec-task][^2].

[RSpec CLI]: https://rspec.info/features/3-13/rspec-core/command-line/
[rails-rspec-task]: https://github.com/rspec/rspec-rails/blob/v8.0.4/lib/rspec/rails/tasks/rspec.rake#L12-L13

[^1]: I'm presuming that you've run `bundle binstubs rspec-core` to generate the `bin/rspec` file; you could also invoke it with `bundle exec rspec`
[^2]: You could just as well run `bin/rake spec` -- same diff.

When you use the rake task (`bin/rails spec`), everything Just Works. You'll notice that assets build automatically every single time you run it, so they're always present and they're always up-to-date. Here's what's happening:

1. The task is [defined](https://github.com/rspec/rspec-rails/blob/v8.0.4/lib/rspec/rails/tasks/rspec.rake#L12-L13) like this:
    ```ruby
    RSpec::Core::RakeTask.new(spec: "spec:prepare")
    ```

    That is, the `spec` task (which is defined in rspec-core and which runs all the specs) depends on the `spec:prepare` task, which is defined just below.
2. The `spec:prepare` task [invokes](https://github.com/rspec/rspec-rails/blob/v8.0.4/lib/rspec/rails/tasks/rspec.rake#L24-L31) the `test:prepare` task，which is defined all the way back in Rails
3. The `test:prepare` task does... [nothing at all](https://github.com/rails/rails/blob/v8.1.3/railties/lib/rails/test_unit/testing.rake#L13-L17)! Per the source code, it is a "Placeholder task for other Railtie and plugins to enhance."
4. [jsbundling-rails](https://github.com/rails/jsbundling-rails/blob/v1.3.1/lib/tasks/jsbundling/build.rake#L69-L75) and [cssbundling-rails](https://github.com/rails/cssbundling-rails/blob/main/lib/tasks/cssbundling/build.rake#L68-L74) do exactly that. They enhance the `test:prepare` task so that whenever `test:prepare` runs, rake will also run the `javascript:build` and `css:build` tasks.

So that's nice: everything is automatic and works as long as you run your RSpec test suite using the `bin/rails spec` task.

It kind of sucks that you need to rebuild _all_ of your assets every time you run _any_ test, but it works.

Now, what if you want to use the `bin/rspec` CLI to run your tests? There are a lot of reasons that you might want to do that:

1. It has a lot of useful flags for customizing its behavior and its output
2. You can run specific spec files by passing them as arguments

One option you have is to just remember to run `bin/rails spec:prepare` or `bin/rails test:prepare` before you run your tests, which will take care of it. Try very hard not to forget, or you may end up with confusing failures. Make sure to document this well for everyone else who works on this project to make sure other people know to do this too.

Another option is to make some kind of wrapper script. We can imagine something like a `bin/prepare-and-rspec` which looks like

```shell
#!/bin/sh

set -e

bin/rails test:prepare
bin/rspec "$@"
```

That way you can just run `bin/prepare-and-rspec --format documentation spec/models/user_spec.rb` and everything should Just Work. Of course, it still kind of sucks that you have to rebuild your assets every time you run a spec, even if nothing changed. And it's still possible that teammates might not discover this script, and they'll just keep using `bin/rspec` and hitting mysterious failures here and there.

Another option is to add some kind of an [RSpec hook](https://rspec.info/features/3-13/rspec-core/hooks/before-and-after-hooks/) which takes care of building assets before the test suite:


```ruby
RSpec.configure do |config|
  config.before(:suite) do
    system("bin/rails javascript:build", exception: true)
    system("bin/rails css:build", exception: true)
  end
end
```

This is a pretty good option! Now you can just use `bin/rspec` and trust that it will automatically build assets whenever you run specs.

Of course, it still sucks that you need to rebuild _all_ of your assets every time you run _any_ test.

And even worse: if you do happen to run `bin/rails spec`, now you're rebuiling _all_ of your assets _twice_, once from your custom hook and once from the `test:prepare` enhancements.

This is actually pretty close to where I've landed in my project. I've zhuzhed it up a little by adding some logic which tries to determine whether re-running is actually necessary:

```ruby
class AutoCompileInTests
  def initialize(command:, inputs:, name:)
    @command = command
    @inputs = inputs
    @name = name
  end

  def run
    return if ENV["CI"]
    return if already_compiled?

    system(@command, exception: true)

    marker_file.write(cache_key)
  end

  def wait
    return if ENV["CI"]

    loop do
      return if already_compiled?

      sleep 1
    end
  end

  private

  def already_compiled?
    marker_file.exist? ? marker_file.read == cache_key : false
  end

  def marker_file
    Rails.root.join("tmp/cache/auto-compile-#{@name}")
  end

  def cache_key
    md5 = Digest::MD5.new
    @inputs
      .map { |input| Dir.glob(input) }
      .flatten
      .uniq
      .each do |path|
        pathname = Pathname.new(path)
        next if pathname.directory?

        md5.update pathname.read
      end

    md5.hexdigest
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    tasks = [
      AutoCompileInTests.new(
        command: "bin/rails css:build",
        inputs: [
          ".node-version",
          "Gemfile.lock",
          "package-lock.json",
          "app/assets/stylesheets/**/*",
        ],
        name: "css"
      ),
      AutoCompileInTests.new(
        command: "bin/rails javascript:build",
        inputs: [
          ".node-version",
          "Gemfile.lock",
          "package-lock.json",
          "app/javascript/**/*"
        ],
        name: "javascript"
      )
    ]

    # if you aren't using parallel_tests, this can simply be
    # tasks.each(&:run)
    ParallelTests.first_process? ? tasks.each(&:run) : tasks.each(&:wait)
  end
end
```

The goal with this code is to list out the tasks that need to run at the top of the test suite. For each task, we give it a name, a command, and inputs. The inputs are all of the files that, if any of them change, we should rerun the task just to be safe. Then, we'll make a hash of all of those inputs and write it to a temp file (`./tmp/cache/auto-compile-css` or `./tmp/cache/auto-compile-js`) and we'll run the command. The next time, we'll recompute the hash and compare it to the tempfile; if it matches, no need to rebuild the assets. If you ever want to force the assets to rebuild, you can just remove those tempfiles by running `rm tmp/cache/auto-compile-*`.

This is a bit of extra complexity, but I think it's worth it if your assets are a bit slow to build.

Of course, it would be nice if all of this Just Worked out of the box, but I'm not sure exactly what that would look like.

Feel free to get in touch if you have ideas to improve this setup.
