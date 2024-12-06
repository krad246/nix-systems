{
  self,
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) krad246;
in {
  imports =
    [
      ./bash.nix
      ./bat.nix
      ./bottom.nix
      ./coreutils.nix
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./nix-core.nix
      ./ripgrep.nix
      ./starship
      ./zoxide.nix
    ]
    ++ [
      self.homeModules.nixvim
    ];

  home = {
    packages = with pkgs; [cachix];
    preferXdgDirectories = true;

    shellAliases = rec {
      l = ''
        ${krad246.cli.toGNUCommandLineShell (lib.meta.getExe pkgs.lsd) {
          hyperlink = "auto";
          group-dirs = "first";
          icon-theme = "unicode";
        }}
      '';

      ls = l;
      ll = "${ls} -gl";
      la = "${ll} -A";
      lal = la;

      reload = ''
        exec ${lib.meta.getExe pkgs.bashInteractive} \
          --rcfile <(${lib.meta.getExe' pkgs.coreutils "echo"} \
              'source ${config.home.homeDirectory}/.bashrc; \
              ${lib.meta.getExe pkgs.direnv} reload')
      '';
      tldr = "${lib.meta.getExe pkgs.tldr}";
    };
  };

  news.display = "silent";

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;
}
