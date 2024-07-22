{pkgs, ...}: {
  home = {
    packages = with pkgs;
      [
        uutils-coreutils
        envsubst
        wget
        unzip
        safe-rm
        jq
      ]
      ++ [
        gnumake
        just
        has
        gcc
      ]
      ++ [
        neofetch
        nodePackages.undollar
        duf
      ]
      ++ [comma]
      ++ [nix-tree nix-du nix-diff];
  };
}
