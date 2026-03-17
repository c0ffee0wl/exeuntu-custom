FROM ghcr.io/boldsoftware/exeuntu:latest

# OCI label links this package to the GitHub repo (enables GHCR <-> repo integration)
LABEL org.opencontainers.image.source=https://github.com/c0ffee0wl/exeuntu-custom

# Pre-install zsh so we can set it as default shell reliably
RUN apt-get update && apt-get install -y --no-install-recommends zsh \
    && rm -rf /var/lib/apt/lists/*

# Run linux-setup as exedev so dotfiles land in /home/exedev with correct ownership
USER exedev
WORKDIR /home/exedev

# Clone linux-setup, run with --force (non-interactive) and --no-hacking-tools,
# then clean up. The trailing "; true" absorbs non-zero exits from harmless
# systemd/chsh failures during Docker build.
RUN git clone --depth 1 https://github.com/c0ffee0wl/linux-setup.git /tmp/linux-setup \
    && /tmp/linux-setup/linux-setup.sh --force --no-hacking-tools \
    ; rm -rf /tmp/linux-setup \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    ; true

# Guarantee zsh is default shell for exedev (fallback if chsh failed above)
USER root
RUN usermod -s /usr/bin/zsh exedev

# Match base image entrypoint (systemd via init-wrapper)
CMD ["/usr/local/bin/init"]
