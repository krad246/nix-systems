{pkgs, ...}: {
  home = {
    packages = with pkgs;
      [
        uutils-coreutils
        safe-rm

        envsubst
      ]
      ++ [
        gnumake
        just
        has
      ]
      ++ [
        neofetch
        nodePackages.undollar
      ]
      ++ [nix-tree];
  };
}
