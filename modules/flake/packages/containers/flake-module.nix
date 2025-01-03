{
  withSystem,
  lib,
  ...
}: {
  perSystem = host @ {pkgs, ...}: {
    packages = {
      makefile-aarch64-linux = withSystem "aarch64-linux" (cross: let
        stream-image = pkgs.callPackage ./container-stream.nix {
          inherit host cross;
        };

        image = pkgs.callPackage ./container.nix {inherit host cross;};
      in
        pkgs.callPackage ./makefile.nix rec {
          inherit host cross;

          # Create a loader derivation for the makefile to pull in the container
          devcontainer-loader = let
            loader =
              # streamLayeredImage is more efficient
              if pkgs.stdenv.isLinux
              then let
                linux-loader = pkgs.writeShellApplication {
                  name = "linux-loader";
                  text = ''
                    ${stream-image} | ${lib.meta.getExe pkgs.docker} load
                  '';
                };
              in
                linux-loader
              # MacOS can't use fakeroot, so have to build in a VM
              else let
                darwin-loader = pkgs.writeShellApplication {
                  name = "darwin-loader";
                  text = ''
                    ${lib.meta.getExe pkgs.docker} image load -i ${image}
                  '';
                };
              in
                darwin-loader;
          in
            lib.meta.getExe loader;

          # pass through the docker image name
          devcontainer-image = let
            drv =
              if pkgs.stdenv.isLinux
              then stream-image
              else image;
          in "${drv.imageName}:${drv.passthru.imageTag}";

          # Generate a devcontainer.json with the 'image' parameter set to this flake's vscode-devcontainer.
          devcontainer-json = let
            template = host.pkgs.substituteAll {
              src = ./devcontainer.json.in;
              image = devcontainer-image;
              platform = "${cross.pkgs.go.GOOS}/${cross.pkgs.go.GOARCH}";
            };
          in
            template;
        });

      makefile-x86_64-linux = withSystem "x86_64-linux" (cross: let
        stream-image = pkgs.callPackage ./container-stream.nix {
          inherit host cross;
        };

        image = pkgs.callPackage ./container.nix {inherit host cross;};
      in
        pkgs.callPackage ./makefile.nix rec {
          inherit host cross;

          # Create a loader derivation for the makefile to pull in the container
          devcontainer-loader = let
            loader =
              # streamLayeredImage is more efficient
              if pkgs.stdenv.isLinux
              then let
                linux-loader = pkgs.writeShellApplication {
                  name = "linux-loader";
                  text = ''
                    ${stream-image} | ${lib.meta.getExe pkgs.docker} load
                  '';
                };
              in
                linux-loader
              # MacOS can't use fakeroot, so have to build in a VM
              else let
                darwin-loader = pkgs.writeShellApplication {
                  name = "darwin-loader";
                  text = ''
                    ${lib.meta.getExe pkgs.docker} image load -i ${image}
                  '';
                };
              in
                darwin-loader;
          in
            lib.meta.getExe loader;

          # pass through the docker image name
          devcontainer-image = let
            drv =
              if pkgs.stdenv.isLinux
              then stream-image
              else image;
          in "${drv.imageName}:${drv.passthru.imageTag}";

          # Generate a devcontainer.json with the 'image' parameter set to this flake's vscode-devcontainer.
          devcontainer-json = let
            template = host.pkgs.substituteAll {
              src = ./devcontainer.json.in;
              image = devcontainer-image;
              platform = "${cross.pkgs.go.GOOS}/${cross.pkgs.go.GOARCH}";
            };
          in
            template;
        });
    };
  };

  flake.packages = let
    pullImage = pkgs: metadata:
      pkgs.dockerTools.pullImage (metadata
        // {
          os = pkgs.go.GOOS;
          arch = pkgs.go.GOARCH;
        });
  in {
    aarch64-darwin =
      withSystem "aarch64-darwin" (_host: {
      });

    aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
      ubuntu = pullImage pkgs {
        imageName = "ubuntu";
        imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
        sha256 = "03srdhmiii3f07rf29k17sipz8f88kydg7hj8awjqsv4jzq7an81";
        finalImageName = "ubuntu";
        finalImageTag = "latest";
      };

      nix-flakes = pullImage pkgs {
        imageName = "nixpkgs/nix-flakes";
        imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
        sha256 = "1kd83s9y26jsrnwy4gxchl6ir2c8p8h95m2f22p070p32ig3ljxb";
        finalImageName = "nixpkgs/nix-flakes";
        finalImageTag = "latest";
      };

      nixos = pullImage pkgs {
        imageName = "nixos/nix";
        imageDigest = "sha256:fd7a5c67d396fe6bddeb9c10779d97541ab3a1b2a9d744df3754a99add4046f1";
        sha256 = "0lyjvwkblsyylgdb6hw2iw1rk5nm19znap6hrijnwfy0alk83fjh";
        finalImageName = "nixos/nix";
        finalImageTag = "latest";
      };
    });

    x86_64-linux = withSystem "x86_64-linux" ({pkgs, ...}: {
      ubuntu = pullImage pkgs {
        imageName = "ubuntu";
        imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
        sha256 = "0j32w10gl1p87xj8kll0m2dgfizc3l2jnsdj4n95l960d4a4pmfa";
        finalImageName = "ubuntu";
        finalImageTag = "latest";
      };

      nix-flakes = pullImage pkgs {
        imageName = "nixpkgs/nix-flakes";
        imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
        sha256 = "0fxyvs2sxmfhj9i70wh23m2licx2waj7z1z5iy0gf6nlkm3j72cf";
        finalImageName = "nixpkgs/nix-flakes";
        finalImageTag = "latest";
      };

      nixos = pullImage pkgs {
        imageName = "nixos/nix";
        imageDigest = "sha256:fd7a5c67d396fe6bddeb9c10779d97541ab3a1b2a9d744df3754a99add4046f1";
        sha256 = "1ggkwd9zw8lj97ig7zah7dqy463hfhsgq3iwxxf8117gf8xi422s";
        finalImageName = "nixos/nix";
        finalImageTag = "latest";
      };
    });
  };
}
