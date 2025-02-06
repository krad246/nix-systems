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
    ++ (with self.modules.generic; [
      home-link-registry
      flake-registry
      nix-core
      unfree
    ]);

  home = {
    file.dotfiles.source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles";

    # auto switch to default specialisation
    activation = lib.modules.mkIf (config.specialisation != {}) {
      switchToSpecialisation = let
        cfg = config.specialisation.default.configuration;
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD ${lib.meta.getExe cfg.home.activationPackage}
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

  nix.settings = {
    trusted-users = [config.home.username];
  };
}
