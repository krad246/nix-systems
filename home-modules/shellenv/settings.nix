{
  inputs,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  # Install home-manager into the PATH.
  # It's only used to compile the derivation otherwise and is deleted after.
  programs.home-manager.enable = true;

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;

  # Switch to flakes and DISABLE the caching of failed evaluations.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    eval-cache = false
  '';

  news.display = "silent";
  nix = lib.mkDefault {
    package = lib.attrsets.attrByPath ["nix" "package"] pkgs.nixFlakes osConfig;
    settings = lib.attrsets.attrByPath ["nix" "settings"] {} osConfig;
  };

  home.sessionVariables = let
    nixPath = lib.attrsets.attrByPath ["nix" "nixPath"] ["nixpkgs=${inputs.nixpkgs}"] osConfig;
    osVars = lib.attrsets.attrByPath ["environment" "variables"] {} osConfig;
  in
    {
      NIX_PATH = "${lib.strings.concatStringsSep ":" nixPath}";
    }
    // lib.attrsets.optionalAttrs (lib.attrsets.hasAttrByPath ["NIX_LD"] osVars) {
      inherit (osVars) NIX_LD NIX_LD_LIBRARY_PATH;
    };
}
