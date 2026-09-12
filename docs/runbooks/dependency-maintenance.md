# Dependency Maintenance Runbook

How to live with the Renovate + scheduled-scan setup. Shared preset: [`default.json`](../../default.json).

## Cadence

Mondays before 6am UTC, Renovate opens dependency-update PRs across every repo that extends `github>shawnyeager/shared-workflows`. Vulnerability advisories bypass the schedule and open PRs immediately. The same Monday cron also runs `secrets-scan` plus `npm audit` / `govulncheck` in each repo's `.github/workflows/security.yml`.

Review window: Monday → Wednesday.

The shared preset does **not** open a Dependency Dashboard issue and does **not** run `lockFileMaintenance`. Pending work is the open Renovate PRs in each repo.

## PR triage decision tree

For each Renovate PR:

1. **CI green?**
   - Yes → continue.
   - No → read the failure. Lockfile drift, peer-dep conflicts, and real regressions look the same at first; the diff tells you which.
2. **Severity?**
   - Vulnerability fix → review and merge same-day. These bypass the weekly cadence for a reason.
   - Patch / minor update → scan the diff, merge.
3. **Build risk?** Frontend repos (`gtm-map`, `shawnyeager-com`, `shawnyeager-share`) have Vercel or Netlify deploy previews. Click through, smoke-test, then merge.
4. **Major bump opened anyway?** Should not happen — the shared preset disables majors globally. If one shows up, that is a config bug. Close the PR, fix `default.json`.

## Inspecting a PR locally

```bash
gh pr checkout <PR_NUMBER>     # checkout the Renovate branch
npm ci                          # or: hugo --minify, depending on repo
npm test                        # if applicable
```

## Major-version-required-for-fix scenarios

The preset sets `major: { enabled: false }`, so Renovate will not open a major-bump PR even when a vulnerability fix needs one.

Response: plan the major bump on its own. Do not flip `major: { enabled: true }` workspace-wide for one case.

When an in-range fix is blocked by a parent pin, use an `overrides` entry. See [`dependency-audit.md`](./dependency-audit.md).

## Repo coverage

| Repo | Renovate config | Security workflow |
|------|-----------------|-------------------|
| `gtm-map` | `renovate.json` (next-react, lint, test, tailwind groups) | `.github/workflows/security.yml` (secrets + npm audit) |
| `shawnyeager-com` | `renovate.json` (excludes tangerine-theme gomod) | secrets (verified only) + npm audit + govulncheck |
| `shawnyeager-share` | `renovate.json` (excludes tangerine-theme gomod and Go toolchain) | secrets + npm audit + govulncheck |
| `tangerine-theme` | `renovate.json` (base only) | secrets-scan only |
| `doc-templates` | `renovate.json` (base only) | secrets-scan only |
| `shared-workflows` | `renovate.json` + `default.json` (the shared preset) | none (workflow repo) |
| `newsletter` | `renovate.json` extends `config:recommended` (not the shared preset) | none |

## Known pins

- **`gtm-map`** — `overrides` for `sharp` (`^0.35.4`) and `postcss` in `package.json`. Remove each override when the parent range includes the patched version.
- **`shawnyeager-com`** — `light-bolt11-decoder` in the V4V stack. A fix that needs a major Lightning rewrite stays out of weekly Renovate.

## When Mend Renovate breaks

If the hosted Mend Renovate App becomes unavailable, paywalled, or rate-limits the workspace:

1. Add a runner workflow here:

   ```yaml
   # .github/workflows/renovate.yml
   name: Renovate
   on:
     schedule:
       - cron: '0 5 * * 1'   # 5am UTC Monday
     workflow_dispatch:
   jobs:
     renovate:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: renovatebot/github-action@v40
           with:
             configurationFile: default.json
             token: ${{ secrets.RENOVATE_PAT }}
   ```

   Provision a fine-grained PAT with read+write on the target repos and store it as `RENOVATE_PAT`. `default.json` and per-repo `renovate.json` files stay the same — only the runner moves.

2. Renovate caches presets for about an hour. For an urgent preset change, trigger Renovate from the Mend dashboard.

## Cross-references

- Audit playbook (one-off scans): [`dependency-audit.md`](./dependency-audit.md)
- Shared preset: [`default.json`](../../default.json)
- Existing security workflow precedent: `gtm-map/.github/workflows/security.yml`
- Renovate config docs: <https://docs.renovatebot.com/configuration-options/>
