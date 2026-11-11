---
layout: post
title:  "Your Files Are Rotting. What Can You Do About It?"
date:   2026-11-11 18:00:00 -0500
tags: archiving preservation backup pkms
excerpt: >-
  Your grandparents' photos and journals lasted for 70 years in a shoebox.
  The photos you take today might not last 15. Here's how to make sure they
  do.
description: >-
  You don't need a library science degree to protect your data, but you do
  need a system. A practical primer on choosing durable file formats, keeping
  real backups, and refreshing drives before they quietly fail.
---

In 1996, my grandfather passed away. A few years later, I was given a gift that
I could share with the entire family: A cassette tape of him telling his
grandkids one of his own made-up bedtime stories. I was able to turn that into a
digital audio file before it degraded to uselessness, and I still have that file
today. For me, the most amazing part of this is that my daughter got to hear the
voice of her great-grandfather telling that story because I preserved it. But
"still have it" isn't the same as safe. That file has outlived six computers and
multiple hard drive crashes. It will only survive if I keep looking after it.

We all have stuff from our past that matters to us: photos, journals, things
we've written down that we want to make sure we never forget. BrainFrame is part
of my answer to making sure that we keep that data around and readable for the
next 50 years. Considering the way that computing has changed in the last 50, my
goal is incredibly ambitious. It's achievable though, and the techniques I'm
using for BrainFrame apply even if BrainFrame is deleted from the face of the
planet.

Hopefully, you can use the same ideas yourself, so the things you care about can
be handed down to your great-great-grandchildren, and they can still use them
when they get there.

Let's help you get started with giving your great-great-grandchildren this gift.

# First things first!

As with so many things, it is possible to find yourself mired in the details,
and wondering why you ever got started. This post is all about those details,
and it would be very easy to read it, think you must do everything in here
perfectly, and give up before doing anything. Don't do that.

To get started, you need four things:

1. A folder to put stuff in.
2. Something you want to preserve.
3. A way to describe that something, stored right next to it, in plain text.
4. A way to back up (and restore) the things above.

That's it. You have begun making your own digital archive that you can give to
your descendants.

Everything else below is a way to help make sure your descendants can make use
of what you are saving for them. Technology moves quickly; what you save today
may not be readable in 15 or 20 years. Between now and then, you can read the
rest of this post, figure out what you want to do from it, and take the action
when you're ready.

It's okay to take your time. It's okay to be imperfect. What matters, more than
anything else, is getting started, where you are, with what you have. Everything
else is negotiable.

# What to collect?

In recent years, the things to collect have become heavily digital. If you are
fortunate enough to have non-digital originals from your own ancestors, this
article won't be able to help you preserve them; I recommend reaching out to
your local library for help learning how to do so. Instead, this article will
help you preserve digital copies of those originals.

What might be surprising is that you should also maintain an index. It doesn't
have to be as grand as the Dewey decimal system. A simple note about what you've
collected will help you and your descendants out immensely. To use my example
above, the index would name the file, and have a brief description naming the
narrator and describing the contents of the recording.

Your actual collection should be the things you want to be found again in 50
years. Photos of that 75th birthday party, or the first Christmas. Recordings
and videos of family, especially if you can get them to talk about how the world
has changed over the course of their lifetime. Journals, either handwritten or
digital.

To put it differently: the archive you are creating should contain the things
you wish had been recorded and passed down to you. What would you like to know
about your ancestors? About your family tree? About their lives, their thoughts,
their world? Find as much of that as you can, and then save it.

Again, this article won't tell you how to preserve the non-digital artifacts you
are collecting. But for the digital versions, read on.

# Choosing formats

## General guidelines

For storing your data for the next 50 years, the advice really boils down to a
few things:

- Never replace your original. If you must convert to another format, keep your
  original as well. The original may have data that does not get put into the
  converted copy. For example, digital cameras embed information about the lens
  in their files, while several image formats will lose that data entirely.
- Prefer formats that a human can read directly. Text, CSV, and SVG are all
  examples of formats that can be opened in a text editor and read by a human.
  JPEG is not.
