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
      ./bash.nix
      ./bat.nix
      ./bottom.nix
      ./coreutils.nix
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./ripgrep.nix
      ./starship
      ./zoxide.nix
    ]
    ++ [
      self.modules.generic.nix-core
      self.modules.generic.unfree
    ]
    ++ [
      self.homeModules.nixvim
    ];

  home = {
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
  };

  news.display = "silent";

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;
}
