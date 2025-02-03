{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./hercules-ci/hercules-ci.nix
      ./hercules-ci/linux-builder.nix
      ./remotes.nix
      ./sshd.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint
