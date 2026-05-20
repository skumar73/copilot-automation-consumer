# Key Vault Consumer (Example)

Example downstream repository that **consumes** the org-standard
`keyvault-shared` Bicep module published by
[`agentic-automation-producer`](../agentic-automation-producer) into the
private Azure Container Registry.

## How it works

```
producer repo                       this repo
─────────────                       ─────────
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
├── main.bicep                      ← uses keyvault-shared
├── parameters/main.bicepparam      ← env-specific input
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml              ← what-if + deploy
│   │   └── module-update-check.yml ← polls producer for new versions
│   └── renovate.json               ← (optional) automated bumps via Renovate
└── README.md
```

## Pinning

The module version is pinned in [`main.bicep`](./main.bicep). Bumping is
handled by Renovate (or `module-update-check.yml`) which opens a PR; CI runs
`bicep build` and a what-if before merge.

## Required secrets / variables

| Name | Type | Purpose |
| ---- | ---- | ------- |
| `AZURE_CLIENT_ID` | secret | OIDC federated identity (deployer) |
| `AZURE_TENANT_ID` | secret | Tenant |
| `AZURE_SUBSCRIPTION_ID` | secret | Target subscription |
| `ACR_NAME` | repo variable | Shared module registry (e.g. `adusasharedmodules`) |
| `RESOURCE_GROUP` | repo variable | Target RG |
| `LOCATION` | repo variable | Region |
