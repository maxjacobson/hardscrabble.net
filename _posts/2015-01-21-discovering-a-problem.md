---
title: discovering a problem
date: 2015-01-21 00:15
category: blogging
---

![view source on a recent post](/img/2015-01-21-markup-view-source.png)

That's the "View Source" on a recent post here on the blog.

Do you ever discover a problem weeks or months or years after it was
introduced? How did you discover it?

The HTML markup on my website has been broken for a while, but I only just
noticed today, and then I noticed twice, the way you learn a new word and then
hear it again right away.

I've looked at that view source several times while poking around on this site,
and I can vaguely recall being concerned that some of those tags are
highlighted in red, but never taking much notice of it, because the site works
more or less fine.

Today while bored I took a look at a very neat iOS app called [View Source][],
which provides an iOS 8 extension for viewing the source of any website right
in Safari. When I tried to run it on my own blog (as you do), I saw this:

[View Source]: https://itunes.apple.com/us/app/view-source-html-javascript/id917660039?mt=8

![view source on a recent post in iOS](/img/2015-01-21-view-source-on-ios.png)

That... looks kind of wrong? Why's all the head stuff in the body? Huh?

So just a few minutes ago I opened up my text editor and opened the relevant
file to make a fix, and I saw this:

![HTML in vim with syntastic](/img/2015-01-21-markup-in-vim-with-syntastic.png)

Hell yeah! Where was that error message when I first introduced the problem?

Well, it was nowhere, because I only started using [that plugin][] like [last
week][], and I introduced the problem a full [615 days ago][] while sloppily
porting my layout from [haml][] to Jekyll.

[that plugin]: https://github.com/scrooloose/syntastic
[last week]: /2015/ambiguous-use-of-user-defined-command/
[615 days ago]: https://github.com/maxjacobson/hardscrabble.net/commit/2bbe8553e33f53d15dea6ce2384f094f1fbf4228
[haml]: https://github.com/maxjacobson/beefsteak/blob/4d305dca1d0c25a2bbefa6a4318a7df56f843f1d/views/layout.haml

Probably my moral is: be careful out there! And pay attention to your inklings.

Here's my second moral: even after making the fix, there are *still* some
errors reported by the plugin because it's confused by the Liquid tags, which
*aren't* valid HTML! I'm going to push the fix and use [the online validator][]
instead. *Sooooo* tools aren't a panacea.

[the online validator]: http://validator.w3.org/
