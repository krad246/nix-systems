{self, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    packages = {
      # TODO: consider switching to streamNixShellImage.
      devshell = pkgs.dockerTools.streamLayeredImage {
        name = "devshell";

        fromImage = pkgs.dockerTools.pullImage {
          imageName = "ubuntu";
          imageDigest = "sha256:83f0c2a8d6f266d687d55b5cb1cb2201148eb7ac449e4202d9646b9083f1cee0";
          sha256 = "sha256-5y6ToMw1UGaLafjaN69YabkjyCX61FT3QxU4mtmXMP0=";
          finalImageName = "ubuntu";
          finalImageTag = "latest";
        };

        contents = let
          mkEnv = pkgs:
            pkgs.buildEnv {
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
                  ++ [direnv]
                  ++ [starship]
                  ++ [coreutils]
                  ++ [cowsay hello]);

              pathsToLink = ["/bin" "/share"];
            };
        in
          mkEnv (
            if pkgs.stdenv.isDarwin
            then (import self.inputs.nixpkgs {system = "aarch64-linux";})
            else pkgs
          );

        config = {
          Env = [
          ];
        };
      };
    };
  };
}
