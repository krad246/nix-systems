{
  perSystem = {
    inputs',
    pkgs,
    lib,
    config,
    ...
  }: {
    packages = {
      devshell = pkgs.dockerTools.streamLayeredImage {
        name = "devshell";
        fromImage = null;
        contents = pkgs.buildEnv {
          name = "devshell-contents";
          paths =
            # seems to be mandatory
            [pkgs.dockerTools.binSh pkgs.bashInteractive]
            ++ (with pkgs;
              [
                just
              ]
              ++ [
                fd
                ripgrep
                zoxide
              ]
              ++ [
                bat
                (bat-extras.batdiff.override {withDelta = true;})
                bat-extras.batgrep
              ]
              ++ [glow]
              ++ [
                inputs'.nixvim-config.packages.default
              ]
              ++ [direnv]
              ++ [starship]
              ++ [coreutils]
              ++ [cowsay hello]);

          pathsToLink = ["/bin" "/share"];
        };

        config = {
          Env = [
            "VISUAL=${lib.getExe inputs'.nixvim-config.packages.default}"
            "EDITOR=${lib.getExe inputs'.nixvim-config.packages.default}"
            "PAGER=${lib.getExe pkgs.less}"
            "LESS=$LESS -SXIFRs"
            "LESSOPEN=|${lib.getExe pkgs.bat-extras.batpipe} %s"
            "BATPIPE=color"
          ];
        };
      };
    };
  };
}
