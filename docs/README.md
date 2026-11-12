# brainframe.tech

The static marketing site for BrainFrame, built with [Jekyll](https://jekyllrb.com/).

The site source lives in this `docs/` folder. On every push to `main`, the
GitHub Actions workflow in `.github/workflows/pages.yml` builds it with the
Jekyll version pinned in `Gemfile.lock` and deploys it to GitHub Pages. Pull
requests run the same build (without deploying), so a broken site shows up as a
failed check before merge.

To upgrade gems, run `bundle update` here and commit the new `Gemfile.lock`.

## Run it locally

```bash
cd docs
bundle install          # first time only
bundle exec jekyll serve # → http://localhost:4000
```

The site rebuilds automatically as you edit — refresh the browser. The one
exception is `_config.yml`: restart the server after changing it.

## Where the words live

Almost all of the landing-page copy is in **`_data/content.yml`**. Edit that
file — hero text, feature cards, philosophy points, the call to action — and the
page updates. No HTML required.

## Layout of the project

```
docs/
  _config.yml          Site-wide settings (title, tagline, URL, plugins)
  _data/content.yml    ← Landing-page copy. Edit this to change the words.
  index.html           Home page. Renders the sections from content.yml.
  blog.html            Blog index (/blog/), lists everything in _posts/.
  about.markdown       /about/ page.
  404.html             Not-found page.
  _posts/              Blog posts (Markdown, one file per post).
  _layouts/            default / page / post — the HTML shells.
  _includes/           header.html, footer.html (shared nav + footer).
  assets/
    css/style.css      The dark + cyan theme.
    img/               brainframe.png (logo) and brainframe-banner.png (hero).
```

## Add a blog post

Create `_posts/YYYY-MM-DD-title.md` with front matter:

```markdown
---
title: "My post title"
date: 2026-01-15 09:00:00 -0500
categories: brainframe
---

Post body in Markdown…
```
