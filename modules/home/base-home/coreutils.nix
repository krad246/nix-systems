{pkgs, ...}: {
  home = {
    packages = with pkgs;
      [
        coreutils
        safe-rm
      ]
      ++ [
        neofetch
        nodePackages.undollar
        has
      ]
      ++ [
        gnumake
        just
      ];
  };
}
