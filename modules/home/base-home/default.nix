{
  osConfig,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) attrsets hm lists meta trivial;
in {
  imports =
    [
      ./agenix.nix
      ./bash.nix
      ./bat.nix
      ./bitwarden.nix
      ./bottom.nix
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./helix.nix
      ./lsd
      ./nerdfonts.nix
      ./packages.nix
      ./ripgrep.nix
      ./spotify-player.nix
      ./starship.nix
      ./yazi.nix
      ./zoxide.nix
      ./zsh.nix
    ]
    ++ (with self.modules.generic; let
      isSystemPkgs = osConfig.home-manager.useGlobalPkgs or false;
    in
      lists.optionals (!isSystemPkgs) [
        overlays
        unfree
      ]);

  services.lorri.enable = pkgs.stdenv.isLinux;

  home = {
    file.dotfiles.source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles";

    # auto switch to default specialisation
    activation =
      (attrsets.optionalAttrs (config.specialisation != {}) {
        switchToSpecialisation = let
          cfg = config.specialisation.default.configuration;
        in
          hm.dag.entryAfter ["writeBoundary"] ''
            $DRY_RUN_CMD ${meta.getExe cfg.home.activationPackage}
          '';
      })
      // {
        syncDotfiles = hm.dag.entryAfter ["writeBoundary"] ''
          ${meta.getExe pkgs.rsync} \
                  --chmod=0755 \
                  --chown=${config.home.username}:nogroup \
                  --mkpath -auvh ${self}/* ${config.xdg.configHome}/dotfiles/
        '';
      };

    packages = with pkgs; [cachix];
    preferXdgDirectories = true;

    stateVersion = trivial.release;
  };

  news.display = "silent";

  manual = {
    html.enable = true;
    json.enable = true;
  };

  xdg = {
    enable = true;
    configFile = {
      dotfiles = {
        enable = false;
        source = self;
      };
    };
  };
}
