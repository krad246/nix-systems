{
  # Install home-manager into the PATH.
  # It's only used to compile the derivation otherwise and is deleted after.
  programs.home-manager.enable = true;

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;

  # Switch to flakes and DISABLE the caching of failed evaluations.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  news.display = "silent";
}
