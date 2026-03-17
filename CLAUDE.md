# CLAUDE.md — Project Context for Claude Code

## Project overview

This repo builds a custom Docker image (`ghcr.io/c0ffee0wl/exeuntu-custom`)
that extends the exe.dev base image (exeuntu) with a personal dev environment.

## Architecture

- `Dockerfile` — extends `ghcr.io/boldsoftware/exeuntu:latest`, runs linux-setup.sh as the exedev user
- `.github/workflows/build-and-push.yml` — builds and pushes to GHCR on push to main, weekly schedule, and manual dispatch
- The setup script is NOT vendored — it is cloned at build time from https://github.com/c0ffee0wl/linux-setup

## Key details

- Base image user: `exedev` (UID 1000), has passwordless sudo and docker group
- Base image init: systemd via `/usr/local/bin/init` (init-wrapper.sh)
- Default shell: zsh (set via usermod fallback in Dockerfile)
- The `linux-setup.sh --force --no-hacking-tools` flag runs non-interactively and skips pentesting tools
- The `; true` in the RUN command absorbs expected non-zero exits from systemd/chsh failures during build

## Common tasks

- **Rebuild image locally:** `docker build -t exeuntu-custom:test .`
- **Test image:** `docker run --rm exeuntu-custom:test su - exedev -c 'echo $SHELL; which fzf bat zoxide'`
- **Trigger rebuild:** push to main or use workflow_dispatch in GitHub Actions
- **After first push:** make the GHCR package public in package settings

## Do NOT

- Fork or modify the exeuntu repo — we only consume the published image
- Vendor linux-setup.sh — it is always cloned fresh at build time
- Remove the `; true` from the Dockerfile RUN — systemd commands fail during Docker build and that is expected
