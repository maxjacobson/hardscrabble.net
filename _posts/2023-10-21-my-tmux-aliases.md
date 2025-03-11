---
title: My tmux aliases (2023 edition)
date: 2023-10-21 15:56
category: personal computing
---

![My tmux setup, with some panes showing a vim editor process, server logs, and test output](/img/2023-10-21-tmux-example.png)

In 2015, I wrote a blog post called [some helpful tmux aliases](/2015/some-helpful-tmux-aliases) explaining a bit about how I use tmux in my development workflow. I'll confess it's not my most coherent blog post I've written, and I've iterated a bit since then, so I thought I'd take another run at it.

## Wait what is tmux even all about?

When I'm working on a project, I usually need a bunch of separate shells.
Right now, as I work on this blog post, I'm using three:
1. One to run my text editor, vim, where I'm writing these words
1. Another to run my `exe/serve` helper script which runs the jekyll server, so I can preview the blog post in a browser and make sure it looks right
1. Another for miscellaneous use, like running git operations to commit the changes or using ripgrep to search the project for references to things I've blogged about already

It would be fine and reasonable to just open three separate windows or tabs in my terminal emulator to run those various things, but instead I use [tmux](https://github.com/tmux/tmux). I basically never have more than one actual tab or window, even when I'm bouncing between multiple projects, because my tmux workflow makes that unnecessary.

tmux is a "multiplexer", which is to say that it lets you run multiple shells in one shell.

It can split your screen vertically and horizontally to run as many shells as you want. In the screenshot at the top of this post, there are three shells[^1]. In tmux's jargon, those are called "panes", like how a window may be made up of multiple panes of glass, this window is made up of multiple shells.

[^1]: It sort of looks like four, but it's really three. The one in the top left is running vim, which has its own splitting mechanism, and is showing two different files.

    It can get a bit fractal when you have vim inside tmux, but you get used to it.

When I open too many panes, it can start to feel a little cramped. I often resize them by dragging the little border line[^2]. I also will often maximize the current pane, hiding the others, if I just need to focus on one task for a bit:

![Resizing tmux panes and zooming into one](/img/2023-10-21-resizing-tmux-panes.gif)

[^2]: This requires you to enable mouse support in your tmux configuration, which I heartily recommend.

    ```
    set-option -g mouse on
    ```

You can also run multiple windows, and switch between those. This is nice because sometimes you want something running in the background and you don't really want to look at it all the time. These are called "windows" but I tend to think of them as "tabs", because they function sort of like tabs in a GUI app. You can even rename windows to help you remember what that window's purpose is:

![Switching between windows and renaming them](/img/2023-10-21-renaming-tmux-windows.gif)

The last major bit of tmux terminology, after "pane" and "window", is "session". A session is a group of windows. You can have many sessions running at once, and switch between them. I have one session per project that I'm working on. If I initiate a session in the directory for my project [seasoning](https://github.com/maxjacobson/seasoning/), then every new pane and window will start a new shell in that directory, which is really convenient.

So that's the overview.

## Aliases

### Creating a new session

You can start a new session by simply running `tmux`. If you do that, your session will automatically be given a name of `0`. Your next session will be called `1`, and so on. Because I run one session per project, and sometimes work on multiple projects at the same time, I like to name my sessions after the project. That's easy enough to do. Instead of running simply `tmux` to start a session, I can run, for example:
```shell
tmux new-session -s seasoning
```

That will start a new session called `seasoning` in the current directory.

Back in 2015, I came up with a clever alias that would automatically infer the session name from the name of the current directory. It looked like this:

```shell
alias 't'='tmux new-session -A -s $(basename $PWD | tr -d .)'
```

Running `basename $PWD | tr -d .` when you're in a directory like `/Users/max/src/gh/maxjacobson/seasoning` prints the text `seasoning`, which seems like a perfect session name for when I'm working on that project.

The `-A` bit will attach to an existing session with that name, if one exists, and otherwise create it.

With this alias, I can happily run simply `t` in any directory and feel confident that I'll be in a nicely-named session.

This held up pretty well over the years, but it has one flaw: every now and then (and this is pretty rare) I'll have more than one "project" with the same name. For example, I'll often clone other people's dotfiles repos and rummage around for inspiration. They're almost always called `dotfiles`. If I clone [wfleming/dotfiles](https://github.com/wfleming/dotfiles/) and start a new session by running `t`, I'll get a new session called `dotfiles` in Will's dotfiles. If I then clone [pbrisbin/dotfiles](https://github.com/pbrisbin/dotfiles/) and run `t`, tmux will see that there is already a running session called `dotfiles` and attach to that instead of creating a new one.

This has only come up a very small handful of times but every time is a little papercut that has bugged me. So, recently, I revised my `t` alias for the first time in ages. It now looks like this:

```shell
alias 't'='tmux new-session -A -s "$(basename $PWD) $(echo $PWD | shasum -a 256 | cut -c1-4)"'
```

With this new version, the derived session name when I'm in `/Users/max/src/gh/maxjacobson/seasoning` is `seasoning 3f2c`. That bit at the end generates a unique[^3] four character hash based on the absolute path to the project. It will always come up with the same hash, so it will be possible to run `t` in as many dotfiles repos as I want and start up independent sessions.

[^3]: I guess it's possible to have a hash conflict, and that's much more likely because I'm truncating the hash to just four characters, but uh, fingers crossed.

### Listing sessions

You can run `tmux list-sessions` to print out a list of the running sessions, plus some interesting metadata about them:

```
$ tmux list-sessions
hardscrabble_net afd6: 4 windows (created Sat Oct 21 15:06:31 2023) (attached)
seasoning 3f2c: 1 windows (created Sat Oct 21 15:06:24 2023)
```

I've had that aliased to `tl` for years. Today I learned you can format the output to include whatever information you want, and spent several minutes exploring various ideas.

Some ideas...


If I want to correct the pluralization error of "1 windows"[^4]:

```
$ tmux list-sessions -F '#{session_name} (#{session_windows} #{?#{==:#{session_windows},1},window,windows})'
hardscrabble_net afd6 (4 windows)
seasoning 3f2c (1 window)
```

That one is uh, pretty gnarly. In English, it's saying "If the `session_windows` variable is equal to 1, say 'window' otherwise say 'windows'".

[^4]: This is something that has apparently bothered me for a long time. I [added](https://github.com/rubocop/rubocop/pull/2316) the [Rails/PluralizationGrammar](https://docs.rubocop.org/rubocop-rails/cops_rails.html#railspluralizationgrammar) rule to rubocop many years ago, and now it's [referenced in thousands of repos](https://github.com/search?q=Rails%2FPluralizationGrammar&type=code), something that genuinely delights me.

If I want to include the session's directory:

```
$ tmux list-sessions -F '#{session_name} (#{session_path})'
hardscrabble_net afd6 (/Users/max/src/gh/maxjacobson/hardscrabble.net)
seasoning 3f2c (/Users/max/src/gh/maxjacobson/seasoning)

$ tmux list-sessions -F '#{session_name} (#{d:session_path})'
hardscrabble_net afd6 (/Users/max/src/gh/hardscrabble)
seasoning 3f2c (/Users/max/src/gh/maxjacobson)

$ tmux list-sessions -F '#{session_name} (#{b:session_path})'
hardscrabble_net afd6 (hardscrabble.net)
seasoning 3f2c (seasoning)
```

As you can see, there are modifiers to just say the parent directory, or just say the basename of the directory.


If I want to scrub out the unsightly trailing hash from the session name:

```
$ tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}'
hardscrabble_net
seasoning
```

I feel like I should be able to simplify that regular expression to something like `/ [a-f0-9]{4}$/` but I can't quite figure out how to escape it. So it goes.

I think I'm going to keep it minimalist and use this last one when I run `tl`. That means my next recommended alias looks like this:

```
alias 'tl'="tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}' 2>/dev/null || echo 'no sessions'"
```

You'll notice that there's a little bit of error handling in there. That's because, by default, `tmux list-sessions` throws a kind of unsightly error when there are no sessions to list. We can make that a little nicer.

### Attaching to an existing session

One of the benefits of tmux is that if you accidentally close your terminal emulator app (e.g. Terminal or iTerm 2 or Alacritty or whatever), your session is still running in the background, and you can reattach to it. It'll keep running until all of the shells within the session exit. I normally press <kbd>Ctrl</kbd> + <kbd>d</kbd> to exit shells, but you can also type `exit` and hit enter.

You can attach to a session by running `tmux attach-session`, which will attach to the most recently used session. I have this aliased to `ta` like so:

```
alias 'ta'='tmux attach-session'
```

This is usually what I want. From there, if I happen to have multiple sessions going, I might switch to another session like so:

![switching between tmux sessions](/img/2023-10-21-switching-tmux-sessions.gif)

(Eagle-eyed readers might notice that the hash has disappeared from the status bar in the lower right in that gif, because I realized I can use the same format string trick to scrub it from there too. And now you know that I am a bit too lazy to redo the earlier gifs for consistency's sake.)

It's also possible to attach to a specific session, rather than the most recently used one. You can do that by running a command like this:

```
$ tmux attach-session -t seas
```

Thankfully you don't need to specify the full name. tmux can figure out that when I specify `seas` I mean `seasoning 3f2c`.

I have that aliased as `to`, so I can simply run:

```
$ to seas
```

That alias looks like this:

```shell
alias 'to'='tmux attach-session -t'
```

### Wrapping it all up

Alright, thanks for coming on this journey. Here's the aliases all together:

```shell
alias 't'='tmux new-session -A -s "$(basename $PWD) $(echo $PWD | shasum -a 256 | cut -c1-4)"'
alias 'tl'="tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}' 2>/dev/null || echo 'no sessions'"
alias 'ta'='tmux attach-session'
alias 'to'='tmux attach-session -t'
```

And here's the relevant bits of config in my `~/.tmux.conf`

```
set -g status-interval 1
set -g status-left ""
set -g status-right "%b %d %H:%M:%S #{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}"
```

Happy tmuxing. See you in another eight years.
