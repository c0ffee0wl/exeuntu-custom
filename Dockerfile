FROM ghcr.io/boldsoftware/exeuntu:latest

# OCI label links this package to the GitHub repo (enables GHCR <-> repo integration)
LABEL org.opencontainers.image.source=https://github.com/c0ffee0wl/exeuntu-custom

# Remove docker.io so linux-setup.sh installs docker-ce from Docker's official repo
RUN apt-get remove -y docker.io docker-compose-v2 docker-buildx containerd runc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Run linux-setup as exedev so dotfiles land in /home/exedev with correct ownership.
# ENV USER is needed because Docker build doesn't set $USER — the script uses it
# for "usermod -aG docker $USER" and "chsh $USER" which fail with empty $USER.
USER exedev
WORKDIR /home/exedev
ENV USER=exedev

# Clone linux-setup into ~/linux-setup (kept for later reruns) and run it with
# --force (non-interactive) and --no-hacking-tools. The script has "set -eo pipefail"
# internally, causing it to abort on commands like systemctl that fail in Docker.
# We run it with || true to let the build continue.
SHELL ["/bin/bash", "-c"]
RUN git clone --depth 1 https://github.com/c0ffee0wl/linux-setup.git ~/linux-setup \
    && (~/linux-setup/linux-setup.sh --force --no-hacking-tools || true) \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Match base image entrypoint (systemd via init-wrapper)
CMD ["/usr/local/bin/init"]
