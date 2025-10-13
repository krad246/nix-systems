{self, ...}: {
  imports =
    [
      ./agenix.nix
      ./auto-update.nix
      ./dark-mode.nix
      ./dock.nix
      ./finder.nix
      ./firewall.nix
      ./hm-compat.nix
      ./homebrew.nix
      ./keyboard.nix
      ./linux-builder.nix
      ./mac-app-util.nix
      ./menubar.nix
      ./misc-prefs.nix
      ./nix-daemon.nix
      ./packages.nix
      ./pointer.nix
      ./single-user.nix
      ./spotlight.nix
      ./touch-id.nix
      ./window-manager.nix
    ]
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      lorri
      nix-core
      overlays
      unfree
    ]);

  system.stateVersion = 5;
}
