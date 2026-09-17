# Getting started with Sundeck

This repository contains signed and notarized Apple Silicon releases of Sundeck and the Homebrew formula that installs them.

## What you need

- An Apple Silicon Mac running macOS 26 or newer
- Homebrew
- [Apple Container](https://github.com/apple/container)
- An existing Daydream checkout containing your development configuration, secret files, and database snapshot

Do not use Daydream's example configurations or generate replacement secrets. The required private values should already be somewhere in your existing Daydream folder. Tailscale is optional and is not required to start Daydream with Sundeck.

## 1. Install Sundeck

Install Sundeck from its public Homebrew tap:

```sh
brew install tomdai/sundeck/sundeck
```

Check that Apple Container's local DNS domains include `machine`:

```sh
container system dns list
```

If `machine` is absent, add it once with administrator privileges:

```sh
sudo container system dns create machine
```

Apple Container does not need to be running yet. Sundeck starts it when needed.

## 2. Prepare `~/.sundeck`

Sundeck uses `~/.sundeck` as the private, device-wide source for configuration shared by all Daydream worktrees. Create the required structure below; the marked Tailscale branch may be omitted:

```text
.sundeck/
├── sundeck-shared.json
├── database/
│   └── snapshot-YYYYMMDDtHHMMSSz/
│       ├── database.pgdump
│       └── manifest.json
├── tailscale/                              # optional; may be omitted or empty
│   └── connection.secret.json             # required only to use Tailscale
└── workspace/
    ├── .vercel/repo.json
    ├── .vercel/README.txt                 # optional
    ├── Daydream.ArticleGenerator/configuration.development.json
    ├── Daydream.ClientApi/configuration.development.json
    ├── Daydream.DatabaseMigrations/configuration.development.json
    ├── Daydream.Frontend/.env.vercel
    ├── Daydream.GrowthLeadAgent/configuration.development.json
    ├── Daydream.McpModuleHost/configuration.development.json
    ├── Daydream.TestLab/configuration.development.json
    ├── *.secret.json                      # referenced files only
    └── *.secret.pem                       # referenced files only
```

Copy each required `workspace/` file from the same relative path in the existing Daydream checkout. For example:

```text
Daydream/Daydream.ClientApi/configuration.development.json
    → ~/.sundeck/workspace/Daydream.ClientApi/configuration.development.json
```

Copy only the direct-child `*.secret.json` and `*.secret.pem` files referenced by those configurations. Do not copy `.claude`, `.codex`, `AGENTS.override.md`, example configurations, build output, or the rest of the repository.

The root `sundeck-shared.json` file must contain exactly:

```json
{"formatVersion":5}
```

Copy the database snapshot as one complete directory with its matching `database.pgdump` and `manifest.json`. Do not create or edit the manifest by hand.

You may omit the entire `tailscale/` directory or leave it empty. Normal `.machine` development does not require Tailscale credentials.

All directories beneath `~/.sundeck` must be owned by your logged-in user with mode `0700`. All files must be real, single-link files owned by your user with mode `0600`; symlinks are not accepted. If `~/.sundeck` already exists, inspect and preserve it rather than replacing it wholesale.

## 3. Optional: configure Tailscale

Only create `tailscale/connection.secret.json` if you intend to use Tailscale HTTPS or Sundeck's device OAuth callback relay. Use the existing values supplied with your Daydream setup:

```json
{
  "formatVersion": 1,
  "oauthClientSecret": "<existing tskey-client-... value>",
  "tag": "<existing tag:... value>",
  "tailnetDNSName": "<existing ... .ts.net value>"
}
```

Replace every placeholder with its real existing value. Do not invent or rotate credentials during setup.

If you omit this file, `sundeck up` continues to use the default `.machine` HTTP URLs. `sundeck tailscale enable` and `sundeck device oauth-relay enable` will explain that the optional configuration is required for those features.

## 4. Validate the private inputs

Run:

```sh
sundeck device inputs check
```

This checks the layout, ownership, permissions, JSON, referenced secrets, configuration compatibility, and complete database snapshot checksum. It does not start Apple Container or modify a Daydream checkout.

Resolve any reported missing or ambiguous input using the existing Daydream material. Do not substitute an example value just to make validation pass.

## 5. Start Daydream

Run Sundeck from the existing Daydream checkout:

```sh
cd /absolute/path/to/Daydream
sundeck up
```

The first run can be slower because Apple Container may install its recommended VM kernel and Sundeck must prepare the complete environment. A successful run prints the Frontend, Client API, and MCP URLs.

If you use Codex, install Sundeck's repository integration once and identify agent-started Frontend processes:

```sh
sundeck codex install
AI_AGENT=codex sundeck up
```

Other AI agents can skip `sundeck codex install` and use their own short identifier in `AI_AGENT`.

## Prompt for an AI agent

Replace the checkout placeholder, then give this prompt to an agent with terminal access to the Mac:

```text
Set up Sundeck for the existing Daydream checkout at <ABSOLUTE_PATH>.

Install Sundeck with `brew install tomdai/sundeck/sundeck` if it is not already installed. Verify that Apple Container is installed and that `container system dns list` includes `machine`; if adding that DNS domain requires administrator approval, ask me.

Build `~/.sundeck` only from configuration, secret, and database snapshot material already present somewhere inside the Daydream checkout. Preserve each required workspace file's relative path. Copy only secret files referenced by the real development configurations. Use real copies, not symlinks. Apply mode 0700 to directories and 0600 to files.

Treat Tailscale as optional. Do not block setup if `tailscale/connection.secret.json` or its values are absent; omit the directory or leave it empty and continue with `.machine` development. Configure Tailscale only if complete existing values are available and I explicitly ask to use it.

Do not print secret contents, use example configurations, invent or rotate credentials, construct a database manifest, replace an existing `~/.sundeck` wholesale, or commit private files. If any required non-Tailscale item is missing or more than one candidate is plausible, stop and report the exact expected path or field.

Run `sundeck device inputs check`. Only after it passes, run `sundeck codex install` and `AI_AGENT=codex sundeck up` from the Daydream checkout. Report the validation result and the URLs printed by the successful run.
```

## Upgrade Sundeck

```sh
brew update
brew upgrade sundeck
```

Each formula revision names an immutable GitHub release archive and verifies its SHA-256 before Homebrew installs the `sundeck` executable.

Sundeck 0.9.1 follows Daydream's `frontendBaseUrls` configuration format. In each `configuration.development.json` under `~/.sundeck/workspace/Daydream.ClientApi`, `Daydream.GrowthLeadAgent`, and `Daydream.McpModuleHost`, rename `frontendBaseUrl` to `frontendBaseUrls` and wrap its existing string value in an array. Preserve the other fields and private file permissions. Then run `sundeck up` in each affected worktree to publish the updated configuration. Sundeck replaces this array with the worktree's single selected development origin.
