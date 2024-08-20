{pkgs, ...}: {
  imports =
    [
      ./bash.nix
      ./bat.nix
      ./bottom.nix
    ]
    ++ [
      ./colima
    ]
    ++ [
      ./coreutils.nix
      ./direnv.nix
      ./git.nix
      ./nix-core.nix
      ./nvim
      ./ripgrep.nix
    ]
    ++ [
      ./secrets
    ]
    ++ [
      ./starship.nix
      ./zoxide.nix
      ./zsh.nix
    ];

  home = {
    packages = with pkgs; [cachix];
    sessionVariables = {
    };
  };

  news.display = "silent";

  # Install home-manager into the PATH.
  # It's only used to compile the derivation otherwise and is deleted after.
  programs.home-manager.enable = true;

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;
}
