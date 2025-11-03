{
  osConfig,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta;
  isSystemPkgs = lib.attrsets.attrByPath ["home-manager" "useGlobalPkgs"] false osConfig;
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
      ./lsd.nix
      ./nerdfonts.nix
      ./packages.nix
      ./ripgrep.nix
      ./spotify-player.nix
      ./starship.nix
      ./yazi.nix
      ./zoxide.nix
      ./zsh.nix
    ]
    ++ (with self.modules.generic;
      lib.lists.optionals (!isSystemPkgs) [
        overlays
        unfree
      ]);

  services.lorri.enable = pkgs.stdenv.isLinux;

  home = {
    file.dotfiles.source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles";

    # auto switch to default specialisation
    activation =
      (lib.attrsets.optionalAttrs (config.specialisation != {}) {
        switchToSpecialisation = let
          cfg = config.specialisation.default.configuration;
        in
          lib.hm.dag.entryAfter ["writeBoundary"] ''
            $DRY_RUN_CMD ${lib.meta.getExe cfg.home.activationPackage}
          '';
      })
      // {
        syncDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${lib.meta.getExe pkgs.rsync} \
                  --chmod=0755 \
                  --chown=${config.home.username}:nogroup \
                  --mkpath -auvh ${self}/* ${config.xdg.configHome}/dotfiles/
        '';
      };

    packages = with pkgs; [cachix];
    preferXdgDirectories = true;

    stateVersion = lib.trivial.release;
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
