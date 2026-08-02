---
layout: post
title:  "What's the Right Answer When Both Edits Are Valid?"
date:   2026-07-26 12:00:00 -0400
tags: crdt sync offline conflictresolution
excerpt: >-
  One harmless four-word sentence turns out to break every notes app that syncs
  across devices. Here's the problem, and the family of solutions that leads
  to CRDTs.
description: >-
  Why concurrent edits are hard, and how CRDTs let offline devices agree on the
  same result without a central server.
---

"The colorful owl sat."

One single, simple sentence. Perfectly innocuous. Unremarkable even. And yet,
somehow, this one little sentence is the introduction to an entire class of
problem that has a major impact on BrainFrame (the local-first, own-your-notes
app that I'm building). That impact is large enough that I've spent literal
weeks wrapping my brain around it, and around the solutions for it.

Here's the interesting part: If you've ever edited a shared document, that odd
little sentence up there has affected you, too. What should the program do when
you and a collaborator both edit the same thing in different ways? Or if you,
working alone, edit the same document in different ways on different devices,
even offline?

Come with me on this journey into the interior of offline editing. I'll keep
this lightweight. There's no code discussed in here. This is all about exploring
possible solutions and showing why things are the way they are.

# When Edits Collide

Our odd little sentence needs some collaborators. Say "hi" to Alice and Bob.
They're both working on the same document that contains our sentence. Both Alice
and Bob think the word "owl" doesn't really fit their overall theme, so they
choose a different animal.

Alice is a dog person, so she changes the word "owl" to "dog". Bob is a cat
person, so he changes the word "owl" to "cat". As it just so happens, they do
their changes at the same time, right down to the millisecond, one letter at a
time. And now the program has to make sense of it all.

What should the program do?

# Working In An Always-Online World

Before we dive into anything else, let's check out how the online world works.
You've already seen this sort of work happen, and it's virtually guaranteed that
you've used it. Google Docs with a collaborator is a prime example of exactly
this sort of work. Both people online, editing the same document. Frequently,
there is also a voice call where the collaborators are talking through what
needs to be done.

The magic in this solution is multi-fold:

* A central server acts as the referee. Essentially, Alice types her edit, Bob
  types his edit, and the central server receives the edits and makes its
  determinations about the output.
* Add in the voice call, and Alice and Bob both have a little laugh, settle the
  age-old debate of cats vs dogs, and one choice gets made by the humans to
  resolve the conflict.
* Without the voice call, you still get collaboration, it's just a matter of
  somebody making a choice and updating the edits again.

You've already dealt with these exact sorts of conflicts before. Having the
central server referee the results is what happens, and humans are always kept
fully in the loop about what is happening in real time. That makes the entire
process easy to handle.

One document. One source of truth. Humans controlling every step of the way in
lockstep.

Unfortunately, this solution goes against the very nature of BrainFrame. Offline
first, local editing, and the lack of a server means that something else has to
happen. Fortunately, software developers have been dealing with variations of
this problem for decades, and have come up with many ways to work with it and
get something resolved. Going over all of those options would be worthy of a
book[^nobook], so I won't cover them in this post. I can promise that we have
been dealing with it since at least the 1960s[^sccs]. In one example that comes
to mind, a professor in college told the class I was in that one software
development group used paint sticks with file names on them. When a developer
wanted to update a file, they had to claim the paint stick. And then return the
paint stick when they were done. We have better solutions today 😀.

# When Locking Isn't Enough

That paint stick anecdote is an example of something called "pessimistic
locking". On the surface it seems like a viable mechanism. Why not just prevent
somebody from editing the same file at the same time?

What happens when the edits *don't* hit the same area? Alice is working on a
section talking about the colorful owl. Bob wants to work on a very different
section, and that section is just a table of contents for the whole document.
Alice has the stick, so Bob can't make his edits even though there's no reason
to prevent the edit. And what happens if Alice goes on vacation, or loses the
stick, or it gets broken somehow? Unless that stick gets replaced correctly,
nobody else can ever edit that file.

That sounds like it wouldn't be a problem in today's world, but what happens if
the paint stick is being held by a phone, and that phone gets dropped in a lake?
Without some work by somebody with technical skills, that file is locked
forever. Bob can never update the table of contents.

There is a variation called "optimistic locking" which addresses some of these
problems, but even it has limitations. For optimistic locking, the file would
get checked on save. The program basically asks "I'm about to overwrite this
file with new contents. Did somebody else update the same file while I was
editing? Or is everything good to go still?" The biggest problem with optimistic
locking is the need to have a second view of the new file. And somehow, the user
has to be able to tell the differences between the original file, the version
somebody else saved, and the new version of the file they are trying to save.

It's a lot to ask of a human: Compare three things and figure out what changes
need to make it into the final results. Software development has a huge toolkit
built around this exact problem, and it's still messy. For something like "The
colorful owl sat" it's easy. But what happens when the changes are spread out
over a thousand lines? How can the human in the loop resolve this in a
meaningful way and *not* lose entire days just handling a simple line-by-line
comparison?

This is where a pattern is beginning to form: All the solutions sound easy,
right until they aren't.

# When Diff Isn't Enough

Software developers reading along have already picked up on this next section
because they live it every day. We call these patterns "diff" and "merge".

Broadly speaking, there are two kinds of changes: conflict-free and conflicted.
Using our example above, what happens when it's only Alice editing the file? She
changes "owl" to "dog", hits save, and that's the end of the story. This is a
conflict-free change, and it's extremely easy to manage. If Bob makes a change
to the table of contents, he's not even editing the same section of the file. We
now have tools that make both of these changes conflict-free (for instance,
[git](https://git-scm.com/)), so we software developers have, by and large,
abandoned using locks for writing our code. It's safe to say that conflict-free
changes are almost boring at this point.

Conflicted changes are where it gets more interesting again. Go back to our
original example: Alice changes "owl" to "dog". Bob changes "owl" to "cat".
Unlike the real-time world of always-online, there's no one to talk to offline.
In the world that BrainFrame lives in, that's not viable. A human needs to sit
down, review the changes, and make the choice to determine what edit wins.
Entire tools and websites (like [GitHub](https://github.com/)) exist to make
this process more manageable. As a developer, we go to the central source of
truth and make a choice. Once we have made that choice, all the other developers
have to grab that choice into their code.

The tools we have make it manageable, but they are decidedly *not* friendly
tools. Asking non-developers to master these tools is being unkind to them.

What happens, though, when there is no central server? What happens when Alice
and Bob make their edits at the same time, right down to the millisecond? It's
not a good idea to ask the user to use tools like GitHub for what is free-form
prose (the heart of every note every user makes). It's not a good idea to
present a separate note into their notes collection calling out the conflict.
The user has to spot it, and that is something very easy to miss.

The common thread for all of this is the decision: The user is always involved.
The computer can't make the decision, because it doesn't understand the *intent*
of the user. Without that understanding, it can't do any resolution. And without
that resolution, the user has to step in and assert control over the process.
Sometimes, this is required. But most times, and especially for free-form text,
it really isn't.

How can we let the computer do the work for us, and just tell us if/when we need
to be involved afterwards?

# Something Old and Something New: CRDTs

After all of the above, you might be feeling hopeless. I know I did. I know what
I want, but I didn't have anything to anchor it off of to actually *get* what I
want. Not until I found out about [Conflict-free Replicated Data
Types](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type), or
CRDTs. These were first defined in 2011, and have been refined greatly in the
many years since then.[^operational-transform] The technology itself is old, but
for me, it is very new. I've only been learning it over the past couple of
weeks.

That mouthful of a name is a long-winded way of saying "The computer will always
figure out a merge path, and will not trouble the user with the need to deal
with merges." In the next section, I'll go over why this isn't perfect, but for
now, for BrainFrame? CRDTs cover over 90% of all the cases for me very well.

Let's build up what we're doing, and how CRDTs handle them, one step at a time.
As I promised in the beginning, I'm not going to post code here. This is all
about what the results of using CRDTs are, and why they help.

## Case: 1 User, 1 Note, 1 Device

Alice types up her note: "The colorful owl sat." She saves it. Comes back a day
later, and changes "owl" to "dog". For this case, we don't need any special
mechanism. Your favorite text editor handles it without any stress to it or to
you.

## Case: 2 Users, 1 Note, 1 Device

Alice and Bob share the laptop. Alice logs in, makes a change to the file. Bob
logs in, makes a different change to the same file. Again, nothing special here.
All of the cases so far are manageable with your favorite text editor.

## Case: 1 User, 1 Note, 2 Devices

A naive approach to this would say that there's really no difference between
this and the first case. Alice can only edit in one location at a time, so the
changes are always going to be visible. That approach assumes an always-online
world, even without a centralized server. What happens if Alice's phone runs out
of battery? If she had changed "owl" to "dog" on her phone beforehand, we have
an edit that her laptop doesn't know about. She continues editing the original
document on her laptop, waiting for her phone to charge up. Once it does, she
turns it on, and the synchronization process begins. The "owl" becomes a "dog"
finally. But what if she changed her mind, and decided to turn the "owl" into a
"cat" while waiting for her phone to charge up? What happens then?

## Case: 2 Users, 1 Note, 2 Devices

Alice has a laptop, Bob has a phone. They are editing the same note, at the same
time, and staying in sync. There is no central server, the two devices have to
figure everything out and present the results to the user in a way that makes
sense. Possibly even more importantly, the two devices have to present the same
results to Alice and Bob without the devices "arguing" about which one of them
is right.

Remember: Alice changed "owl" to "dog", and Bob changed "owl" to "cat". How do
we decide on the result in a way that allows Alice and Bob to find and fix the
conflict?

## Convergence

This is the heart of the problem. Everything else is a special condition on top.
How do two devices receiving concurrent updates from each other make sure
they're giving the users the *same* result at the same time without some sort of
arbitration mechanism? How do they converge on a result they give to Alice and
Bob?

CRDTs do exactly this. I'm going to be a bit handwavy here, since I promised no
code. What CRDTs do, though, winds up feeling like magic, *especially* when
there's no conflict. Alice changes "owl" to "dog", Bob edits the table of
contents. Both devices synchronize. This is the most boring possible case for
all of it: The changes simply land where they are supposed to.

The whole process is transparent to Alice and Bob. No having to go to a central
source of truth and figure out the conflict and then make sure everybody gets
it. For Alice and Bob, the work is handled automatically by the computers, the
updates land, and everybody is happy.

The changes are anchored in the text in such a way that even if one of them
deletes a major section, as long as they don't conflict with each other, all
changes will come out matching Alice and Bob's intent. The document will remain
coherent and complete.

It might not be magic, but it certainly will feel like it. Documents get
synchronized across multiple devices with multiple users and everything
continues to make sense.

Or does it?

# CRDTs Aren't Magic

CRDTs provide a way for the computer to determine what should land, in what
order, when document edits collide. I cannot overstress the importance of this
enough: The mechanism *only* guarantees you a result; it does *not* guarantee a
meaningful result. For that, we still have to rely on the human in the loop.
What we can do, though, is make it easier than the tools that programmers have
to use. Prose doesn't have to go through the same process that code does, so if
a mistake lands somewhere, the fix is easier to manage.

Make no mistake, though: Conflicts are a real problem, and not even CRDTs solve
them entirely. For that, let's lean into our example from the beginning: "The
colorful owl sat." Alice changed the word "owl" to "dog", and Bob changed the
same word to "cat" at the exact same millisecond that Alice did. Above, I've
asked you to consider what happens, and how other systems try to solve it.

CRDTs solve it differently. Instead of picking a winner, CRDTs let *both* edits
win, simultaneously. All by themselves, CRDTs will produce a result that is
undeniably gibberish. "owl" will become something like "cdaotg". Look through
that mess, and you'll see the words "cat" and "dog" mixed together. The reason
for this is that additions to the note are prized above all else. If somebody
added something, then the result should have all of what they added. Since Alice
and Bob were typing at the same speed at the same time, their results got mixed
together at the same spot in the document. While the gibberish is, of course,
bad, it has one property that is good: It is *consistent*. Each device that
tries to view the note will get the *same* gibberish.

Have hope: All is not lost. This is a well-known problem, and it has a solution
that makes the gibberish more legible to humans. That solution is called
[Fugue](https://mattweidner.com/2022/10/21/basic-list-crdt.html). When we apply
that solution, the letters of the word stay together. The result of using Fugue
on these same edits will be either "catdog" or "dogcat" (there are some sorting
rules that come into play that I won't go into for this post). While it's
obviously wrong, it's also something that us humans can reason through and fix.
Either Alice or Bob will make updates to the note, removing what they
collaboratively decide is the wrong word, and the note will make sense.

Where the hard part comes in is making sure that the conflicts are brought to
the attention of Alice and Bob. If they're working with an entire collection of
notes, and these edits conflict, the application needs to notify them about the
conflict and direct them to its location. Then the human in the loop can fix the
problem.

There's something even stranger hiding in our example: "The colorful owl sat."
Alice decides to change the word colorful to the British spelling: "colourful".
Bob decides to delete the line entirely. This is the most counterintuitive part
of CRDTs. Before I tell you the answer, can you guess it? Take a moment and
think about it. What will happen?

The answer will surprise you unless you've already spent time studying CRDTs.
The algorithms in this case are heavily focused on preserving every single
addition *after* all the deletions happen. If somebody took the time to add
something, we want to make sure that addition gets preserved. That's why the
only thing left in that example is the single letter "u". No, that's not a
mistake. Alice added a letter. Bob deleted every letter in that line *except*
her addition. Alice's newly added letter survives.

It might seem like this is a problem that the computer should be able to solve,
but it is actually impossible. The computer doesn't know what Alice and Bob
*want*. It can't discern intent from the text of the note. It can only direct
their attention to the conflict and let *them* decide what the correction should
be. Someday, we may be able to hook our brains up directly to the computers and
express our intent. If that day comes to pass, then the computer can solve it
for us.

That's not the only cost of CRDTs. CRDTs have hidden bookkeeping costs. They
have to track every single change to every single character across every single
device. Those changes can't be discarded until every device has checked in and
confirmed it has the updates for that note. If a device suddenly winds up at the
bottom of a lake, we have to provide additional housekeeping tasks that allow
Alice to tell the computer that a device is gone and won't come back. Otherwise,
the collective changes for the note will grow forever. A single note that is
only a few kilobytes in length could have its change history occupying hundreds
of kilobytes (even megabytes) otherwise.

CRDTs make compromises, the same as every other solution we have. Those
compromises keep most of the cases running perfectly most of the time. As long
as we make sure that Alice and Bob can keep their eyes on enough information to
make those compromises acceptable, they work well.

Of course, this is all about text. Binary files (like graphics, PDFs, and ePubs)
are an entirely different story. And that story is part of BrainFrame's overall
story, too.

# When "Good Enough" Is Enough: BrainFrame's Bet

We've covered a lot of ground here. We've got history, we've got software
development, we've even covered a few topics that most people outside of
software development have never even heard of ("pessimistic locking" anyone?).
All of this material is a way for me to communicate why I'm making the choices I
am for BrainFrame.

CRDTs are a tool that takes away most of the frustration of shared offline
editing with no central server. Unless you're a developer, you're not likely to
want to deal with locks and merges and conflict resolutions. Scratch that last
one: Not even developers want to deal with conflict resolution; it's pretty
horrible. That doesn't change the value of CRDTs.

For you, the goal is to provide a set of markdown files that you own, you edit,
you explore in your own way. To do that, and to provide the multi-device
experience that has come to be expected in the current age of computing,
BrainFrame has to do some background work. I'm already working on that, and I'm
making sure that the work is isolated from your notes. You will be able to use
any editor to make the files (yes, even Notepad/TextEdit/vi if you so choose),
and BrainFrame will do the work to make sure all your devices get it.

As was shown above, CRDTs aren't magical, no matter how much we all wish they
were. Despite the ways in which they can miss, they provide escape hatches for
us. We can detect when things look like they weren't handled smoothly. We can
make sure to bring those to the attention of the user of BrainFrame. We can
provide the right assistance, at the right time, to make sure that notes stay
coherent. It's a big bet, but it's one that I can (and will) deliver.

Another question some of you might be picking at: What about binary files? Their
answer is more mundane: The entire file has to be edited as a single unit. The
actual send between devices might be done in individual blocks and reassembled,
but the edit can never be at the individual character level. PDFs, ePubs, and
graphic files do not survive having their internals edited, and quite likely
will have their native editors and viewers simply put up an error message saying
that the file is corrupted. Sadly, we don't have the magic for handling them
properly yet. That's okay for us, though, since BrainFrame is about providing a
means to annotate and link to those files, not to make edits directly to them.

Other considerations do exist, and I'm not going over them in this article at
all. Things like "How do other devices actually *get* those changes?" are very
different questions, and are likely worthy of multiple articles.

# Conclusion

"The colorful owl sat." Four innocuous words. Three changes, "dog", "cat", and
British spelling. Six words in total. And all of it turned my world upside down.

You don't have to be a software developer for this to have turned your world
upside down either. You can see the problems. After this article, you can even
talk about them, maybe for the first time. And that is my true hope: Not that
I've turned your world upside down, but rather that I've given you something new
to think about. And if you *are* a software developer, perhaps even a new
problem to help solve for the world.

Go forth, and edit your notes. My job is to make sure those edits work. I'm on
it.

If you'd like to have a conversation with me about this article, you can find me
on Mastodon as [@pedersen@c.im](https://c.im/@pedersen). I look forward to it!

# Links and References

* [BrainFrame Code Playground](https://github.com/BrainFrameTech/playground) -
  This is where I did my examination of CRDTs, but it will eventually include
  other code snippets. It's not production code, it's all about learning the
  behavior of tools that I am using.
* [CRDTs](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type)
* [Dart crdt library](https://github.com/MattiaPispisa/crdt) - This is the CRDT
  library being used by BrainFrame. Look under
  [packages/crdt_lf](https://github.com/MattiaPispisa/crdt/tree/main/packages/crdt_lf)
  for the exact library source.
* [Fugue](https://mattweidner.com/2022/10/21/basic-list-crdt.html)
* [git](https://git-scm.com/)
* [GitHub](https://github.com/)
* [Operational
  Transformation](https://en.wikipedia.org/wiki/Operational_transformation) - An
  alternative technique that could have been used to replace CRDTs, but was not
  chosen.
* [Google Docs](https://en.wikipedia.org/wiki/Google_Docs) - One of the most
  famous products that *does* use Operational Transformation.

# Footnotes

[^nobook]: Amusingly, this doesn't seem to exist at this time. The history is
    scattered across chapters, papers, and articles. The topic is still
    book-worthy, and will have references to tools that are considered laughably
    primitive today. I'm not the person to write it, though. BrainFrame demands
    too much of my time for me to make an effective author for the topic.

[^sccs]: The first program to formalize this whole process was called
    [SCCS](https://en.wikipedia.org/wiki/Source_Code_Control_System), and was
    released in 1973. The problem itself is, of course, older. The code wouldn't
    have been written if the problem didn't exist. Considering the first
    multi-user operating system looks to be
    [CTSS](https://en.wikipedia.org/wiki/Timeline_of_operating_systems#1960s)
    (released in 1961), it's safe to assume the first conflicts were being felt
    by users around the same time.

[^operational-transform]: A similar technology known as "[Operational
    Transformation](https://en.wikipedia.org/wiki/Operational_transformation)"
    takes a different approach. First defined in 1989, it was later adopted for
    use in [Google Docs](https://en.wikipedia.org/wiki/Google_Docs). While there
    is no actual *requirement* for using a central server to be successful with
    Operational Transformation, the complexity involved in getting it right
    (especially when CRDTs are much easier) makes this option a non-starter for
    BrainFrame.