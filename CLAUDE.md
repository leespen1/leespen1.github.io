# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal academic website for Spencer Lee, built with **Franklin.jl** (a Julia-based static site generator). Hosted on GitHub Pages at https://leespen1.github.io/.

## Build & Deploy

**Local development server:**
```bash
julia -e 'using Franklin; serve()'
```

**Build and deploy to GitHub Pages (gh-pages branch):**
```bash
bash deploy_website.sh
```
This runs `julia -e 'using Franklin; verify_links(); optimize(); verify_links()'`, builds to `__site/`, then force-pushes to the `gh-pages` branch.

**Install dependencies (first time):**
```bash
julia -e 'using Pkg; Pkg.instantiate()'
```

## Architecture

- **Franklin.jl** processes Markdown files with TOML front matter (`+++ ... +++`) into static HTML
- **config.md** — Global site configuration (author, RSS settings, LaTeX macros)
- **utils.jl** — Custom Julia functions callable from Markdown via `{{functionname}}`. Key function: `hfun_blogposts()` auto-generates the blog post list sorted by date
- **_layout/** — HTML templates (head, footer, sidebar navigation)
- **_css/** — Stylesheets (Pure.css framework + Franklin/sidebar styles)
- **_libs/** — Third-party JS: KaTeX (math rendering), highlight.js (code syntax)
- **__site/** — Generated output directory (gitignored)

## Blog Posts

Blog posts live in `BlogPosts/` as Markdown files with required front matter:
```toml
+++
title = "Post Title"
date = Date(YYYY, MM, DD)
tags = ["tag1", "tag2"]
+++
```

The blog index (`BlogPosts/index.md`) uses `{{blogposts}}` to call `hfun_blogposts()` in `utils.jl`, which auto-discovers and lists all posts sorted by date (newest first). Adding a new `.md` file to `BlogPosts/` with proper front matter is all that's needed.

## Equation Numbering

Do **not** use KaTeX `\tag{n}` for equation numbers — on wide equations the tag renders inside the equation box and overlaps with the content. Instead, use the `\eqnumber{...}` Franklin command (defined in `config.md`) to wrap the `$$...$$` block. This applies a CSS counter via `.numbered-eq .katex-display::after` in `_css/franklin.css`, which positions the number outside the equation with `float: right`.

- **Numbered equation:** `\eqnumber{$$x = y$$}` — gets a sequential CSS counter number.
- **Unnumbered equation:** plain `$$x = y$$` — no number.
- Numbers are sequential across all `\eqnumber` uses on a page, so text references like "in (3)" must match the order of `\eqnumber` appearances.

## Sidenotes & Firefox Reader View

Sidenotes use Tufte-style CSS (superscript number, margin float). In Firefox Reader View, CSS is stripped, which causes sidenote text to concatenate with surrounding text. The fix: wrap sidenote content with `<span class="sidenote-delimiter"> [</span>` and `<span class="sidenote-delimiter">] </span>` delimiters (defined in `config.md` macros). These are hidden via `display: none` in `_css/franklin.css` during normal rendering, but become visible as `[bracketed text]` in Reader View, keeping sidenotes separated from body text. Do not use `<aside>` for sidenotes — it is block-level and breaks paragraph flow.
