{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta;
in {
  imports =
    [
      ./agenix.nix
      ./bash.nix
      ./bat.nix
      ./bitwarden.nix
      ./bottom.nix
      ./coreutils.nix
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./nerdfonts.nix
      ./ripgrep.nix
      ./spotify-player.nix
      ./starship.nix
      ./zoxide.nix
      ./zsh.nix
    ]
    ++ [self.homeModules.helix]
    ++ (with self.modules.generic; [
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

    shellAliases = rec {
      l = meta.getExe pkgs.lsd;
      ls = l;
      ll = "${ls} -gl";
      la = "${ll} -A";
      lal = la;

      reload = ''
        exec ${meta.getExe pkgs.bashInteractive} \
          --rcfile <(${meta.getExe' pkgs.coreutils "echo"} \
              'source ${config.home.homeDirectory}/.bashrc; \
              ${meta.getExe pkgs.direnv} reload')
      '';
      tldr = meta.getExe pkgs.tldr;
    };

    stateVersion = lib.trivial.release;
  };

  news.display = "silent";

  manual = {
    html.enable = true;
    json.enable = true;
  };

  xdg.configFile = {
    dotfiles = {
      enable = false;
      source = self;
    };
  };
}
