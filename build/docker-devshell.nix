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
        fromImage = pkgs.dockerTools.pullImage {
          imageName = "nixos/nix";
          imageDigest = "sha256:85299d86263a3059cf19f419f9d286cc9f06d3c13146a8ebbb21b3437f598357";
          sha256 = "19fw0n3wmddahzr20mhdqv6jkjn1kanh6n2mrr08ai53dr8ph5n7";
          finalImageTag = "2.2.1";
          finalImageName = "nix";
        };
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
