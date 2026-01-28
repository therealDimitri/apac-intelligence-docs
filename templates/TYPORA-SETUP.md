---
title: "Typora PDF Export Setup Guide"
subtitle: "Altera-Branded PDF Output via Pandoc + LaTeX"
author: "APAC Client Success Team"
date: "January 2026"
cover-page: false
confidential: false
---

# Typora PDF Export Setup Guide

This guide explains how to set up Typora to export Markdown documents as professionally branded PDFs with Altera Digital Health styling.

## Prerequisites

- macOS (tested on macOS Sequoia)
- [Homebrew](https://brew.sh/) package manager
- [Typora](https://typora.io/) (licensed)

## Step 1: Install Pandoc

Pandoc converts Markdown to PDF via LaTeX.

```bash
brew install pandoc
```

Verify: `pandoc --version` should show version 3.x or later.

## Step 2: Install TinyTeX

TinyTeX is a lightweight LaTeX distribution (~90MB vs ~4GB for full TeX Live).

```bash
curl -sL "https://yihui.org/tinytex/install-bin-unix.sh" | sh
```

Then install the required LaTeX packages:

```bash
~/Library/TinyTeX/bin/universal-darwin/tlmgr install \
  fancyhdr graphicx xcolor geometry fontspec titlesec \
  hyperref booktabs lastpage etoolbox float caption \
  parskip enumitem
```

**Note:** If the install script asks for sudo, you can skip the symlink step. XeLaTeX will still work from its full path.

Verify: `~/Library/TinyTeX/bin/universal-darwin/xelatex --version` should show XeTeX.

## Step 3: Install Inter Font

```bash
brew install --cask font-inter
```

This installs the Inter font family to `~/Library/Fonts/`.

## Step 4: Install Template Files

Three files need to be in place:

### LaTeX Template

Copy `altera.latex` to your Pandoc templates directory:

```bash
mkdir -p ~/.pandoc/templates
# Copy altera.latex to ~/.pandoc/templates/
```

### Logo File

Copy `altera-logo.pdf` to the same directory:

```bash
# Copy altera-logo.pdf to ~/.pandoc/templates/
```

Both files are available from the team's shared drive or from a colleague who has completed this setup.

### Typora Theme (Optional)

For matching live preview in Typora, copy `altera.css` to:

```bash
# macOS Typora themes directory:
~/Library/Application Support/abnerworks.Typora/themes/altera.css
```

Then in Typora, go to **Themes** menu and select **Altera**.

## Step 5: Configure Typora Export

1. Open Typora → **Preferences** → **Export**
2. Click **+** to add a new export format
3. Select **PDF (Pandoc)** (or **Custom** if Pandoc option is unavailable)
4. Configure:
   - **Pandoc Path**: `/opt/homebrew/bin/pandoc` (or run `which pandoc` to find yours)
   - **Extra Arguments**:
     ```
     --pdf-engine=/Users/YOUR_USERNAME/Library/TinyTeX/bin/universal-darwin/xelatex
     --template=altera
     -V geometry:a4paper
     -V geometry:margin=2.5cm
     --highlight-style=tango
     ```
   - Replace `YOUR_USERNAME` with your macOS username

5. Click **Save**

## Usage

### YAML Front Matter

Add this block at the very top of your Markdown document:

```yaml
---
title: "Your Document Title"
subtitle: "Optional Subtitle"
author: "Your Name"
date: "January 2026"
cover-page: true          # true = branded cover page, false = inline title
confidential: false       # true = adds "Confidential" to footer
toc: false                # true = adds table of contents after cover
---
```

### Exporting

1. Write your document in Typora (use the **Altera** theme for matching preview)
2. Go to **File** → **Export** → **PDF (Pandoc)**
3. Choose output location
4. Done — branded PDF is generated

### What You Get

- **Cover page** with Altera logo, title, subtitle, author, and date
- **Header** on every page: Altera logo (left) + document title (right)
- **Footer**: Page X of Y (centre) + optional "Confidential" label (right)
- **Blue headings** using Altera brand colour (#2563EB)
- **Inter font** throughout
- **Blue-themed tables** with branded header row
- **Syntax-highlighted code blocks** with grey background

## Troubleshooting

### "xelatex not found"

Ensure the full path to xelatex is in the Pandoc arguments:
```
--pdf-engine=/Users/YOUR_USERNAME/Library/TinyTeX/bin/universal-darwin/xelatex
```

### Missing LaTeX packages

If you see `! LaTeX Error: File 'xyz.sty' not found`, install the missing package:
```bash
~/Library/TinyTeX/bin/universal-darwin/tlmgr install xyz
```

### Font not found

Ensure Inter is installed: `fc-list | grep -i inter`. If empty, reinstall:
```bash
brew install --cask font-inter
```

### Logo not appearing

Ensure `altera-logo.pdf` is in `~/.pandoc/templates/`. The template looks for it by the name `altera-logo` (without extension).
