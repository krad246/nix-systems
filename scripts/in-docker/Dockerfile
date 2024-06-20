FROM nixos/nix

RUN echo 'experimental-features = nix-command flakes' >>/etc/nix/nix.conf
RUN echo 'filter-syscalls = false' >>/etc/nix/nix.conf

WORKDIR /workdir
RUN git config --global --add safe.directory /workdir
