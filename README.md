# Homebrew tap for Sundeck

This public repository contains signed and notarized Apple Silicon releases of [Sundeck](https://github.com/tomdai/sundeck) and the Homebrew formula that installs them.

## Install

Requirements: Apple Silicon, macOS 26 Tahoe or newer, and [Apple Container](https://github.com/apple/container).

```sh
brew install tomdai/sundeck/sundeck
```

Upgrade an existing installation with:

```sh
brew update
brew upgrade sundeck
```

Each formula revision names an immutable GitHub release archive and verifies its SHA-256 before Homebrew installs the `sundeck` executable.
