{
  pkgs,
  lib,
  ...
}: {
  environment = {
    systemPackages = with pkgs;
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
      ++ [comma]
      ++ [git gh]
      ++ [direnv nix-direnv];

    shellAliases = {
      ls = "${lib.getExe pkgs.lsd} --color=auto";
      cat = "${lib.getExe pkgs.bat} -p";
    };
  };
}
