{ezModules, ...}: {
  imports = with ezModules;
    [
      ./krad246-cli.nix
    ]
    ++ [discord spotify];
}
