# Homebrew tap for Sundeck

This public repository contains signed and notarized Apple Silicon releases of [Sundeck](https://github.com/tomdai/sundeck) and the Homebrew formula that installs them.

## Install

Requirements: Apple Silicon, macOS 26 Tahoe or newer, and [Apple Container](https://github.com/apple/container).

Sundeck's default `.machine` URLs require Apple Container's local DNS domains to include `machine`. Check the one-time host setup with:

```sh
container system dns list
```

If `machine` is absent, add it with administrator privileges:

```sh
sudo container system dns create machine
```

On a pristine Apple Container installation, the first `sundeck up` starts its services noninteractively and installs Apple's recommended VM kernel. That initial download can make the first run slower; subsequent starts reuse the installed kernel.

```sh
brew install tomdai/sundeck/sundeck
```

Upgrade an existing installation with:

```sh
brew update
brew upgrade sundeck
```

Each formula revision names an immutable GitHub release archive and verifies its SHA-256 before Homebrew installs the `sundeck` executable.
