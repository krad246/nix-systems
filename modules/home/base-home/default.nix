{
  self,
  config,
  lib,
  pkgs,
  modulesPath,
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
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./helix.nix
      ./nerdfonts.nix
      ./packages.nix
      ./ripgrep.nix
      ./spotify-player.nix
      ./starship.nix
      ./zoxide.nix
      ./zsh.nix
    ]
    ++ (with self.modules.generic; [
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

    packages = let
      docsPath = modulesPath + "/../docs";

      docs = import docsPath {
        inherit lib pkgs;
        inherit (config.home.version) release isReleaseBranch;
      };

      htmlOpenTool = pkgs.symlinkJoin {
        name = "home-manager";
        paths = [docs.manual.htmlOpenTool];
        buildInputs = [pkgs.makeWrapper];
        postBuild = let
          opener = pkgs.writeShellApplication {
            name = "zen-browser-file-open";
            text = ''
              set -x
              open -a Zen -u "file://$1"
            '';
          };
        in ''
          wrapProgram $out/bin/home-manager-help --set BROWSER ${lib.meta.getExe opener}
        '';
      };
    in
      with pkgs;
        [
          cachix
        ]
        ++ (with docs.manual; [
          html
          htmlOpenTool
        ]);
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
    # html.enable = true;
    json.enable = true;
  };

  xdg.configFile = {
    dotfiles = {
      enable = false;
      source = self;
    };
  };
}
