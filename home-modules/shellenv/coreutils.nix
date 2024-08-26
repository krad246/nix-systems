{pkgs, ...}: {
  home = {
    packages = with pkgs;
      [
        uutils-coreutils
        safe-rm
      ]
      ++ [
        neofetch
        nodePackages.undollar
      ];
  };
}
