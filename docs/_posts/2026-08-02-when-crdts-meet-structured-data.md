---
layout: post
title:  "Two Shoppers, One Grocery List, and a Missing Bag of Dog Food"
date:   2026-08-02 10:00:00 -0400
tags: crdt sync offline localfirst
excerpt: >-
    Conflict-free replicated data types aren't infallible. Let's explore the ways they can help, and the ways they can be the wrong tool for the job.
description: >-
    Learn how to use structured data with conflict-free replicated data types. Decide if you should even use them at all.
---

[My previous post](https://brainframe.tech/blog/2026/07/26/when-edits-collide/)
demonstrated how to use [Conflict-free Replicated Data
Types](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type) (CRDTs)
to deal with concurrent editing of text between two offline devices, and making
it work. If you read that, you'll get lots of warm fuzzy feelings about them,
and feel like they're almost the answer to everything. If you haven't read that
one, I do recommend it. This post will still be here.

Going against that grain, this article will show the walls that I've run into
with CRDTs as I work on [BrainFrame](https://brainframe.tech). The prior one had
a happy ending, while this one does not. Still, it's worth the exploration to
understand *why* they aren't the ultimate answer to life, the universe, and
everything.

I want you to come away from this article with enough knowledge to understand if
you should use CRDTs for your own project. And for those who are just curious,
I'd like to welcome you as well. While this post is unavoidably technical, I've
worked to keep it legible to those who do not live and breathe this work.

* TOC
{:toc}

# A Quick Tour of This Article

Before we dive in: We cover a lot of ground in this article.

The next section, "Some Old Friends Go Shopping", sets up the example that I'm
using through much of this post. It shows a simple grocery list, and gives us
the mental model to explore some concepts that will be used by both you and me
while we evaluate how best we can use CRDTs.

The following section ("Structured Data and CRDTs") is all about CRDT data
types, and how they work with our example (and, with the library I'm using, how
they *don't* work). If you're already familiar with the common CRDT data types,
you can skip most of this section. I would, however, recommend picking back up
at "[Bob never bought dog food - When the tool broke down](#dogfood-breakdown)".
That's the description of the first failure I had that made me stop and look to
see if I was doing the right thing.

The section after that ("I'm not making an overly complicated grocery list. Why
do I care?") is a deeper dive that came out of that insight, and digs into such
things as schema vs schemaless YAML frontmatter, and when to choose one or the
other. I definitely don't recommend skipping that one. It's all about the
process I used when trying to make CRDTs and YAML frontmatter work for me in
BrainFrame. I wanted you to have this information to help you avoid making the
same mistakes I made.

The final section gives my lessons learned, and concrete advice about
whether or not you should even use CRDTs with structured data.

# Some Old Friends Go Shopping

Let's reintroduce Alice and Bob. After they [edited the owl out of that
document](https://brainframe.tech/blog/2026/07/26/when-edits-collide/), they
discovered they enjoyed each other's company, have moved in together, and are
planning their first ever grocery shopping trip. They need a grocery list. They
were even kind enough to give me a copy of it.

```yaml
store: Trader Mike's
dairy:
    - 1 dozen eggs
    - 8oz cheese
produce:
    - 5 apples
    - 5lb potatoes
cereal:
    - frosted wheat cereal
    - honey nut shaped o's
```

You might notice that (in the title) I promised some missing dog food, but it's
not on the list. Hold that thought. We'll [get to it](#dogfood-breakdown) as
soon as we can.

## Who Writes Their Grocery List Like That?

> Attention developers! This subsection is almost entirely to help our
> non-developer friends understand that example better. If you already know
> CRDTs and structured data, you should skip it, as it will be redundant for
> you.

Nobody I know will write out their grocery list looking like that, but I'm doing
it this time to provide an example we can work with throughout this article.

Calling back to the previous post, CRDTs are a long-winded way of saying "The
devices can always produce the same document, even if two people edit that
document at the same time in ways that produce a conflict." That was all about
editing text, just like you might type up in Notepad, or TextEdit, or even vi.

The grocery list above is formatted the way it is to provide an example of
something called "structured data". You've already worked with structured data
elsewhere: If you've ever edited a spreadsheet; if you've ever made your own
table in your favorite text editor; if you've ever made a to-do list; if you've
ever had your own grocery list. These are all structured data[^structured-data].
Nothing to be afraid of here, you've already used it. You just never knew it
would be called that.

## What *is* that grocery list, anyway?

The list itself is formatted using something called
"[YAML](https://en.wikipedia.org/wiki/YAML)"[^yaml]. It's plain text, just like
[Markdown](https://en.wikipedia.org/wiki/Markdown) is plain text. It has some
rules about the formatting, but first and foremost YAML is meant for *people*,
just like Markdown. It's why YAML and Markdown make for a powerful combination
for notes. It might look ugly (okay, no might, it does), but it is very readable
by people. You can see which store the list is for, which aisles in the store
Alice and Bob are going to visit, and what they're going to get from each aisle.

What makes this useful for us is that each of these things can be handled
differently than normal text. For instance, it's possible to maintain a
collection across devices and have them automatically sync up in ways that just
plain text has a hard time with. These special cases allow us to do things that
are otherwise very difficult to manage. I'm going to go over a few of the
special things we can do next. And when I get to the end of it, I'm going to
finally solve the mystery of the missing dog food. Explaining it just requires a
bit of understanding first.

# Structured Data and CRDTs

CRDTs are well-studied. Because of the properties they have, it's possible to
write code around structured data that does things that are surprisingly easy
with them, and difficult without them. We're going to go over some of the
possibilities here, but the [Wikipedia article about
them](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type) has a
more comprehensive list.

I'm going to focus on the ones that affect both our grocery list above, and
BrainFrame overall. By the time you get through these, you could be forgiven for
thinking I've forgotten about the overall idea of lists in YAML. I haven't.
We're going to be treating the aisle listings as sets instead in just a moment.
The list idea is what we'd call a "sequence CRDT", and one example of that is
just freeform text. After all, that text is just a list of characters kept in
order. To learn more about them, I'm going to refer you to my [previous
post](https://brainframe.tech/blog/2026/07/26/when-edits-collide/).

## Where are we going again? - How "Last Writer Wins" Works

Check out that grocery list again, specifically the very first line:

```yaml
store: Trader Mike's
```

The name of the store that Alice and Bob are going to is "Trader Mike's". What
happens when the edits come in? Alice decides to change the store to "Organics R
Us", while Bob changes it to "Food Tiger". If we use the same tools from the
sequence CRDTs, we'll wind up with something like "Organics R UsFood Tiger".
Alice and Bob can still have their discussion and figure out the correct store
name, but what if they didn't have to?

We can simply say that the last edit is the one that will always be the one that
gets chosen. If Alice made her change at 12:01pm, and Bob made his change at
12:02pm, then we can assume that his change is the one that everything should
reflect when everything synchronizes. We can then set the store name to be "Food
Tiger" just because his edit was the most recent one.[^hlc-vs-wall-clock]

In CRDT terms, we call this "Last Writer Wins", or "LWW". Generally speaking,
for freeform text, we don't want LWW. For a single value that should always
match some piece of reality (like the name of the store), using LWW is a valid
choice to make. While this example is a little forced for the store name, other
things matter more, especially for our notes that we want to make. For example,
we might want a `status` field to always be something the rest of the app can
recognize, like "work-in-progress" or "in-review" or "published".

## What are we buying? - How "Sets" and "Lists" Work

Once more back to the grocery list, where we can see things like this:

```yaml
    - 1 dozen eggs
    - 8oz cheese
```

Here, I need to be precise, and that precision can be difficult to see. In YAML
terms, this is an *ordered* list. If code were to redraw this, it should always
do so in the *same* order. For the grocery list, this can genuinely matter. It's
possible (especially depending on how well Alice and Bob know the store) to make
the items in the aisle appear in the order that they can be found in the aisle.

Instead, for BrainFrame, we're going to look at this as a set. This removes the
ordered aspect, and adds in another constraint that matters for BrainFrame, but
not for the grocery list: A set's items are always unique. A list, for contrast,
can have 12 entries that each say "1 dozen eggs", but the set can only have one
entry that says this. In YAML, they are going to be written down the same way:
No difference exists when you look at YAML. It's all about what the code does
with it that makes it different.

Compare and contrast these two: On a grocery list, you will change the beginning
of the string to reflect a quantity ("2 dozen eggs" instead of "1 dozen eggs").
For BrainFrame, the most likely use for this sort of thing will be things like
tags on the article, which should always be unique. For both of these, a set can
actually make sense. So can a list. And that is where the problem truly lies.

This is where *intent* matters, which is the thing that computers are bad at
guessing. I am choosing to treat these ordered lists as sets because I believe
that is the intent most of the time. That belief could be wrong, though, and I
can't know until users start working with the program.

The inability to determine the intent from the YAML also means that both of
these distinct things are very easily placed under the same conceptual category.

## Where is everything in the store? - How "Maps" Work

A little more YAML (and its explanation) before we can finally figure out why
Bob never bought dog food.

```yaml
dairy:
produce:
cereal:
```

These are all the names of the aisles that Alice and Bob are planning to visit
when they go to the store. They also happen to represent the most complex
concept that we've hit so far: Maps (and I don't mean the thing that has all the
roads on it).

Broadly speaking, maps use a string (usually a single word, such as the name of
a grocery store aisle) to say what can be found there (such as "8oz cheese" in
the "dairy" aisle). We call that string a "key", and we call what it points to a
"value". You can see it very easily yourself. Here's the dairy aisle again, just
to refresh your memory:

```yaml
dairy:
    - 1 dozen eggs
    - 8oz cheese
```

The dairy aisle contains two items in its set. In this form, it is very easy to
see and understand. It becomes harder when you understand that the things
pointed to by the key aren't limited to being sets. The entire grocery list is a
map. It has a "store" key, as well as keys for each aisle. Each aisle could be
further broken down. For instance, the following would also be valid for the
grocery list:

```yaml
dairy:
    eggs:
        - 1 dozen large
        - 1 dozen brown
    cheese:
        - 8oz cheddar
        - 4oz mozzarella
```

In this case, Alice and Bob have created a map of maps to make their shopping
trip hyper efficient. And they can continue making ever deeper maps. Each value
that they point to can be a string (like the store name), a map, or a set of
items to buy in that area of the store.

Critical behavior note: In any given map, keys are unique. To use our dairy
example, you can only have *one* `cheese` key. When programming, the result of
trying to add a second `cheese` key will destroy the original value and replace
it with the new value.

Maps are one of the most useful tools that we software developers have. It's
very easy for us to reach for them for many different uses. Sometimes, they feel
right at first, and then we find that they're the wrong tool, and we have to
change what we are doing. If we're very lucky, we find it out early enough that
we've only wasted an hour. Sometimes, the work can take weeks to unravel.

In my case, the pain wasn't just the lost time I spent chasing structured data
and CRDTs. It was the lost vision. To show why it got lost, it's time to explain
the missing dog food.

## Bob never bought dog food - When the tool broke down {#dogfood-breakdown}

Alice and Bob have made it to the grocery store, and they want to make it a
quick trip. They split up, and their devices go offline. While they're each
collecting the items from their part of the list, they realize they forgot to
add something: pet food! Alice adds the following YAML on her phone:

```yaml
pet_food:
    - canned cat food
```

Bob adds the following YAML on his phone:

```yaml
pet_food:
    - dry dog food
```

They've each got it in their notes on their devices. Before they actually pick
things up from the shelves, their devices manage to synchronize with each other.
If everything is behaving correctly, the results *should* look like this:

```yaml
pet_food:
    - canned cat food
    - dry dog food
```

A new map key was added to both devices. Each device added a set with a single
item to that map key. The *order* of the set on your screen can be reversed from
what I show above, but both devices should have them visible in the same order.
CRDTs manage this behavior well for structured data.

Plans rarely survive first contact with reality. When I tested this exact
scenario, I got a very different result. Here's what I saw:

```yaml
pet_food:
    - canned cat food
```

The dog food never made it into the resulting map after the synchronization
occurred. I could review the changes that each side was making. I could see the
dog food on the one side, and the cat food on the other, and the dog food was
simply *gone* from the result, as if it had never existed.

If Alice and Bob stick to their list, then by the time they get to the pet food
aisle, Bob will never buy the dog food. The exact order of operations
matters[^order-of-operations], so let's spell it out here:

1. The code sorted the changes, and Bob's edit was determined to be first.
2. The code made a new key in the map from Bob's edit, named "pet_food".
3. The code then assigned Bob's set as the value for that key - The "dry dog
   food"
4. The code saw Alice's new key "pet_food"
5. The code then set that key with Alice's set - The "canned cat food".

Remember: Keys *must* be unique in a given map. So when the code acted the way
it did, it overwrote the previous "pet_food" key wholesale. Instead of merging
the two sets together (the preferred and arguably correct behavior), Bob's dog
food was relegated to the dust bin.

I lost data. And data loss is the one thing I can't accept.

## Is this fixable?

And this is the most important question: Can it be fixed? The answer is an
unsatisfying "maybe". This is where the way that the CRDT library is written
matters; I'm not sure I could do better than the author on this, which is why
the answer is a "maybe". On the plus side, even if it turns out it can't be
fixed, it can be detected, which is arguably more important for figuring out if
your CRDT library is okay.

This is the most technically challenging part of this entire article, but it's
also the most critical for understanding what's gone wrong.

> I hate to tell my non-developer readers to pass it over, but this section is
> genuinely a lot of geek-speak, and I can't reduce that. Feel free to move on
> to the next section. If you *do* skip, take this one note with you: CRDTs, as
> a tool, are great at what they do. The specific tool I'm using didn't live up
> to those expectations.

When working with CRDTs, everything gets a unique identifier. With the library
I'm using, those identifiers are called "[Universally Unique
Identifiers](https://en.wikipedia.org/wiki/Universally_unique_identifier)"
(UUIDs). You've probably seen them at some point; they look like this:
`60c91291-aaad-4f1e-98b0-98f21a603497`. Each map key in the grocery list has
one. So `store`, `dairy`, and `pet_food` all have one.

The critical difference is that the others were agreed upon by the devices
*before* everything went offline. This is best described by stating the order of
operations explicitly. For this list, it's entirely arbitrary who did what. What
matters is how their devices dealt with the edits.

1. Alice created the file.
2. Both devices synchronized. Bob now has a copy of Alice's file.
3. Bob added the `store` key.
4. Both devices synchronized. Alice now has a copy of Bob's store key. This
   means that the UUID for this key is the same on both of their devices.
5. Repeat steps 3 and 4 for everything on the list: the keys, the values, the
   sets, everything. *Except* for the pet food.
6. Alice and Bob go to the store, and their devices go offline.
7. Alice adds the `pet_food` key. This generates a new UUID for *her* `pet_food`
   key.
8. Bob adds the `pet_food` key. This generates a new UUID for *his* `pet_food`
   key.
9. The devices come back online and synchronize. At this time, before the map
   gets re-evaluated, *both* copies of the `pet_food` key exist.
10. The map gets re-evaluated, and the key (which must be unique, remember) gets
    exactly one winner.
11. Bob's "dry dog food" entry is lost, because the differing UUIDs pointed to
    *different* "pet_food" keys. CRDTs themselves did not prevent the merge;
    this was the way the implementation was executed on this library.

The poor behavior here is subtle, but important: The library treated the
"pet_food" keys as different when deciding to merge (because of the different
UUIDs), but then treated them as the same when enforcing uniqueness. That
contradiction is what dropped the dog food on the floor.

I am speculating here, but I would be surprised if this isn't a common bug with
implementations doing what I'm doing. CRDTs absolutely require the
identity[^identity], and this is an easy bug to miss if you're not looking for
it.

Before moving on, an obvious question you're asking me right now: How do I check
my library for this? I'm going to answer with a bit of pseudocode. You need to
translate this for your preferred programming language and the library you are
using. Here's how you can do it in about 40 lines of code:

* Generate a device id for your CRDT library, call it "peerA"
* Generate a second device id for your CRDT library, call it "peerB"
* Generate a document for your CRDT library, call it "doc"
* Make sure that both peerA and peerB are working with your same document. This
  is likely some sort of "import/export changes" method, or even an "exchange
  document" method.
* Generate an Observed-Remove Map for your CRDT library and document, using
  peerA, call it "map"
* Generate an Observed-Remove Set for that map on peerA, call it "tags".
* Add the tag "tag1" to that set.
* Generate an Observed-Remove Map for your CRDT library and document, using
  peerB, call it "map"
* Generate an Observed-Remove Set for that map on peerB, call it "tags".
* Add the tag "tag2" to that set.
* Have both peers exchange their data (import/export changes, exchange document,
  etc, same as the document exchange above)
* View the resulting document from both peers. If your library handles it well,
  you will see both "tag1" and "tag2" in the result. If it does not, you will
  see only one of the tags appear in the document on both peers.

Once done, you'll know if you are subject to the same limitations I'm
describing. Two notes about this:

* Note that the names are *deliberately* identical. You need to generate
  conflicting names that can overwrite each other to prove what happens with
  your library of choice.
* The pseudocode is using an Observed-Remove Map[^or-map]. That's a deliberate
  choice. Don't just make sure the test uses it: Make sure your actual code that
  you will ship uses it as well. If your library uses a default map that doesn't
  use Observed-Remove, you may believe that everything is okay even though
  you're not *actually* using the Observed-Remove map.

In my case, I am looking for it because of BrainFrame itself. I need the things
I've been describing, but the ways in which I need them can be surprising.

# I'm not making an overly complicated grocery list. Why do I care?

Here's the surprising thing: Even if you're not making a grocery list, you *are*
using all those same concepts when you make your notes. I'll prove it with this
sample note:

```markdown
---
title: Review of The Tell-Tale Heart
author: Edgar Allan Poe
first_published: January, 1843
migrated_to_notion: false
status: work-in-progress
tags:
    - horror
    - fiction
---
This was a lighthearted romp through
the madness that descended on the
protagonist after killing someone.
I really enjoyed it.
```

Instead of calling it a grocery list, we call it "YAML frontmatter". It's
structured text that allows you to make tools that work on your notes. For
example, you may want to key off of the status. When that gets moved to
"published", you actually post the review somewhere.

You can see all the elements we discussed earlier: the whole map, the set of
tags, the status being a "last writer wins" value.

## YAML Frontmatter should obviously be structured, right?

> This subsection is a little more dry than most, and can be summed up very
> simply: Every field that appears in the frontmatter needs a type, and I'm now
> explaining how I chose the types. If you're comfortable already with choosing
> types, or simply not interested in how to do so, feel free to skip this
> section.

Thanks to everything you've learned throughout this article, you can see how
that YAML frontmatter is structured data, and BrainFrame should absolutely honor
that structure. I agree with you, and here's what I would do for that document:

* The entirety of the frontmatter is a map. You can see the keys and values
  already, so this makes sense.
* title is a string. I would treat this as text, instead of "last writer wins".
  Multiple people and devices might change that title before it is finally
  settled.
* author is unlikely to ever change for this example. It could be a "last writer
  wins", or it could be a string. I'm choosing a string (which is handled as
  text by the CRDT library), but either answer could easily be valid. The real
  danger is coming up.
* first_published is a "last writer wins". If somebody ever finds an earlier
  publication date, then we need to adjust it in one change. It looks like a
  string, but it's never going to be partially replaced or updated.
* migrated_to_notion is a "last writer wins". It's either been migrated, or it
  hasn't.
* status is a "last writer wins" as well. It's always one complete status, never
  a mish-mash of two or more.
* tags is a set of strings.

Looking at this, YAML frontmatter practically *begs* to be treated as structured
data. But looking back to the grocery store reveals an issue that makes it
problematic.

It's always easy, right up until it isn't.

## I've got 99 problems, and they're all schemas

Remember: YAML is for people, first and foremost. Us people are messy, and we
come up with new ideas all the time. It is trivial for us to add something to
that YAML frontmatter that we had never considered. For instance, maybe we
choose to add a link to the [Project Gutenberg page for The Tell-Tale
Heart](https://www.gutenberg.org/files/2148/2148-h/2148-h.htm#chap2.20) so we
can download it. That could look like this:

```yaml
url: https://www.gutenberg.org/files/2148/2148-h/2148-h.htm#chap2.20
```

While I'm writing the code, I have no idea what keys might be placed in the YAML
frontmatter. The URL is just one example. Maybe the user is doing a survey of
the favorite colors of the authors, so decides to add a `favorite_color` key. In
order for me to set up the code to handle structured data, I have to tell the
code what that structured data actually is. In software development, we call
that a "schema".

This lets us say things like "author is a string, handle it like text" and
"status is a 'last writer wins'". The code then honors those choices, and
everything works happily for the choices we have defined, as long as the user
uses those things in the same way.

What happens when the user decides to add that "favorite_color" key? Even worse,
what happens when they do it on their phone, and then switch to their currently
offline e-ink reader and add it there as well (since they didn't see it yet on
their e-ink reader)? We now have two keys, with two different identities, on two
different devices. Something is going to get lost.

What about that "author" key? What if we have two documents that try to do
different things here: one has only one author, while another has multiple
authors? Because we're dealing with code, we have to make a choice, and a bad
choice here mangles what the user actually wants. The author key can't have two
shapes in the code: It has to be either a single string, or a set. And if the
user tries to change the shape without a developer updating the code, their data
is going to get (at best) garbled. At worst, it could be completely lost, and
without any explanation as to why the data got lost.

That's the real danger: In order to have everything be structured data, we have
to commit to a schema that can't ever cover everything that the user needs.

## If I defined at least part of a schema, wouldn't that fix the problem?

> This subsection is almost an engineering journal discussing the options that
> got explored and why they didn't work. I don't want to cheat my readers out of
> this information, but I also acknowledge that it might be less interesting to
> some of you. Feel free to skip forward to the next header if this sort of
> discussion doesn't give you any value.

YAML gives us the ability to put structure on the text that goes into the
frontmatter. Using that knowledge, we could go for a hybrid approach: Define a
list of keys and how we will handle them, and leave the rest alone as user
input. If we do that, we can add in keys like title, aliases, url, author, tags,
status, and a few others.

Unfortunately, this still is broken from the user's perspective. As the
developer, I will miss more keys than I ever capture, and the user will still be
able to create more. What's more, that same data loss scenario comes back when
somebody adds the same key on two separate devices and then synchronizes them.
Telling the user "You used the tool wrong, so you lost data, sorry" is never a
sentence I want to say.

And with that, the complexity is just beginning. I can say "These are all the
keys that are supported by the YAML frontmatter, and no other key will ever be
allowed unless/until the code is updated to support it." By doing that, I've
just limited an incredibly useful tool into being something that *I* control and
decide, not the user.

I could make two separate front matter sections. The first one will be the one
that is all of the structured data that BrainFrame supports, and the second will
be the one that the user makes choices about. The problem then becomes "Which
frontmatter section is being looked at?" What if the user doesn't add the
BrainFrame supported section, but just adds their own section? They don't get
the benefit of structured data from BrainFrame at all then. And BrainFrame,
seeing only one frontmatter section, will have every reason to act as if that
frontmatter belongs to the BrainFrame-supported structured data, not the user's
frontmatter.

As a final option, I could make the schema into something that is stored in a
note. I could ask the user to take the time to update their schema every time
they want to add a new frontmatter field. It's not impossible, but it's pretty
horrible to tell a non-developer that they have to carefully update a file just
to protect their data from being destroyed.

## The final breakdown

In the end, one surprising revelation is what finally broke me: Comments. Let's
take that sample from above, and add something for us to do later:

```markdown
---
title: Review of The Tell-Tale Heart
author: Edgar Allan Poe
# need to double-check the first_published data
# and make sure it's accurate
first_published: January, 1843
migrated_to_notion: false
status: work-in-progress
tags:
    - horror
    - fiction
---
This was a lighthearted romp through
the madness that descended on the
protagonist after killing someone.
I really enjoyed it.
```

Comments have no structure. They attach to nothing. The comment I added above
could be anywhere in the frontmatter. Anything that changes that frontmatter
could cause BrainFrame to need to regenerate the entire frontmatter section. The
comment could be moved around or even destroyed.

My promise to the user is simple: Your data is protected. I will not destroy it.
I will not lose it.

Between the schema issues (especially coordinating that schema across devices
which may or may not be accessible when the updates need to happen) and the
ability to accidentally destroy the data, I hit the wall I could not overcome.

# How this broke my heart - Final thoughts

My vision did not survive the constraints I'd placed on myself. I want to have
everything be perfect. I want the user to have the ability to make a schema that
suits *them*. I want to support that schema by having everything be treated
properly: Sets, Maps, Last Writer Wins, all of it. I want the user to get all of
the possible benefits out of YAML frontmatter they could, fully supported by
BrainFrame and CRDTs doing things that other solutions just don't handle as
well. In other words, I want to have my cake and eat it too.

I thought I went into this with my eyes wide open. As it turned out, I was
committing one of the cardinal sins of software development. I had my vision. I
had a tool. And I got attached to using that tool to make my vision. And when
the tool couldn't support my vision, it hurt in ways that surprised even me. I'm
hoping that by sharing these lessons with you, I'll exorcise some of my own
demons and let myself move forward again.

Allow me to shorten these lessons for you now.

* Don't become attached to your tools. When they let you down (and sooner or
  later, they will, because no tool is perfect), it will hurt you deeply and
  keep you from moving forward.
* Learn the rough edges of your tools as quickly as possible. The sooner you
  know them, the sooner you can prevent yourself sailing off the edge of the map
  with no way back.
* Concurrent replicas are *hard*, and in surprising ways. No matter how much you
  may prepare yourself, it is easy to find yourself in a tough spot, trying to
  find a way out of it so your project can move forward. Don't give up. The path
  out may not be clear, but it *does* exist.
* CRDT Maps, Sets, Last Writer Wins, and other data types are the right choice
  for structured data as long as you have a well-defined schema. If your schema
  is not something you can fully define (such as what happens when the user can
  make any field they choose), I would avoid using those types. The difficulty
  of keeping everything in sync when there is no governance on what these things
  actually are is a problem with no solution I can find. For your use case, you
  can possibly still use CRDTs for freeform text, like I am. That's a
  surprisingly flexible option.

In the end, I had to make a choice that I hate, but it's my way out of the
weeds: YAML frontmatter, while it is structured data, is also just text. I'm
going to treat it as such, and provide tools to help my users make the best
sense out of it that they can should things ever get into a weird state. But I'm
not going to drop their data, and that's the important part.

If you have solutions to what I've described, or just want to commiserate about
the difficulties, I'm on Mastodon as [@pedersen@c.im](https://c.im/@pedersen).

I'll talk with you soon.

# References

* [BrainFrame](https://brainframe.tech/)
* [Conflict-Free Replicated Data
  Types](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type)
* [Hybrid Logical
  Clocks](https://sookocheff.com/post/time/hybrid-logical-clocks/)
* [Local First](https://www.inkandswitch.com/essay/local-first/)
* [Markdown](https://en.wikipedia.org/wiki/Markdown)
* [Project Gutenberg: The Tell-Tale
  Heart](https://www.gutenberg.org/files/2148/2148-h/2148-h.htm#chap2.20)
* [Universally Unique
  Identifiers](https://en.wikipedia.org/wiki/Universally_unique_identifier)
* [What's the Right Answer When Both Edits Are
  Valid?](https://brainframe.tech/blog/2026/07/26/when-edits-collide/)
* [YAML](https://en.wikipedia.org/wiki/YAML)

## Further Reading: Popular CRDT Libraries

This is *not* an exhaustive list, don't treat it as such. These are just some
that might be useful to you:

* [Automerge](https://automerge.org/)
* [crdt_lf](https://pub.dev/packages/crdt_lf)
* [Yjs](https://yjs.dev/)

# Footnotes
{:.no_toc}

[^structured-data]: I'm being deliberately a bit handwavy here. Some of these
    more correctly fall into a category known as "strongly structured data",
    while others fall into the category known as "semi-structured data" or
    "loosely structured data". Arguably, something like a todo list could even
    be labeled as "unstructured data", and would be treated that way in rigorous
    practice. However, with the way I'm using it here, it fits into the
    "semi-structured" bucket. There are important technical differences between
    the three, but this post isn't about those differences. We're going to
    explore why any kind of structured data coupled with freeform text is a
    problem for CRDTs, so I'm going to continue to ignore those differences for
    this article.

[^yaml]: I hate leaving acronyms unexplained, but this one is basically a joke
    for computer programmers. YAML stands for "YAML Ain't Markup Language". It
    can do a lot, and the [Wikipedia
    article](https://en.wikipedia.org/wiki/YAML) goes into it in depth. For now,
    just know that it's something simple for us humans to read.

[^hlc-vs-wall-clock]: When you're familiar with CRDTs, you'll catch a
    simplification here that could throw you off. I'm using the wall clock as a
    stand-in for the [Hybrid Logical
    Clock](https://sookocheff.com/post/time/hybrid-logical-clocks/), or HLC. An
    HLC (which is what BrainFrame is using behind the scenes) is how the
    ordering actually gets determined, not the clock on the wall. I'm using the
    clock on the wall as an easier way to understand the ordering. HLC is the
    decider, but that comparison is harder to make in a post like this. If
    you're not already familiar with HLCs, it's worth noting that they do *not*
    guarantee a match to the actual time. Frequently, they will line up.
    However, computerized time-keeping is imperfect, and drifts (or is manually
    configured to be wrong). Even though HLCs record that time, it's important
    to note that they work strictly for ordering, and do not (ever) guarantee
    that they are actual timestamps. Treating them that way will only make your
    life more difficult. For still more information, see the [article about
    them](https://sookocheff.com/post/time/hybrid-logical-clocks/).

[^order-of-operations]: This order of operations hides something subtle that you
    might have carried forward from the "Last Writer Wins" topic: The way I've
    phrased things suggests an order based on time. Alice edited, Bob edited,
    and I've kept that ordering because it's alphabetical, not because of any
    perceived order. What matters in this case is that the edits were made while
    both devices couldn't talk with each other, and then the code had to decide
    what to do with those edits when synchronization occurred. The code in
    question did its own internal sorting to determine which operations happened
    in which order. It could have just as easily gone the other way, where Alice
    might have not picked up the cat food. Don't take my arbitrary alphabetical
    ordering as the canonical order that CRDTs in general would apply things.
    Your individual CRDT library might use a different clock or a different
    mechanism for sorting.

[^identity]: Don't assume that "identity" must mean UUID. It could be a counter,
    with each character or key getting a number. It could be a UUID. It could be
    a different type of identifier entirely. This is an implementation detail of
    the library. It would be good for you to know what your CRDT library is
    doing under the hood, but CRDTs don't mandate the use of UUIDs. They're just
    convenient for us.

[^or-map]: I didn't cover Observed-Remove in the basic data types because they
    added length to this post without enhancing anything from the basics
    section. The idea behind them is that no peer should ever remove data unless
    it saw that data before trying to remove it. In the bit of pseudocode that
    brought you to this footnote, if you were to tell peerB to remove "tag1"
    from the set *before* the final exchange, the tag should survive. If you
    were to tell peerB to remove "tag1" from the set *after* the final exchange,
    the tag should be deleted. For more detailed information, see
    [Wikipedia](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#OR-Set_(Observed-Remove_Set))
    and its references.