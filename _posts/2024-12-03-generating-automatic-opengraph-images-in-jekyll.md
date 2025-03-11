---
title: generating opengraph social preview images for blog posts automatically in jekyll
date: 2024-12-03 21:13
category: blogging
---

Some time last year I thought it might be nice to have [opengraph](https://ogp.me) preview images on my blog posts, so if I posted them to Mastodon they'd show a cool little preview image and more people would click on them.

It's easy enough, you just need something like this in the `<head>`:

```html
<meta property="og:image" content="https://www.hardscrabble.net/img/preview/2024-10-03-colors.png">
```

Because I use [Jekyll](https://jekyllrb.com) to generate my blog, it wasn't too hard to add [a little conditional logic](https://github.com/maxjacobson/hardscrabble.net/blob/10561fb935b1a98c96d8abb85a165079fe3c0b5e/_layouts/default.html#L19-L20) that includes that meta element if a post specifies a preview image filename in its [front matter](https://jekyllrb.com/docs/front-matter/).

But it's sort of annoying to have to prepare an image whenever you want to blog something. I don't necessarily have time for all that.

Then, yesterday, I was poking around on Bluesky and saw this post:

<blockquote class="bluesky-embed" data-bluesky-uri="at://did:plc:bhdap3w2bseikypfnjmaskzf/app.bsky.feed.post/3lcbjdiahas2l" data-bluesky-cid="bafyreiauldlnvw5i7inskcwxnaw2h3yjaesxdhbzstzvtkzwv6gxpnygji"><p lang="en">I&#x27;m starting my 2024 #blogvent series where I post a blog a day in December!

Blogvent day 1 is about fighting spam in your open source repos:
cassidoo.co/post/oss-int...<br><br><a href="https://bsky.app/profile/did:plc:bhdap3w2bseikypfnjmaskzf/post/3lcbjdiahas2l?ref_src=embed">[image or embed]</a></p>&mdash; Cassidy (<a href="https://bsky.app/profile/did:plc:bhdap3w2bseikypfnjmaskzf?ref_src=embed">@cassidoo.co</a>) <a href="https://bsky.app/profile/did:plc:bhdap3w2bseikypfnjmaskzf/post/3lcbjdiahas2l?ref_src=embed">December 1, 2024 at 4:07 PM</a></blockquote><script async src="https://embed.bsky.app/static/embed.js" charset="utf-8"></script>

And I got so jealous of how nice and clean that preview image is, and I had a few thoughts:

- Sigh I should blog more
- Dang can you imagine blogging that much?
- No, I mean, it would be so annoying to generate all those preview images
- Wait, how did she manage to auto-generate the preview images with text for each blog post??? That's so cool!!!

I saw that her blog post is open source and I tracked down [the lines of code](https://github.com/cassidoo/blahg/blob/c7ca18f2ee53cdb781b25b39105a9aec30ea0bcd/src/components/BaseHead.astro#L7-L27), which look sort of like this:

```
---
const { title, description, image = "/home-blog-card.png" } = Astro.props;
---

<head>
  <meta property="og:image" content={new URL(image, Astro.url)} />
</head>
```

I sat and stared at that for several minutes, trying to puzzle out how it works. I've never used Astro, but it seems very powerful. I look at the docs.

Eventually I realized that actually it's just a static image, and it isn't dynamically changing the text for each blog post. I went back to her page and scrolled down past several links, and I saw that they all have the same text.

Lol.

But hey, I thought, maybe it is possible to generate custom images with text in them? And if it is, maybe it is possible to hook that into the jekyll build process?

And indeed it is. And I've done a somewhat basic version of that. And here's how you can do that too.

First, create a plugin by creating a file called `_plugins/opengraph.rb`. Ruby files in the `_plugins` folder are loaded during the build process.

Within that plugin, register some jekyll [hooks](https://jekyllrb.com/docs/plugins/hooks/):

```ruby
Jekyll::Hooks.register :posts, :pre_render do |post|
  unless post.data["preview_image"]
    preview = GeneratePreview.new(post)
    preview.write
    post.merge_data!({"preview_image" => preview.path }, source: "opengraph plugin")
  end
end

Jekyll::Hooks.register :site, :after_init do
  FileUtils.mkdir_p "tmp/img/preview"
end

Jekyll::Hooks.register :site, :post_write do
  Dir.glob("tmp/img/preview/*").each do |path|
    FileUtils.cp path, "_site/img/preview"
  end
end
```

The idea here is that for any post that doesn't already have a preview image specified in the front matter, we'll

- generate a preview image and write it to a folder
- modify the in-memory post object to know that it has a preview image with a particular filename. Because this is a `:pre_render` hook, the HTML for that post has not yet been written to disk, so it's not too late to modify its metadata

And then, after the whole site has been written, copy all of those generated image files into place.

In this design, I don't need to commit all of the generated files to the repository, I just generate them at build time. I need to regenerate them each time I deploy. This is a bit slow and ineffecient. I might decide to just commit them down the line.

The actual image generation code is sort of hacky. It's a bit of ruby glue code that shells out to the venerable [imagemagick](https://imagemagick.org/script/index.php) CLI tool. It executes commands like this:

```shell
magick \
    -background "#f2d8b2" \
    -font "Helvetica" \
    -fill "#248165" \
    -size 1200x630 \
    -gravity SouthWest \
    "caption:The\ easiest\ way\ to\ indent\ paragraphs\ online,\ not\ that\ you\ necessarily\ should" \
    tmp/img/preview/2012-03-21-indenting-paragraphs-online.png
```

Which produces images like this:

[![example preview image with green text on beige background saying "The easiest way to indent paragraphs online, not that you necessarily should"](/img/2024-12-03-example-preview.png)](/img/2024-12-03-example-preview.png)

Kind of obnoxious right? A little brat maybe? You tell me.

Getting this to run in GitHub Actions presented a few challenges. The `ubuntu-latest` machine where the builds run had imagemagick installed, but it was imagemagick 6, not 7. `sudo apt-get install -y imagemagick` just complained that hey, it's already installed baby, nothing for me to do. But I had gotten all of this working with imagemagick 7 and I wasn't about to redo anything.

Once I figured out how to install imagemagick 7, I had the next issue, which was that no fonts were installed on the machine, at least as far as imagemagick could tell. After installing the [gsfonts](https://packages.ubuntu.com/jammy/gsfonts) package, it could see some fonts, but only the off brand, Linux versions of them. By running `magick -list font` in the CI context, I could see what those were. Eventually I worked out that something called Nimbus-Sans-L is basically knockoff Helvetica, which was what I had randomly picked locally. Great. Close enough. Perhaps you can tell but I have never really been a Font Guy. But I wanted this to work in both contexts, locally and in GitHub Actions. To work around that, I added some conditional logic to the ruby script to default the font to Helvetica, but allow overriding it via an environment variable.

And with that... everything was working, and I went to bed, criminally late, having forgotten what I originally had been planning to blog about. I remembered over lunch today and finished [that post](/2024/waitress-colorblind/). And now here's this.

Here's [the commit](https://github.com/maxjacobson/hardscrabble.net/commit/019fded4d2627c8ea20c634486df235b5a5b7253) with all of the code, if you're curious. It kind of works.
