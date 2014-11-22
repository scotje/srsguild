# srsguild

A self-hosted MMO guild management application, written in Ruby on Rails.


### Where did this come from?

I wrote it, like a billion years ago, with the idea of building a side business around it.
I recently decided to open-source it and try to get it modernized and fixed up enough that
anyone interested could run it on their own server.

### What is its current state?

I actually got it running again on my local machine pretty quickly, but I wouldn't really
expect anyone else to get it running currently (Nov 2014). The last commit before it's hiatus
was in 2010 and at that point it was based on Rails 2.3.8. It's also based on the paradigm of
a single install hosting many guilds which probably needs to change.

From a functionality perspective, all the guild/character import from the WoW Armory stuff
is obviously broken. (The good news is that Blizzard has an actual public API now for that.)
But the scheduling/attendance interface still seems to work fine. I haven't tested the balance
(DKP) tracking yet though.

### What needs to be done?

I created some [milestones over in the Issues area](https://github.com/scotje/srsguild/milestones)
that outline broad areas in most pressing need of attention. I plan to attack these
rather savagely as time allows. If you are an experienced Ruby developer / archeologist and
feel inclined to contribute, pull requests are welcome!