- Prefer fewer formats. The day will come when a file must be converted. Having
  fewer formats makes it easier to maintain the archive.
- Store more of the data. This means capturing the data at a higher quality than
  you think you need. You can always make a smaller copy later, but you can't
  reconstruct data that you threw away.
- Use lossless formats. Some formats will throw data away that humans have
  difficulty perceiving. New technology can make use of that data. But, if it's
  gone, it can't be recovered.
- Use generic, well-documented, and established formats. If the format hasn't
  been around for a long time, it can become a victim of disappearing readers.
  For instance, finding something that can read a Paperclip (a popular word
  processor for the Commodore 64) document, in 2026, is extremely challenging.
  If the format isn't documented, or the hardware is difficult to procure, then
  the data will be unusable if the application ever stops supporting it or goes
  away.
- No encryption, no DRM, no passwords. A forgotten password or offline DRM
  server will make your data as useless as if it was stored on a broken hard
  drive.


## Storing text

Above all else, use plain text where possible. This is the one file type that
has survived since the 1960s, and will almost certainly be readable well past
the next 50 years. If your software allows you to specify the encoding, use
UTF-8. Store your index as plain text. To format your text, use something like
[Markdown](https://commonmark.org/). The simplicity of it will help keep it
understandable.

## Storing documents

Many files are not distributed as text. For them, you should use PDF/A. The "A"
stands for archiving. These documents are fully self-contained, including fonts,
to make sure they render exactly as they do for you today.

For other document formats, such as .docx and .odt, keep the original *and*
export a copy to PDF/A. Even though these are openly documented formats, they do
not carry the same durability goals as PDF/A, which could render their current
versions unusable over time.

EPUB is also a good choice, though it does have imperfections for archiving.
EPUB is a .zip archive containing HTML, CSS, font files, etc. The files may not
be precisely rendered in exactly the same way in the future, but the format is
open and well-documented, making it an excellent candidate for being usable in
50 years. However, a special note about EPUB must be mentioned here: Many of
them are encrypted and use DRM. Before relying on it, make sure that your EPUB
does not.

## Storing pictures

Graphics are hard to work with: Should you use GIF, JPEG, PNG, TIFF, or
something else?

If you are scanning something, use TIFF, but with caveats: use baseline TIFF
either without compression, or just using LZW/Deflate compression. This format
has barely been updated since 1992, and is recommended by the Library of
Congress.

Photos are a particularly touchy subject. Something that may surprise you: JPEG
actually throws out data. However, if your only original is a JPEG, then that is what
you should store. Converting it to a different format won't gain you anything,
but will cost storage.

If your photos are stored in a RAW format, keep the RAW and also make a DNG.
This is an openly documented version of the various RAW formats. As digital
photographers can tell you, DNG is not a finished photo: it is sensor data from
the camera that needs to be processed still to make it into a finished image
file. For the actual finished image file, use TIFF.

A special type of graphics file exists known as "vector graphics". Vector
graphics scale cleanly, allowing something from the size of a postage stamp up
to the size of a billboard, all without the jagged edges you have seen when
zooming into a picture too far. For vector graphics, make a copy of them as an
SVG (scalable vector graphics).

If you receive graphics as GIF or PNG, store them directly. They do not need
conversion.

For all other graphics, store a copy of them as PNG. This includes anything else
created on the computer, including screenshots, diagrams, charts, and digital
art.

## Storing video

Almost all of the videos you will make are lossy. Every phone video, most
digital camcorders, and even videos you capture and edit yourself (such as
tutorials) are almost always stored in a .mp4 file using lossy tools. When you
have this, store that as your original. Conversion may be necessary in the
future, but for now, this is the current common format for amateur archivists.

If you are fortunate enough to be turning an analog item into a digital video,
make sure to use the Matroska format (.mkv extension), while using FFV1 to store
the video and FLAC to store the audio. The files will be *much* larger, but you
will capture everything possible from the original.

I will talk more about the digital capture process below.

## Storing audio

As with video, most audio you already have will be lossy. MP3, AAC, and others
all throw away data that we humans have a hard time hearing. If this is your
source material, store it in the original form, and don't convert it until new
formats demand you do so.

If you are capturing an audio recording, you should use tools that capture and
store as FLAC. The resulting file will be larger, but (again) you will capture
everything possible from the original.

For me, I was fortunate enough to capture my grandfather's bedtime stories in
FLAC, which I then made an MP3 copy from and shared that with the family.

Again, I will talk more about the digital capture process below.

# Converting to digital file formats

## Capturing pictures

For pictures, use a scanner with the highest optical DPI settings you can get.
Depending on the original material, you can have a surprising amount of data to
capture and store. For instance, an estimate of the amount of data in a single
35mm negative is up to about 24 megapixels. Notice the "highest optical DPI
settings": Many scanners will offer high resolution, but they do this by
interpolating pixels. This means they add data that isn't actually there,
inflating your image size while giving you nothing extra. Focus on the
non-interpolated settings.

Specific recommendations: For photo prints and printed documents, scan them at
600-1200 DPI (1200 DPI for small prints). For negatives and slides,
scan them at 2400-4000 DPI. The resulting files will be larger, but the
additional data being captured will be worth it to your descendants.

## Capturing videos

The capture process for video is more involved: You want to find hardware that
will send the data to the computer in an uncompressed format, and then have the
software you use do the encoding and storage into MKV/FFV1/FLAC. Blackmagic
capture hardware is frequently used for the capture, while OBS Studio can handle
the encoding.

## Capturing audio

For audio, the process is similar: You want to capture audio at 24-bit, 96kHz.
Similar to video, the audio signal should be uncompressed. The actual conversion
to a digital signal should not be done on your computer, though: The line-in
jack sits next to noisy electronics inside of your computer and can cause
excess noise in your recording. Instead, look for either a USB audio interface
*or* a standalone device that can capture the audio in an uncompressed format
and store it on (for example) an SD card.

The format recommended by the Library of Congress is a WAV file, but I will
recommend FLAC. The support for metadata and compression is standardized and
documented. The compression is lossless, which allows the files to be about half
the size of WAV without throwing anything away. Since the metadata is
standardized, editors, viewers, and players are more uniform in their handling
of it.

# Storage

The computing landscape is littered with dead storage formats, with floppy disks
being the most famous at this point. CD-ROMs, DVD and Blu-ray, Compact Flash,
xD, MMC, LaserDisc, IDE, MFM, RLL, and other (even older) styles and connectors
are all either declining in use or completely gone from modern computers.

Because of this, there is no substitute for manual maintenance. Every year,
re-evaluate where your archive is stored. Copy it to new media formats
regularly. If you keep a network attached storage device (NAS) at home, use it
as another copy.

While this sounds onerous, it is quite likely to be something you start on a
lazy Sunday morning and walk away from until after dinner, even with very large
collections.

# Backups

Backups are the single most important part of your archive. Without them, your
archive will probably be lost, even if you maintain your storage regularly. Even
if you ignore every other piece of advice in this article, do not ignore this.

Storage media dies. SD cards wear out. USB flash drives can gradually lose
charge, causing them to lose the data stored on them (typically this takes
years, but it still happens). Hard disk drives can develop bad sectors. SSD
drives gradually lose cells to write to (and NVMe drives are SSD drives with a
different connector). Tapes physically wear out. To reiterate: Storage media
*dies*.

Your protection for this needs to follow a rule, commonly called "3-2-1": 3
copies of your data on 2 separate storage media with one copy offsite.

That sounds really hard, but it's much simpler than you would expect. You're
already keeping one copy on your computer. Keep another copy on an external hard
drive that you only plug in during the annual refresh or when adding something
important (but make sure to keep that drive unplugged the rest of the time, so
you can rely on it being protected from anything happening on your computer).
Finally, use a tool like [Syncovery](https://www.syncovery.com/features/) to
back up your archive to the cloud. Even multi-terabyte archives can be stored
online for surprisingly little, and that provides extra protection against
something horrible happening to your home.

I'm not endorsing Syncovery; it's one example. Choose a tool that suits you and
your needs, and consider the following criteria:

- Your backups should keep multiple versions of your data. Doing this allows you
  to recover from ransomware encrypting your archive by just restoring an older
  copy. Note that services like Amazon's Simple Storage Service (S3), Google's
  Cloud Storage (GCS), and Backblaze B2 allow you to store older copies of the
  files without having to deal with special applications. The option has to be
  turned on, and it can increase storage costs, but it does provide protection
  against a ransomware attack.
- Does the program *require* you to use it to do a restore? I would avoid these
  sorts of programs. Cloud storage should just look like an extra directory to
  you, allowing you to manually pick and choose what you want to restore. If the
  application stores it in a format that only it can read, then what happens if
  the program stops working on a new operating system, or the company goes out
  of business?
- Would you prefer a graphical application or the command line? Do you prefer a
  browser-based experience?
- Do you have to pay attention to it? Do you *want* to pay attention to it?
  Maybe you would prefer to only do it manually. Maybe you would prefer it to
  happen automatically. Either way, make sure it matches *your* desires.
- Does it fit your budget? Free options exist, as well as paid options. The
  program may require a subscription, or it may be completely free to use. This
  is a *separate* cost from the cost of storing your archive in the cloud.
- Does the application encrypt your data in the cloud? If so, do you have a plan
  to make sure that password is passed on? If not, then the cloud backup dies
  with that password.

> A Word of Caution: Your backups are your only way back in the event of
> disaster, and a disaster can be something much smaller than losing your home.
> What happens if ransomware takes over your computer, scrambling your archive?
> Did you already back up the scrambled copy? Did that cost you all your copies
> of the data you've been trying to protect? When backing up your archive, make
> sure of what you are backing up *before* you do the backup. If you are using
> automatic backups, then versioning is your primary defense against bad
> backups.

# Backup verification

A backup that has never been tested is just a bucket of bits with no value. A
quick Google search will give you hundreds of stories of backups that, when they
were needed, turned out to be faulty, resulting in data loss. In some extreme
cases, the data loss was so severe that the business closed as a result.

Your data might not keep a business afloat, but it does matter for you and your
family. Take the time to verify that the data is all being kept in good
condition, and ready for a restore in the event of a failure.

When you are starting out, you can do this manually. Restore a file to a
different location, and then double-click on it. Can you read it, if it's text
or a document? Can you watch the video? Can you hear the audio? With only a few
files, you can keep everything manual.

When you get to thousands of files, it becomes much more tricky. What you are
trying to establish is that the files haven't changed at all. Professional
archivists call this "fixity", and tools exist to help you manage it. For a
graphical tool, check out [Fixity Pro](https://www.fixitypro.com/). For command
line tools, look at [rclone](https://rclone.org/). These tools will help you
manage your archive when it is too large to do manually.

# Restore some files

At least once a year, grab some files out of your backup and make sure you can
use them as you expected: text files and documents are readable, pictures are
viewable, videos are watchable, audio files are listenable.

If you don't make sure you can restore, you really are just storing a bunch of
random bits. Don't find out that your backup is worthless when you most need it.

# Tell people

If you don't tell people that you have this information, then they are unlikely
to find it. Talk about the information you have, and share it with them when you
can. Show them that this exists, and make sure they know how to get at it.

They might even make a copy of the data from you, and even want to keep their
copy updated with what you add. That's yet another backup, so take advantage of
it!

# Is that all?

The job title of "Professional Archivist" exists, and they do *much* more than
I'm listing here. How to organize a collection, evaluating new formats for data
preservation, making copies in the new formats when needed, the list goes on and
on.

This post is just a peek into their world. For you, take your time and enjoy
your archive. There's no telling what you'll find, and what you'll share, and
what you'll give to your own descendants. Make it something special to you, and
your descendants will treasure it as well.

Now, I'm getting back to work on BrainFrame. This tool is focused on helping you
preserve your knowledge for the next 50 years. I focus on using the advice I've
given here to make BrainFrame do exactly that.

And if I do things very well, perhaps my daughter's great-grandchildren can hear
that same bedtime story. I don't know that I can provide a better gift.

If you'd like to talk with me some more, I'm available on Mastodon as
[@pedersen@c.im](https://c.im/@pedersen). I hope to hear from you soon!
