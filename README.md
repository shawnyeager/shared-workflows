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

### Theme Auto-Update Workflows (PR-Based)

Both sites use a **PR-based workflow** for theme updates to save Netlify credits and enable preview review.

#### auto-theme-update-pr.yml
Creates a Pull Request when theme updates are available, allowing preview review before production deploy.

**Workflow location:** `.github/workflows/auto-theme-update-pr.yml` in each site repo

**Triggers on:**
- Manual trigger via `workflow_dispatch` (preferred)
- Daily cron at 9am UTC (fallback)

**Actions:**
1. Checks current theme version in `go.mod`
2. Runs `hugo mod get -u github.com/shawnyeager/tangerine-theme`
3. If updated, creates Pull Request with `theme-update` label
4. Netlify builds FREE deploy preview for the PR
5. Review preview, merge when satisfied
6. Production build only happens on merge (15 credits)

**Required secrets:**
- `GH_PAT` - GitHub PAT with `contents:write` and `pull-requests:write`

**Required permissions:**
- `contents: write` (to commit go.mod changes)
- `pull-requests: write` (to create PR)

**Workflow for theme updates:**
1. Push theme changes to master branch
2. Trigger workflow manually: `gh workflow run auto-theme-update-pr.yml --repo shawnyeager/shawnyeager-com`
3. Wait for PR to be created (~2 min)
4. Review deploy preview URL in PR
5. Merge when satisfied → triggers production build

**Cost savings:**
- Deploy previews: FREE (0 credits)
- Multiple theme commits can accumulate in one PR
- Only pay for final production build (15 credits per site)

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
