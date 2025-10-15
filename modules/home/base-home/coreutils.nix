{pkgs, ...}: {
  home = {
    packages = with pkgs;
      [
        coreutils
        safe-rm
        tldr
        sd
      ]
      ++ [duf dust]
      ++ [procps procs nodePackages.fkill-cli]
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
