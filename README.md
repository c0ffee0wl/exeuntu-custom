# exeuntu-custom

Custom Docker image that extends [exeuntu](https://github.com/boldsoftware/exeuntu)
(the default [exe.dev](https://exe.dev) VM image) with my personal dev
environment from [linux-setup](https://github.com/c0ffee0wl/linux-setup).

## What it adds

The exeuntu base already ships Ubuntu 24.04 with systemd, Docker, headless
Chrome, Shelley and other coding agents, Go, uv, and the usual dev tools (see
[its Dockerfile](https://github.com/boldsoftware/exeuntu/blob/main/Dockerfile)).
On top of that, this image runs `linux-setup.sh` to set up:

**Shell**

- zsh as the default login shell, with autosuggestions, syntax highlighting, and a preconfigured `.zshrc` / `.zprofile` / `.profile`
- fzf for fuzzy history and file search, and hstr for browsing shell history
- zoxide, a `cd` that remembers the directories you actually use

**Command-line tools**

- bat (a `cat` with syntax highlighting), fd-find, ripgrep, jq, yq, tree, tmux, htop, ncdu
- delta wired in as the git pager, plus lazygit and lazydocker for git and Docker TUIs
- a handful of smaller utilities: sd, eget, gitsnip, exiftool

**Language runtimes and package tools**

- Rust via rustup
- Bun, with `node` / `npx` shims so it drops in for Node.js
- PowerShell
- Python tooling through pipx and uv (uv installs httpie, tldr, and name-that-hash)

**Supply-chain hardening**

- Hardened configs for npm, Bun, Cargo, uv, and pip: 7-day install cooldowns, exact version pinning, blocked lifecycle scripts, and telemetry opt-outs

## Usage

### With exe.dev

```
ssh exe.dev new --name=my-custom-vm --image=ghcr.io/c0ffee0wl/exeuntu-custom:latest
```

Then connect:

```
ssh myvm.exe.xyz
```

### With Docker

```
docker pull ghcr.io/c0ffee0wl/exeuntu-custom:latest
docker run -d --privileged --name myvm ghcr.io/c0ffee0wl/exeuntu-custom:latest
```

## Building locally

```
docker build -t exeuntu-custom .
```

## How it works

The Dockerfile builds on `ghcr.io/boldsoftware/exeuntu:latest`, then clones and
runs [linux-setup.sh](https://github.com/c0ffee0wl/linux-setup) with
`--force --no-hacking-tools`. `--force` answers every prompt with yes so the
build stays non-interactive, and `--no-hacking-tools` skips the pentest tooling.
Afterwards it restores a few base-image defaults that the setup script changes:
Docker goes back to starting on first use, `/etc/machine-id` is emptied so
each VM gets its own, and the image runs as root so systemd can boot.
GitHub Actions rebuilds the image weekly so it picks up changes to both the base
image and the setup script.

## Links

- Base image: [boldsoftware/exeuntu](https://github.com/boldsoftware/exeuntu)
- Setup script: [c0ffee0wl/linux-setup](https://github.com/c0ffee0wl/linux-setup)
- exe.dev: [exe.dev](https://exe.dev)
