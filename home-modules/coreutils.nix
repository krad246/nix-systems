{
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs;
      [
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
      ++ [comma];

    shellAliases = {
      ls = "${lib.getExe pkgs.lsd} --color=auto";
      cat = "${lib.getExe pkgs.bat} -p";
    };
  };
}
