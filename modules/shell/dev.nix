{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.shell = {
      config,
      pkgs,
      ...
    }: let
      cfg = config.shell.profiles.dev;
    in {
      imports = with self.modules.homeManager; [
        codex
        direnv
        gh
        git
        lazygit
        lorri
      ];

      options.shell.profiles.dev.enable = lib.options.mkEnableOption "Whether this to turn on development extensions for the CLI.";

      config = lib.modules.mkIf cfg.enable {
        shell = {
          integrations.direnv.enable = lib.modules.mkDefault true;

          programs = {
            codex.enable = lib.modules.mkDefault true;
            direnv.enable = true;
            diff.integrations = {
              git.enable = lib.modules.mkDefault true;
              lazygit.enable = lib.modules.mkDefault true;
            };
            gh.enable = true;
            git = {
              enable = true;
              integrations = {
                gh.enable = lib.modules.mkDefault true;
              };
            };

            lazygit.enable = true;
            lorri.enable = pkgs.stdenv.hostPlatform.isLinux;
          };
        };

        home.packages = with pkgs; [
          binutils
          cachix
          cmake
          gdb
          gnumake
          just
          # neofetch
          nix-diff
          nix-du
          nix-fast-build
          nix-output-monitor
          nodePackages.undollar
          # safe-rm
        ];

        # home.shellAliases.rm = "safe-rm";
      };
    };
  };
}
