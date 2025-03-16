{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./dullahan.nix
      ./hercules-ci/dullahan.nix
      ./hercules-ci/headless-penguin.nix
      ./remotes.nix
      ./secrets.nix
      ./sshd.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint
