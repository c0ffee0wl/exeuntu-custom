FROM ghcr.io/boldsoftware/exeuntu:latest

# OCI label links this package to the GitHub repo (enables GHCR <-> repo integration)
LABEL org.opencontainers.image.source=https://github.com/c0ffee0wl/exeuntu-custom

# Remove docker.io so linux-setup.sh installs docker-ce from Docker's official repo
RUN apt-get remove -y docker.io docker-compose-v2 docker-buildx containerd runc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Run linux-setup as exedev so dotfiles land in /home/exedev with correct ownership.
# Docker build doesn't set $USER, so it is passed to the script for installers
# that expect it — inline rather than ENV, so root shells don't inherit it.
USER exedev
WORKDIR /home/exedev

# Clone linux-setup into ~/linux-setup (kept for later reruns) and run it with
# --force (non-interactive) and --no-hacking-tools. The script has "set -eo pipefail"
# internally, causing it to abort on commands like systemctl that fail in Docker.
# We run it with || true to let the build continue.
#
# We intentionally KEEP /var/lib/apt/lists (the package index) so that
# `apt-cache search` works inside the running container. `apt-get clean` still
# drops the downloaded .deb archives to keep the image lean, and the final
# `apt-get update` rebuilds a fresh index. Do NOT re-add `rm -rf /var/lib/apt/lists/*`.
SHELL ["/bin/bash", "-c"]
RUN git clone --depth 1 https://github.com/c0ffee0wl/linux-setup.git ~/linux-setup \
    && (USER=exedev ~/linux-setup/linux-setup.sh --force --no-hacking-tools || true) \
    && sudo apt-get clean \
    && sudo rm -rf /tmp/* /var/tmp/* \
    && sudo apt-get update

# Root like the base image, so init (systemd) can run as PID 1; SSH logins
# still land as exedev via the inherited exe.dev/login-user label.
USER root

# Restore upstream defaults that linux-setup changes: Docker socket-activated
# rather than started at boot, and an empty (not deleted) machine-id so each VM
# generates its own. Keep this the last RUN: package installs bake in an ID.
# No `|| true` here: a failure (e.g. docker-ce missing) should fail the build.
RUN systemctl disable docker.service containerd.service \
    && systemctl enable docker.socket \
    && truncate -s 0 /etc/machine-id \
    && ln -sf /etc/machine-id /var/lib/dbus/machine-id

CMD ["/usr/local/bin/init"]
