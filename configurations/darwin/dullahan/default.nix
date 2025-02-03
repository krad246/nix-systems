{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./dullahan.nix
      ./hercules-ci/ci-agent.nix
      ./hercules-ci/headless-penguin.nix
      ./remotes.nix
      ./sshd.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint
