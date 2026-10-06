# Getting started with Sundeck

This repository contains signed and notarized Apple Silicon releases of Sundeck and the Homebrew formula that installs them.

## What you need

- An Apple Silicon Mac running macOS 15 or newer
- Homebrew
- [OrbStack](https://orbstack.dev)
- A Daydream checkout and the team's development configuration and secret files
- A prepared development database snapshot, or the team's production read access to create one with `sundeck database pull`

Use the real development configuration and secrets supplied by your team, which may already be in your existing Daydream folder. Ask your team for missing private inputs; example configurations are not substitutes. Tailscale is optional and is not required to start Daydream with Sundeck.

## 1. Install Sundeck

Install Sundeck from its public Homebrew tap:

```sh
brew install tomdai/sundeck/sundeck
```

Install OrbStack once:

```sh
brew install --cask orbstack
```

Sundeck uses named machine endpoints. Disable OrbStack's automatic localhost/LAN machine port forwarding once so it cannot bypass worktree domain controls or collide with the device OAuth relay:

```sh
orb config set machines.forward_ports false
```

If OrbStack is already running, stop and restart its shared runtime to apply this setting; coordinate that restart with other workloads. This is a device-wide Linux-machine setting. Other OrbStack machines must also use their named addresses; OrbStack's global Docker port forwarding is unaffected. Sundeck checks this setting before managed guest mutations and never changes it implicitly.

OrbStack provides `.orb.local` DNS and host file sharing automatically. Its GUI does not need to remain open; Sundeck uses its background runtime. Each worktree has a native Linux machine with dynamic memory, independent services, and its own database volumes.

OrbStack does not need to be running yet. Sundeck starts it when needed.

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

You may omit the entire `tailscale/` directory or leave it empty. Normal `.orb.local` development does not require Tailscale credentials.

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

`pull` saves a new snapshot without changing a machine or production. Repeat `--organization` to select several organizations, or use `--all` to include every organization. Omit `--name` for an automatic timestamp name. Large organizations can take time and disk space; AI usage and billing rows are excluded. Imported integrations are disconnected and existing agent invocations are retired. Snapshots retain private business content and belong in `~/.sundeck`, never in Git.

List saved snapshots and choose the one new machines should use:

```sh
sundeck database snapshots
sundeck database default customer
```

For a copied snapshot, use its existing name instead of `customer`. A single saved snapshot is selected automatically; with several snapshots, the list marks the default with `*`. New pulls preserve an existing default; changing the default does not change any machine. No machine needs to be running for these commands. First startup restores the default into an absent or empty database.

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

If you omit this file, `sundeck up` continues to use the default `.orb.local` HTTP URLs. `sundeck tailscale enable` and `sundeck device oauth-relay enable` will explain that the optional configuration is required for those features.

## 5. Validate the private inputs

Run:

```sh
sundeck device inputs check
```

This checks the layout, ownership, permissions, JSON, referenced secrets, configuration compatibility, and all file checksums in the default snapshot. It does not start OrbStack or modify a Daydream checkout.

Resolve any reported missing or ambiguous input using the existing Daydream material. Do not substitute an example value just to make validation pass.

## 6. Start Daydream

Run Sundeck from the existing Daydream checkout:

```sh
cd /absolute/path/to/Daydream
sundeck up
```

The first run can be slower because Sundeck prepares its Ubuntu toolchain template and the complete environment. Sundeck saves the prepared template under `~/Library/Application Support/Sundeck/machine-profiles/`, removes the temporary preparation machine, and imports the archive directly for new worktree machines. Deleting machines in OrbStack preserves the saved template; removing its host directory requires preparation again. A successful run prints the Frontend, Client API, and MCP URLs.

Later `sundeck up` runs preserve a populated database. To replace its data with another saved snapshot, run these commands from that Daydream worktree while its machine is running:

```sh
sundeck database restore customer --replace
sundeck up
```

Replacement discards local database changes after validating and migrating the snapshot in staging. It keeps your saved snapshots but no backup of the replaced database. Restore leaves applications stopped; `up` starts them again. To switch back, restore the other saved snapshot. Omit the snapshot name to restore the default.

If you use Codex, install Sundeck's repository integration from any Daydream checkout:

```sh
sundeck codex install
```

This installs an ignored `AGENTS.override.md` in the primary checkout and all existing linked worktrees. Start a chat in your usual checkout; ask the agent to work in a worktree when you want isolation. The instructions explain how to reuse or create a worktree, install and verify its instructions before reading or changing its source, and run `AI_AGENT=codex sundeck up` there. New worktrees default to the repository's locally recorded `origin/HEAD` unless you specify another ref. Chats without a worktree request keep their selected checkout.

Run `sundeck codex install` again after upgrading Sundeck, and use `sundeck codex status` to verify all existing checkouts. The integration does not require a Codex environment profile or project configuration block. It preserves tracked repository guidance and tells the agent to read it alongside Sundeck's environment instructions.

Other AI agents can skip `sundeck codex install` and use their own short identifier in `AI_AGENT`.

## Prompt for an AI agent

Replace the checkout placeholder, then give this prompt to an agent with terminal access to the Mac:

```text
Set up Sundeck for the existing Daydream checkout at <ABSOLUTE_PATH>.

Use the setup guide at https://github.com/tomdai/homebrew-sundeck#readme for installation, private inputs, snapshots, and startup. Include the required `machines.forward_ports false` setting; coordinate any required device-wide OrbStack restart with me.

Use real development inputs already available or supplied by my team. Preserve existing private inputs, snapshots, their selected default, and populated machine databases. Keep secret contents private. If a snapshot must be pulled and I have not specified an organization, ask which one; do not choose all organizations automatically.

Tailscale is optional; use ordinary `.orb.local` development unless I request Tailscale.

If you are Codex, refresh and verify the repository integration with `sundeck codex install` and `sundeck codex status`. Other agents skip that integration. Use your own short identifier in `AI_AGENT` when starting the environment.

Continue setup and supported recovery until private-input validation passes and Daydream starts successfully. Report the validation result and the actual published URLs. If progress needs missing inputs or an unauthorized operation, explain the concrete blocker and continue independent authorized work.
```

## Upgrade Sundeck

```sh
brew update
brew upgrade sundeck
```

Each formula revision names an immutable GitHub release archive and verifies its SHA-256 before Homebrew installs the `sundeck` executable.
