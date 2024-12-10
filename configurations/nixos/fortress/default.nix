{
  withSystem,
  inputs,
  self,
  lib,
  specialArgs,
  ...
}: let
  inherit (inputs) nixos-generators nixos-hardware;
  entrypoint = {system, ...}: {
    imports =
      [
        ./empty-disko.nix
        ./fortress.nix
      ]
      ++ [nixos-generators.nixosModules.all-formats];

    formatConfigs = import ./specialisations/formats;

    specialisation = rec {
      default = fortress;
      fortress.configuration = {pkgs, ...}: let
        inherit specialArgs;
      in {
        imports =
          [self.diskoConfigurations.fortress-desktop]
          ++ [
            ./specialisations/desktop/cachix-agent.nix
            ./specialisations/desktop/hardware-configuration.nix
          ]
          ++ (lib.lists.optionals pkgs.stdenv.isx86_64 (with nixos-hardware.nixosModules; [
            common-cpu-amd
            common-cpu-amd-pstate
            common-cpu-amd-zenpower
            common-gpu-amd
            common-hidpi
            common-pc
            common-pc-ssd
          ]))
          ++ (with self.nixosModules; [
            agenix
            avahi
            bluetooth
            kdeconnect
            pipewire
            rdp
            sshd
          ]);

        programs.ssh = {
          startAgent = true;
        };

        users.users.krad246.openssh.authorizedKeys.keys = let
          inherit (specialArgs) krad246;
          paths = krad246.fileset.filterExt "pub" ./specialisations/desktop/authorized_keys;
        in
          lib.lists.forEach paths (path: builtins.readFile path);

        age.secrets = let
          inherit (specialArgs) krad246;
          paths = krad246.fileset.filterExt "age" ./secrets;
        in
          krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
      };
    };

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
