---
title: "sindresorhus/pure is such a good zsh prompt"
date: 2021-02-02 23:30
category: programming
---

Given how much time I spend in a terminal, typing things and hitting enter, I think it's a good idea to keep the vibe in my shell nice.
For the first like seven years of my coding career, I felt it was important that I design and maintain my own prompt.
There's evidence of this on my blog and in [my dotfiles repo](https://github.com/maxjacobson/dotfiles):

* In [December 2012](/2013/devblog/), when I used this character `ϡ` (???)
* In [June 2013](/2013/random-emoji-in-prompt/), when I used a little Ruby script to make it print a random emoji each time
* In [June 2015](https://github.com/maxjacobson/dotfiles/commit/86aa053847a037ea744cbf0bd80cdac1e1d79e90#diff-cb1e1ddc588b47fb67481acd89fdf355fb8a5848b703c55dc4e8fe9bdf75146f), when I wrote a shell script to display some git information about the current repository
* In [June 2016](/2016/the-first-useful-thing-i-wrote-in-rust/), when I kept the random emoji, but rewrote the script in Rust
* In [December 2017](https://github.com/maxjacobson/dotfiles/commit/822a93f83e1e2f5ccb0c1e3a300226e9727108ac#diff-cf07194ee232eb531e15f690000d19846dea69cf05504782658afcfacb9228a2), when I finally got rid of the emoji, because I was using Linux at work and couldn't figure out how to display emoji in my terminal emulator
* In [January 2019](https://github.com/maxjacobson/dotfiles/commit/62768389b2c4d34155bef47a4a6fe2dbff8a15ef#diff-cf07194ee232eb531e15f690000d19846dea69cf05504782658afcfacb9228a2), when I rewrote the git shell script in Rust, which I thought would make it faster, but actually made it slower, but by then I was too stubborn and just kept it

On some level, I felt like my shell prompt was an avenue for self expression.
I took some pride in that.
No offense if you don't care about yours, it's not a judgment thing.
I'm just trying to establish some stakes here.

I found myself annoyed by how long my prompt took to render, especially when working in large git repositories.
I spent some time optimizing it.
I disabled some of the functionality; for example, I updated the prompt to display my current git branch, but ripped out the "dirty checking" which changes the color of the branch when there are uncommitted changes.
I missed that functionality and brought it back.

Eventually, just as an idea, I decided to see what was out there.
I googled around a little bit, and found [sindresorhus/pure](https://github.com/sindresorhus/pure), which bills itself as a "Pretty, minimal and fast ZSH prompt".
That's basically what I want.

I installed it a few months ago, and... well, shit.
It's very good.

Here are a few things that are great about it.

When your last command failed, the prompt turns red.

When your last command took a while, the prompt automatically displays how long it took.
You don't need to have the thought "hm, that felt slow, was that slow? Should I re-run it with `time`?"


The prompt tells you when your branch is behind the remote, and you should might want to pull.
That means it _automatically fetches_, so that it can know that.
At first that seemed kind of crazy, that rendering my prompt would have side effects on my repository ("How _dare_ you, prompt?" was my gut reaction), but I've come to really appreciate it.
It's the best kind of automation, in that it becomes just one less thing I need to worry about.
That requires building some trust, but it did.

It renders super fast because it does a lot of its work asynchronously, like checking the git status.
It uses this script called [mafredri/zsh-async](https://github.com/mafredri/zsh-async) to do that.
The effect is pretty novel: the prompt renders right away, and then (sometimes) it changes a half second later.
It's a lot like an asynchronous request in a website, which fetches data and displays it when it's ready.
I skimmed the readme of that repo and I have no idea how the hell it works, but I basically don't care, I'm happy to let it be some magic.

There's only one thing that I miss from my days of customization.
Before I used pure, my prompt looked like:

```
hardscrabble.net main*
```

All on one line.
The first bit is the name of the folder.
Then the name of the branch -- printed in red, and with an asterisk, to indicate that there are uncommitted changes.

Imagine that you were at that prompt, and then you ran `cd _posts`.
What should it display then?
It would be pretty intuitive if it displayed this:

```
_posts main*
```

In my days of customization, though, my prompt would have displayed:

```
hardscrabble.net/_posts main*
```

The idea being that I wanted to know two pieces of information:

1. what repo am I in?
2. what path am I at, in that repo?

To achieve that, I needed to write [some clumsy, but workable Rust](https://github.com/maxjacobson/my-fancy-zsh-git-prompt/blob/cd0940a3f6110a5487388f52daba3a73fbbf68f2/src/main.rs#L95-L99).

By contrast, pure displays the absolute path to the working directory:

```
~/src/gh/maxjacobson/hardscrabble.net/_posts main*
❯
```

Which is...fine.

In summary, be like me: get over yourself and use pure.
