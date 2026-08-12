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
      ++ [procps procs]
      ++ [
        undollar
        has
      ]
      ++ [
        gnumake
        just
      ];
  };
}
