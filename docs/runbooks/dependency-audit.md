# Dependency Audit Playbook

How to scan workspace repos for known vulnerabilities and outdated packages. Companion to the Renovate setup in `default.json`. Use this for one-time sweeps, post-upgrade checks, or when you want to cross-check what Renovate reports.

## Preconditions

```bash
gh auth status                # must be authenticated for `gh api` calls
go install golang.org/x/vuln/cmd/govulncheck@latest   # one-time; not on PATH by default
command -v govulncheck        # confirm install succeeded
```

`npm` comes from `mise`. No other installs required.

## Per-ecosystem commands

### npm projects

```bash
# Production-severity gate (matches CI in .github/workflows/security.yml)
npm audit --omit=dev --audit-level=high

# Full report including dev deps and lower severities — for triage
npm audit --json | jq '.vulnerabilities | to_entries | map({name: .key, severity: .value.severity, via: .value.via, fixAvailable: .value.fixAvailable})'

# What's outdated within current semver range (caret/tilde permits)
npm outdated --depth 0
```

Run from each repo root: `gtm-map`, `shawnyeager-com`, `shawnyeager-share`, `doc-templates`.

### Go modules (Hugo sites)

```bash
# Call-graph-aware vuln scan — only flags vulns reachable from your code
govulncheck ./...

# Module update preview (patch-level only; minor/major are out of scope)
go list -u -m all
```

Run from `shawnyeager-com` and `shawnyeager-share`. `tangerine-theme` has no transitive deps (no `go.sum`); skip it.

### GitHub-side advisories (cross-check)

```bash
gh api repos/shawnyeager/<repo>/dependabot/alerts --jq '.[] | {number, state, severity: .security_advisory.severity, package: .security_vulnerability.package.name}'
```

Useful when local `npm audit` and the GitHub Security tab disagree (for example a stale lockfile after a server-side deprecation).

## Severity threshold convention

| Threshold | Use when |
|-----------|----------|
| `--audit-level=high` | CI gate. Medium/low do not break the build. Matches `gtm-map/.github/workflows/security.yml`. |
| Full report (no threshold) | Triage. Read everything. Accept or queue a fix. |

Remediation posture:

- Fix all critical/high. Escalate to the user only when the fix forces a major bump.
- Triage medium/low. Fix when easy; document acceptance otherwise.
- Never use `npm audit fix --force` — it crosses major-version boundaries silently.
- For Go: `go get <module>@<safe-version>` then `go mod tidy`. Never `go get -u` (takes minor across all modules).

## npm overrides (when an in-range fix is blocked)

`npm audit fix` cannot reach a patched version when a parent pins a narrower range. Add an `overrides` entry instead of `--force`:

```json
"overrides": {
  "sharp": "^0.35.4"
}
```

Confirm the override does not downgrade a major. Re-run lint and build after the lockfile change. Remove the override once the parent range includes the patched version. `gtm-map/package.json` holds the current `sharp` and `postcss` examples.

Escalation ladder:

1. `npm ls <pkg> --all` — is the package production or dev-only?
2. `npm audit fix --dry-run` — will a plain fix stay in range?
3. `npm audit fix` — apply in-range fixes.
4. `overrides` — only when the patched version sits outside a parent's declared range.

## Repo coverage matrix

| Repo | npm audit | govulncheck | gh dependabot/alerts |
|------|-----------|-------------|----------------------|
| `gtm-map` | ✓ | — | ✓ |
| `shawnyeager-com` | ✓ | ✓ | ✓ |
| `shawnyeager-share` | ✓ | ✓ | ✓ |
| `doc-templates` | ✓ | — | ✓ |
| `tangerine-theme` | — | — | ✓ (actions only) |
| `shared-workflows` | — | — | ✓ (actions only) |
| `newsletter` | — | — | — (Python scripts, no npm/Go manifests) |

## Cross-reference

- Renovate config (shared preset): `shared-workflows/default.json`
- Per-repo Renovate configs: `<repo>/renovate.json`
- Scheduled scan workflows: `<repo>/.github/workflows/security.yml`
- Maintenance cadence and PR triage: [`dependency-maintenance.md`](./dependency-maintenance.md)
