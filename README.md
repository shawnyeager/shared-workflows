# Shared GitHub Actions Workflows

Reusable GitHub Actions workflows for Hugo sites (shawnyeager.com and notes.shawnyeager.com).

## Workflows

### hugo-link-checker.yml
Checks for broken links in markdown files using lychee.

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/**/*.md`

### hugo-markdown-linter.yml
Lints markdown files and checks for:
- Obsidian wikilinks (`[[...]]`)
- Hardcoded smart punctuation (curly quotes, em/en dashes, ellipsis)
- Markdown formatting issues

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/`

### hugo-content-validator.yml
Validates frontmatter in Hugo content files.

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/essays`
- `content_type` (optional): Type of content (essays or notes). Default: `essays`
- `require_description` (optional): Whether description field is required. Default: `true`

## Usage

In your repository's workflow file:

```yaml
name: Content Quality

on:
  pull_request:
    paths:
      - 'content/**/*.md'
  push:
    branches:
      - master
    paths:
      - 'content/**/*.md'

jobs:
  link-check:
    uses: shawnyeager/shared-workflows/.github/workflows/hugo-link-checker.yml@main

  markdown-lint:
    uses: shawnyeager/shared-workflows/.github/workflows/hugo-markdown-linter.yml@main

  content-validator:
    uses: shawnyeager/shared-workflows/.github/workflows/hugo-content-validator.yml@main
    with:
      content_path: 'content/essays'
      content_type: 'essays'
      require_description: true
```

## Maintenance

These workflows are used by:
- [shawnyeager.com](https://github.com/shawnyeager/shawnyeager-com)
- [notes.shawnyeager.com](https://github.com/shawnyeager/shawnyeager-notes)

Update once, benefit everywhere.
