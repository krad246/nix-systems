{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs;
      [
        coreutils
        uutils-coreutils
        envsubst
      ]
      ++ [
        bat
        lsd

        just
        ripgrep
        safe-rm
        tre
        zoxide
      ]
      ++ [
        neofetch
        bottom
        nodePackages.undollar
      ]
      ++ [comma nix-index]
      ++ [git gh]
      ++ [direnv nix-direnv];
  };

  nixpkgs.config.allowUnfree = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;
}
