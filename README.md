# exeuntu-custom

Custom Docker image extending [exeuntu](https://github.com/boldsoftware/exeuntu)
(the default [exe.dev](https://exe.dev) VM image) with a personal development
environment powered by [linux-setup](https://github.com/c0ffee0wl/linux-setup).

## What it adds

On top of the exeuntu base (Ubuntu 24.04, systemd, Docker, Chrome headless,
Claude CLI, Shelley, nginx, build tools):

- **zsh** as default shell with autosuggestions, syntax highlighting, and custom config
- **fzf** — fuzzy finder for shell history, files, and more
- **bat** — syntax-highlighted cat replacement
- **fd-find** — fast, user-friendly alternative to find
- **zoxide** — smarter cd that learns your habits
- **hstr** — shell history browser
- **lazygit** / **lazydocker** — terminal UIs for git and Docker
- **Rust toolchain** via rustup
- **Bun** JavaScript runtime
- **pipx tools** — httpie, tldr, uv, and more
- **Custom dotfiles** — .zshrc, .zprofile, .profile with aliases and environment

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
docker run -d --name myvm ghcr.io/c0ffee0wl/exeuntu-custom:latest
```

## Building locally

```
docker build -t exeuntu-custom .
```

## How it works

The Dockerfile extends `ghcr.io/boldsoftware/exeuntu:latest` by cloning and
running [linux-setup.sh](https://github.com/c0ffee0wl/linux-setup) with
`--force --no-hacking-tools`. The image is rebuilt weekly by GitHub Actions
to pick up changes to both the base image and the setup script.

## Links

- Base image: [boldsoftware/exeuntu](https://github.com/boldsoftware/exeuntu)
- Setup script: [c0ffee0wl/linux-setup](https://github.com/c0ffee0wl/linux-setup)
- exe.dev: [exe.dev](https://exe.dev)
