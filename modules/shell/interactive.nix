{lib, ...}: {
  flake.modules.homeManager.shell = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.shell.profiles.interactive;
  in {
    options.shell.profiles.interactive.enable =
      lib.options.mkEnableOption "Whether this to turn on interactive tools and integrations for the CLI."
      // {
        default = true;
      };

    config = lib.modules.mkIf cfg.enable {
      shell = {
        backends = {
          bash.enable = true;
          nushell.enable = lib.modules.mkDefault false;
        };
        integrations = {
          bat.enable = true;
          fzf.enable = lib.modules.mkDefault config.picker.backends.fzf.enable;
          lsd.enable = true;
          starship.enable = true;
          yazi.enable = true;
          zoxide.enable = true;
        };
        programs = {
          bat.enable = true;
          bottom.enable = true;
          diff.enable = true;
          fd.enable = true;
          lsd.enable = true;
          man.enable = true;
          pager.enable = true;
          ripgrep.enable = true;
          starship.enable = true;
          yazi.enable = true;
          zoxide.enable = true;
        };
      };

      home.packages = with pkgs; ([
          coreutils
          curl
          duf
          dust
          file
          gnutar
          jq
          procps
          # safe-rm # FIXME: not useful unless aliasing rm
          sd
          tldr
          tree
          which
          unzip
          zip
        ]
        ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
          bashmount
          psmisc
          strace
        ]
        ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
          m-cli
        ]);
    };
  };
}
