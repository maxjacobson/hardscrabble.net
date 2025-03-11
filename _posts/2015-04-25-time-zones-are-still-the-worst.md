---
title: time zones are still the worst
date: 2015-04-25 16:24
category: programming
---

After publishing [my last post][1], a few minutes ago, I of course triggered
refreshes until the reminder ticked down to "0 days and 0 hours", but... it
didn't work.

[1]: /2015/my-new-menu-bar-guilt-trip/

Instead, I saw: "0 days and 4 hours". What the hell?

My first instinct was to blame the script and feel a little embarrassed for
sharing a faulty script.

After a little digging, I realized it was worse than that: it was actually my
RSS feed that was faulty! This commit fixed the problem: [642cd54][2].

[2]: https://github.com/maxjacobson/hardscrabble.net/commit/642cd54bf4ea6667d38970049fd47065c610b611

Because I wasn't supplying a time zone in the metadata for the post, Jekyll (my
blog generator) had to make an assumption, and it assumed UTC, which is
currently 4 hours ahead of New York, from where this blog emanates, and from
where I anxiously remind myself to update it.

By stating that I was publishing a post at 15:53 UTC as opposed to 15:53 EDT, I
was effectively backdating it, which makes it sort earlier in RSS feeds. One of
my favorite blogs, [The Setup][3], doesn't supply times at all, only dates, so
whenever a new interview arrives, it arrives buried below all of the day's
posts, which I find mildly inconvenient. It pains me to know I've caused
something of the same, and I apologize.

[3]: http://usesthis.com/

But at least the script is fine!
