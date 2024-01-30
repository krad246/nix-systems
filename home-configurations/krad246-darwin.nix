{ezModules, ...}: {
  imports = with ezModules;
    [
      ./krad246-cli.nix
      ./krad246.nix
    ]
    ++ [kitty];
}
