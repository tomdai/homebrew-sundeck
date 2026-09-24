# Getting started with Sundeck

This repository contains signed and notarized Apple Silicon releases of Sundeck and the Homebrew formula that installs them.

## What you need

- An Apple Silicon Mac running macOS 26 or newer
- Homebrew
- [Apple Container](https://github.com/apple/container)
- A Daydream checkout and the team's development configuration and secret files
- A prepared development database snapshot, or the team's production read access to create one with `sundeck database pull`

Use the real development configuration and secrets supplied by your team, which may already be in your existing Daydream folder. Ask your team for missing private inputs; example configurations are not substitutes. Tailscale is optional and is not required to start Daydream with Sundeck.

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
│   └── <snapshot-name>/                   # copy or pull a snapshot in step 3
│       ├── manifest.json
│       └── ...                            # keep every file in the snapshot
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

Leave `database/` ready for the snapshot selected in the next step. Preserve any snapshots and default selection already there.

You may omit the entire `tailscale/` directory or leave it empty. Normal `.machine` development does not require Tailscale credentials.

All directories beneath `~/.sundeck` must be owned by your logged-in user with mode `0700`. All files must be real, single-link files owned by your user with mode `0600`; symlinks are not accepted. If `~/.sundeck` already exists, inspect and preserve it rather than replacing it wholesale.

## 3. Choose a database snapshot

If your team supplied a development snapshot, copy its complete directory into `~/.sundeck/database/`, keeping its original directory name and every file. Existing snapshots with `database.pgdump` and `manifest.json` remain supported. New Sunbeam snapshots contain a manifest, schema SQL and compressed table files. Do not construct or edit a manifest, or convert either format by hand.

To create a snapshot from production instead, install the optional host tools and authenticate:

```sh
brew install --cask gcloud-cli
brew install cloud-sql-proxy libpq
gcloud auth login --update-adc
sundeck database organizations
```

Your Google account needs the team's existing Cloud SQL and database read access. Authentication alone does not grant it; ask your team for access or a prepared snapshot if the connection is refused. Sundeck starts and stops Cloud SQL Proxy for each pull, so there is no proxy process to manage yourself.

Choose an organization UUID from the list and replace `<organization-uuid>` below:

```sh
sundeck database pull --organization <organization-uuid> --name customer
```

`pull` saves a new snapshot without changing a VM or production. Repeat `--organization` to select several organizations, or use `--all` to include every organization. Omit `--name` for an automatic timestamp name. Large organizations can take time and disk space; AI usage and billing rows are excluded. Imported integrations are disconnected and existing agent invocations are retired. Snapshots retain private business content and belong in `~/.sundeck`, never in Git.

List saved snapshots and choose the one new VMs should use:

```sh
sundeck database snapshots
sundeck database default customer
```

For a copied snapshot, use its existing name instead of `customer`. A single saved snapshot is selected automatically; with several snapshots, the list marks the default with `*`. New pulls preserve an existing default; changing the default does not change any VM. No VM needs to be running for these commands. First startup restores the default into an absent or empty database.

If a pull says Sundeck needs an update because production's schema changed, upgrade Sundeck and retry. If the latest release still reports it, share the table or column names with the Sundeck maintainer; do not bypass the check.

## 4. Optional: configure Tailscale

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

## 5. Validate the private inputs

Run:

```sh
sundeck device inputs check
```

This checks the layout, ownership, permissions, JSON, referenced secrets, configuration compatibility, and all file checksums in the default snapshot. It does not start Apple Container or modify a Daydream checkout.

Resolve any reported missing or ambiguous input using the existing Daydream material. Do not substitute an example value just to make validation pass.

## 6. Start Daydream

Run Sundeck from the existing Daydream checkout:

```sh
cd /absolute/path/to/Daydream
sundeck up
```

The first run can be slower because Apple Container may install its recommended VM kernel and Sundeck must prepare the complete environment. A successful run prints the Frontend, Client API, and MCP URLs.

Later `sundeck up` runs preserve a populated database. To replace its data with another saved snapshot, run these commands from that Daydream worktree while its VM is running:

```sh
sundeck database restore customer --replace
sundeck up
```

Replacement discards local database changes after validating and migrating the snapshot in staging. It keeps your saved snapshots but no backup of the replaced database. Restore leaves applications stopped; `up` starts them again. To switch back, restore the other saved snapshot. Omit the snapshot name to restore the default.

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

Build `~/.sundeck/workspace` from the real development configuration and secret files already in the Daydream checkout or supplied by my team. Preserve each required workspace file's relative path. Copy only secret files referenced by those configurations. Set `sundeck-shared.json` to {"formatVersion":5}. Use real copies, not symlinks. Apply mode 0700 to directories and 0600 to files.

Preserve existing database snapshots and their selected default. If no snapshot is available, copy a complete team-supplied snapshot, or use `sundeck database pull` for the organization I specify after Google Cloud authentication and read access are available. Ask which organization to pull if I have not specified one; do not choose --all automatically. Use `sundeck database snapshots` and `sundeck database default <name>` to select a default when needed. Pulling and selecting a default do not replace a running VM's database.

Treat Tailscale as optional. Do not block setup if `tailscale/connection.secret.json` or its values are absent; omit the directory or leave it empty and continue with `.machine` development. Configure Tailscale only if complete existing values are available and I explicitly ask to use it.

Do not print secret contents, use example configurations, invent or rotate credentials, construct a database manifest, replace an existing `~/.sundeck` wholesale, or commit private files. Do not replace a populated VM database unless I ask for it. If required configuration or secrets are missing or ambiguous, report the exact expected path or field so I can obtain the correct input from my team.

Run `sundeck device inputs check`. Only after it passes, run `sundeck codex install` and `AI_AGENT=codex sundeck up` from the Daydream checkout. Report the validation result and the URLs printed by the successful run.
```

## Upgrade Sundeck

```sh
brew update
brew upgrade sundeck
```

Each formula revision names an immutable GitHub release archive and verifies its SHA-256 before Homebrew installs the `sundeck` executable.
