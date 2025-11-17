# Shared GitHub Actions Workflows

Reusable GitHub Actions workflows for Hugo sites (shawnyeager.com and notes.shawnyeager.com).

## Workflows

### Content Quality Workflows

These workflows validate content before/after commits.

#### hugo-link-checker.yml
Checks for broken links in markdown files using lychee.

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/**/*.md`

#### hugo-markdown-linter.yml
Lints markdown files and checks for:
- Obsidian wikilinks (`[[...]]`)
- Hardcoded smart punctuation (curly quotes, em/en dashes, ellipsis)
- Markdown formatting issues

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/`

#### hugo-content-validator.yml
Validates frontmatter in Hugo content files.

**Inputs:**
- `content_path` (optional): Path to content directory. Default: `content/essays`
- `content_type` (optional): Type of content (essays or notes). Default: `essays`
- `require_description` (optional): Whether description field is required. Default: `true`

#### hugo-module-validator.yml
Validates Hugo Module dependencies to prevent broken Netlify builds.

**Inputs:**
- None (validates go.mod contains required theme dependency)

### Theme Auto-Update Workflows

These workflows automate theme updates across both sites when the theme is pushed.

#### tangerine-theme: notify-sites.yml
Triggers when theme is pushed to master. Sends `repository_dispatch` events to both site repos.

**Workflow location:** `tangerine-theme/.github/workflows/notify-sites.yml`

**Triggers on:**
- Push to `master` branch
- Changes to `layouts/**`, `static/**`, or `theme.toml`

**Sends events to:**
- `shawnyeager/shawnyeager-com` (event-type: `theme-updated`)
- `shawnyeager/shawnyeager-notes` (event-type: `theme-updated`)

**Required secrets:**
- `SITES_UPDATE_TOKEN` - GitHub PAT with repo access

#### shawnyeager-com/shawnyeager-notes: auto-theme-update.yml
Listens for theme update events and automatically updates go.mod with latest theme version.

**Workflow location:** Both `.github/workflows/auto-theme-update.yml` in each site repo

**Triggers on:**
- `repository_dispatch` event-type: `theme-updated`
- Manual trigger via `workflow_dispatch`

**Actions:**
1. Runs `hugo mod get github.com/shawnyeager/tangerine-theme@master`
2. Removes any accidental replace directives (safety net)
3. Normalizes go.mod version format
4. Checks for go.mod changes
5. Auto-commits if changes detected: `"chore: auto-update tangerine-theme module"`
6. Pushes to master (triggers Netlify deployment)

**Required secrets:**
- `SITES_UPDATE_TOKEN` - GitHub PAT for triggering workflows across repos

**Required permissions:**
- `contents: write` (to commit and push)

**Result:** Theme updates are now a 2-step process (down from 9 manual steps):
1. Edit theme and test locally
2. Commit and push theme to master → sites auto-update via GitHub Actions

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
