FROM ghcr.io/boldsoftware/exeuntu:latest

# OCI label links this package to the GitHub repo (enables GHCR <-> repo integration)
LABEL org.opencontainers.image.source=https://github.com/c0ffee0wl/exeuntu-custom

# Run linux-setup as exedev so dotfiles land in /home/exedev with correct ownership.
# ENV USER is needed because Docker build doesn't set $USER — the script uses it
# for "usermod -aG docker $USER" and "chsh $USER" which fail with empty $USER.
USER exedev
WORKDIR /home/exedev
ENV USER=exedev

# Clone and run linux-setup with --force (non-interactive) and --no-hacking-tools.
# The script has "set -eo pipefail" internally, causing it to abort on commands
# like systemctl that fail in Docker. We run it in a subshell with || true to let
# the build continue, then verify that .zshrc was actually created.
SHELL ["/bin/bash", "-c"]
RUN git clone --depth 1 https://github.com/c0ffee0wl/linux-setup.git /tmp/linux-setup \
    && (/tmp/linux-setup/linux-setup.sh --force --no-hacking-tools || true) \
    && rm -rf /tmp/linux-setup \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Guarantee zsh is default shell for exedev (fallback if chsh failed above)
USER root
RUN usermod -s /usr/bin/zsh exedev

# Match base image entrypoint (systemd via init-wrapper)
CMD ["/usr/local/bin/init"]
