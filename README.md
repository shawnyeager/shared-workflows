# Shared GitHub Actions Workflows

Reusable GitHub Actions workflows for Hugo sites (shawnyeager.com).

## Workflows

### Content Quality (Consolidated)

#### complete-content-quality.yml

**Primary workflow.** Runs all content quality checks in a single job to minimize GitHub Actions minutes.

**Checks included:**
- Link validation (lychee)
- Markdown linting
- Obsidian wikilink detection
- Smart punctuation detection
- Frontmatter validation
- Hugo module validation
- Image alt text validation

**Inputs:**
- `site_type` (required): `"essays"` or `"notes"` - determines content path and validation rules

**Usage:**
```yaml
name: Content Quality

on:
  push:
    branches: [master]
    paths:
      - 'content/**/*.md'
      - '*.md'
      - 'go.mod'
      - 'go.sum'
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Mondays
  workflow_dispatch:

jobs:
  quality-check:
    uses: shawnyeager/shared-workflows/.github/workflows/complete-content-quality.yml@master
    permissions:
      contents: read
      issues: write
    secrets: inherit
    with:
      site_type: 'essays'  # or 'notes'
```

**Note:** Sites run this on master push only (not PRs) to save Actions minutes.

### Config Consistency

#### config-consistency.yml

Validates Go version alignment between `go.mod` and `netlify.toml`, and verifies the theme `require` statement exists in `go.mod`.

### Theme Update PR (Manual Use)

#### theme-update-pr.yml

Reusable workflow for creating theme update PRs. Not called by any cron --- theme PRs are created manually. Available via `workflow_dispatch` if needed as a one-off.

## Maintenance

Used by:
- [shawnyeager.com](https://github.com/shawnyeager/shawnyeager-com)

Update once, benefit everywhere.
