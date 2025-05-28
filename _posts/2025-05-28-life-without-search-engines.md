---
title: Life without search engines
date: 2025-05-28 18:52
category: personal computing
---

I thought it would be fun to try taking a break from using search engines. Is this possible?

Like everyone else, I've used Google a ton and it's been very useful. In recent years, I've felt kind of like Google isn't serving my needs as much. I'm not a big fan of the AI widgets at the top of the search results (see this recent article, [Google Is Burying the Web Alive](https://nymag.com/intelligencer/article/google-ai-mode-search-results-bury-the-web.html) from John Herrman). And I find that when I visit the Google homepage on my phone, it's popping up clickbait articles under the search bar that are uncannily good at grabbing my attention, and suddenly I'm forgetting what I was going to search for in the first place.

I tried out DuckDuckGo for a few months and it's a fine replacement, but they're also popping up a little AI widget all the time and you can ask it to go away but then it just comes back after a while and that kind of rubs me the wrong way too.

I just tried out Kagi for a month. It's a paid search engine, and it's $10 per month, but you only get 300 searches per month, and I apparently use more than that, and I can't quite bring myself to pay $25 a month for this, so I think I'm out.

If there's no search engine that I'm excited to use, maybe I should use _no_ search engine? It's a bit of a hard sell, given that I clearly love to search (I used up my 300 Kagi searches in 20 days!). It's muscle memory: just write something and hit enter, over and over.

But I know how to break muscle memory. Recall my [steam locomotive post](/2022/steam-locomotive/) about how to break command line habits. All I need to do is find a way to see a six second animation of a train whenever I try to google something, and then I'll stop googling things.

Thankfully, most browsers have a way to specify a custom search engine, and I know how to make websites, so I can just _make my own_ search engine, and configure my browser to use that. And I can make that search engine display a six second animation of a train, or whatever else I would like.

Despite being motivated here by some antipathy for AI insofar as it is not what I am looking for when I am just trying to Google something, and even though I do worry that it is fairly likely to put me out of work in the next few years or at the very least make my job [different in ways that mostly suck](https://www.nytimes.com/2025/05/25/business/amazon-ai-coders.html), I can't help but be curious about how other people are using it, and so I decided to try to build this search engine site by [vibe coding](https://en.wikipedia.org/wiki/Vibe_coding). I've had fairly limited success with vibe coding but this seemed pretty doable. I was inspired by [a recent blog post and video from Mary Rose Cook](https://maryrosecook.com/blog/post/using-ai-to-build-a-tactical-shooter) demonstrating how she approaches "AI-Augmented Programming" which gave me some insight into _how_ to actually use these things effectively, which doesn't come super naturally to me.

Here's what I came up with:

<https://maxjacobson.github.io/search-engine/> ([source](https://github.com/maxjacobson/search-engine/tree/v0.1.0)) (GitHub Copilot wrote 100% of this code and I didn't read any of it)

[![gif of searching in MJ Search and getting no results](/img/2025-05-mj-search.gif)](/img/2025-05-mj-search.gif)

No matter what you search, you see a spinner for two seconds and then it says "There are zero results". Lol.

I think this should be basically fine. I can bookmark websites that I know are useful, and I can go to them, and I can use the search functions built in to those sites. That's the plan.

This feels likely to flop, but I think it'll be interesting. Will report back 
