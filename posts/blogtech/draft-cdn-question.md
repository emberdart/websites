---
title: 'The CDN Question'
date: 2026-07-14T17:21:00+01:00
draft: true
aliases: [ "/2026/07/cdn-question" ]
tags: [web,websites,dns,networking,cdn,cloudflare,akamai,aws]
---

It's time to answer the CDN question: how many of the bookmarked sites I have are backed by what CDNs?

Any bets?

Starting with a list of approximately 5,674 domains and subdomains, this produced 6,392 unique IPv4 addresses and 3,932 unique IPv6 addresses.

This doesn't give a decent answer, because it just deduplicates all the endpoints, but it might be interesting to see which have the most endpoints first: 




Here's what it came to:

Interestingly there were a bunch of nonstandard TTL values looking up this stuff, I normally expect things divisible by sensible fractions of hours or days, but this was kind of crazy:

