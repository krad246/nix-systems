{
  inputs,
  self,
  lib,
  specialArgs,
  ...
}: let
  inherit (inputs) nixos-hardware;
in {
  imports =
    [self.modules.generic.unfree]
    ++ (with self.nixosModules; [
      agenix
      avahi
      bluetooth
      efiboot
      flatpak
      kdeconnect
      pipewire
      rdp
      sshd
      system76-scheduler
      wireshark
    ])
    ++ (with nixos-hardware.nixosModules; [
      common-cpu-amd
      common-cpu-amd-pstate
      common-cpu-amd-zenpower
      common-gpu-amd
      common-hidpi
      common-pc
      common-pc-ssd
    ])
    ++ [
      ./cachix-agent.nix
      ./hardware-configuration.nix
    ];

  programs.ssh = {
    startAgent = true;
  };

  users.users.krad246.openssh.authorizedKeys.keys = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "pub" ./authorized_keys;
  in
    lib.lists.forEach paths (path: builtins.readFile path);

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ../../secrets;
  in
    krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
}
