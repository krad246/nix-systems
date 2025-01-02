{
  host,
  cross,
  devcontainer-loader,
  ...
}: let
  image = "${devcontainer-loader.imageName}:${devcontainer-loader.imageTag}";
in
  host.pkgs.substituteAll rec {
    src = ./Makefile.in;
    inherit image;

    loader = devcontainer-loader;
    devcontainer = host.pkgs.lib.meta.getExe host.pkgs.devcontainer;
    docker = host.pkgs.lib.meta.getExe host.pkgs.docker;

    # Generate a devcontainer.json with the 'image' parameter set to this flake's vscode-devcontainer.
    template = host.pkgs.substituteAll {
      src = ./devcontainer.json.in;
      inherit image;
      platform = "${cross.pkgs.go.GOOS}/${cross.pkgs.go.GOARCH}";
    };
  }
