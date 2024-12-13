{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
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
      self.homeModules.nixvim
      self.modules.generic.unfree
    ];

  home = {
    packages = with pkgs; [cachix];
    preferXdgDirectories = true;

    shellAliases = rec {
      l = lib.meta.getExe pkgs.lsd;
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
