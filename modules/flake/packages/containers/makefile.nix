args @ {
  lib,
  pkgs,
  self',
  ...
}: let
  inherit (args) hostCtx;
  specific = hostCtx.self'.packages.vscode-devcontainer;
  image = "${specific.imageName}:${specific.imageTag}";
in
  args.hostCtx.pkgs.substituteAll rec {
    src = ./Makefile.in;
    inherit image;

    loader = specific;
    devcontainer = hostCtx.pkgs.lib.meta.getExe hostCtx.pkgs.devcontainer;
    docker = hostCtx.pkgs.lib.meta.getExe hostCtx.pkgs.docker;

    # Generate a devcontainer.json with the 'image' parameter set to this flake's vscode-devcontainer.
    template = hostCtx.pkgs.substituteAll {
      src = ./devcontainer.json.in;
      inherit image;
      platform = "${pkgs.go.GOOS}/${pkgs.go.GOARCH}";
    };
  }
