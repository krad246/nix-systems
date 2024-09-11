{pkgs, ...}: {
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
      ../../secrets
    ]
    ++ [
      ./starship.nix
      ./zoxide.nix
      ./zsh.nix
    ];

  home = {
    packages = with pkgs; [cachix];
    preferXdgDirectories = true;
  };

  news.display = "silent";

  # Version mismatch validation
  home.enableNixpkgsReleaseCheck = true;
}
