{
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      ./bash.nix
      ./bat.nix
      ./bottom.nix
    ]
    ++ [
      ./bitwarden.nix
    ]
    ++ [
      ./colima
    ]
    ++ [
      ./coreutils.nix
      ./direnv.nix
      ./fd.nix
      ./fzf.nix
      ./git.nix
      ./nix-core.nix
      ./nvim
      ./ripgrep.nix
    ]
    ++ [
      ./agenix.nix
      ./secrets.nix
    ]
    ++ [
      ./starship.nix
      ./zoxide.nix
      ./zsh.nix
    ];

  home = {
    packages = with pkgs; [cachix];
    preferXdgDirectories = true;

    shellAliases = rec {
      l = "${lib.getExe pkgs.lsd} --hyperlink auto --group-dirs first";

      ls = l;
      ll = "${ls} -gl";
      la = "${ll} -A";
      lal = la;

      reload = "${lib.getExe pkgs.direnv} allow \"$PWD\" && ${lib.getExe pkgs.direnv} reload \"$PWD\"";
    };
  };

  news.display = "silent";

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;
}
