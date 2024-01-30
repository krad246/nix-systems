{ezModules, ...}: {
  imports = with ezModules; [efiboot nixos-cli pantheon-desktop];
}
