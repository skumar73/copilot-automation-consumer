# Key Vault Consumer (Example)

Reference downstream repository that **consumes** the org-standard
`keyvault-shared` Bicep module published by
[`agentic-automation-producer`](../agentic-automation-producer) into the
private Azure Container Registry.

This repo is intentionally **thin**: every consumer carries the same five
files plus two ~10-line caller workflows. All real logic lives in reusable
workflows in the producer repo, so platform-team updates land in every
consumer simultaneously.

## How it works

```
producer repo                       this repo (and N siblings)
─────────────                       ──────────────────────────
modules/keyvault.bicep   ──publish──►  br:<acr>/keyvault-shared:<ver>
                                              │
                                              ▼
                                          main.bicep
                                              │
                                              ▼
                                       Azure deployment
```

## Layout

```
.
├── bicepconfig.json                ← aliases the private ACR
├── main.bicep                      ← pins keyvault-shared:<ver>
├── parameters/main.bicepparam      ← env-specific input
├── .github/
│   ├── CODEOWNERS                  ← platform team owns the pin line
│   └── workflows/
│       ├── deploy.yml              ← 3-line caller → producer's consumer-deploy.yml
│       └── module-update-check.yml ← 3-line caller (Renovate fallback)
└── README.md
```

## Onboarding a new consumer

1. Create from the `org/consumer-template` repo (or copy these five files).
2. Configure repo **secrets**: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
   `AZURE_SUBSCRIPTION_ID`, optional `TEAMS_WEBHOOK_URL`.
3. Configure repo **variables**: `ACR_NAME`, `RESOURCE_GROUP`, `LOCATION`.
4. On the deployer identity, add a federated credential scoped to this
   repo's `main` branch and `pull_request` events.
5. Grant the deployer identity `AcrPull` on the producer ACR.
6. Edit `main.bicep` and `parameters/main.bicepparam` for your app.
7. Open a PR → what-if runs. Merge to `main` → first deploy.

## Pinning

The module version is pinned in [`main.bicep`](./main.bicep). Bumping is
handled by **Renovate** (preferred — config lives at the org level in
`<org>/.github/renovate.json`). For orgs without Renovate, the
[`module-update-check`](./.github/workflows/module-update-check.yml) caller
runs a daily ACR poll and opens a PR.

## Required secrets / variables

| Name | Type | Purpose |
| ---- | ---- | ------- |
| `AZURE_CLIENT_ID` | secret | OIDC federated identity (deployer) |
| `AZURE_TENANT_ID` | secret | Tenant |
| `AZURE_SUBSCRIPTION_ID` | secret | Target subscription |
| `TEAMS_WEBHOOK_URL` | secret (optional) | App-team channel for deploy pings |
| `ACR_NAME` | repo variable | Shared module registry (e.g. `adusasharedmodules`) |
| `RESOURCE_GROUP` | repo variable | Target RG |
| `LOCATION` | repo variable | Region |
