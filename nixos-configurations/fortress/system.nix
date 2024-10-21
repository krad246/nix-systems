{
  self,
  config,
  lib,
  ...
}: let
  # found in the minimal profile
  hasXEnabled =
    lib.attrsets.attrByPath ["services" "xserver" "enable"] false config; # usually true.

  # WSL instances define this attribute
  isWSL = lib.attrsets.attrByPath ["wsl" "enable"] false config;

  # docker images set this
  isContainer = lib.attrsets.attrByPath ["boot" "isContainer"] false config;

  # common for VMs
  growableRoot = lib.attrsets.attrByPath ["boot" "growPartition"] false config;

  isIso = lib.attrsets.hasAttrByPath ["system" "build" "isoImage"] config;

  isVM =
    isContainer
    || growableRoot
    || (lib.attrsets.hasAttrByPath ["virtualisation" "diskSize"]
      config);
  isGraphicalNixOS = let
    vmGui =
      lib.attrsets.attrByPath ["virtualisation" "graphics"]
      true
      config;
  in
    if (isWSL || isContainer || (!hasXEnabled) || !vmGui)
    then false
    else hasXEnabled;

  baseModules = isGraphicalNixOS;
  extendedModules = let
    rest = baseModules && !isVM && !isIso;
  in
    rest;
in {
  imports = with self.nixosModules;
    [
      gnome-desktop
      nixos
      whitesur
    ]
    ++ lib.lists.optional extendedModules [self.nixosModules.agenix];

  services.flatpak.enable = lib.mkDefault false;

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"] ++ ["docker" "libvirtd"] ++ ["NetworkManager"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
    openssh.authorizedKeys = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzCjoarVDF5bnWX3SBciYyaiMzGnzTF9uefbja5xLB0"
      ];
    };
  };

  system.stateVersion = lib.trivial.release;

  # Default value to shut the flake checker up. Overridden using extendModules.
  nixpkgs.system = lib.mkDefault "x86_64-linux";
}
