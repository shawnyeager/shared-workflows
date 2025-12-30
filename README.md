# Shared GitHub Actions Workflows

Reusable GitHub Actions workflows for Hugo sites (shawnyeager.com and notes.shawnyeager.com).

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

### Individual Workflows (Available)

These standalone workflows are still available if needed for specific use cases:

| Workflow | Purpose |
|----------|---------|
| `hugo-link-checker.yml` | Broken link detection |
| `hugo-markdown-linter.yml` | Markdown linting + wikilink/punctuation checks |
| `hugo-content-validator.yml` | Frontmatter validation |
| `hugo-module-validator.yml` | go.mod theme dependency check |
| `hugo-image-validator.yml` | Image alt text validation |

### Theme Auto-Update (PR-Based)

#### auto-theme-update-pr.yml

Creates PRs when theme updates are available. Located in each site repo (not here).

**Triggers:**
- Automatically when theme repo pushes to master (via repository dispatch)
- Daily cron at 9am UTC (fallback)
- Manual trigger via `workflow_dispatch`

**Flow:**
1. Push theme changes to master
2. Theme repo triggers site workflows automatically (~3 min)
3. PRs created with `theme-update` label
4. Netlify builds FREE deploy preview
5. Review preview, merge when ready
6. Production build on merge (15 credits)

**Cost savings:** Deploy previews are free. Only pay for production builds.

## Maintenance

Used by:
- [shawnyeager.com](https://github.com/shawnyeager/shawnyeager-com)
- [notes.shawnyeager.com](https://github.com/shawnyeager/shawnyeager-notes)

Update once, benefit everywhere.
