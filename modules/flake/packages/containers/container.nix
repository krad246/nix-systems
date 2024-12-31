args @ {
  lib,
  pkgs,
  self',
  ...
}: let
  inherit (args) hostCtx;
in
  # instantiate a layeredImage script targeted at 'system' but runnable on 'hostSystem'
  hostCtx.pkgs.dockerTools.streamLayeredImage {
    name = "vscode-devcontainer";

    # Based on Ubuntu 22.04 of the mapped architecture
    fromImage = self'.packages.ubuntu;
    architecture = pkgs.go.GOARCH;

    contents = pkgs.buildEnv {
      name = "vscode-devcontainer-env";
      paths = with pkgs;
        [bashInteractive git]
        ++ [toybox less lesspipe util-linux]
        ++ [nix just]
        ++ [
          dockerTools.binSh
          dockerTools.usrBinEnv
        ];

      pathsToLink = ["/bin"];
    };

    config.Env = lib.attrsets.mapAttrsToList (name: value: "${name}=${value}") {
      # Provide the Nix install certificate paths for internet access.
      SSL_CERT_FILE = "${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "${pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
      TERM = "xterm-256color";
    };

    # Reconfigure the Nix install as single-user, but with flake support.
    extraCommands = ''
      mkdir -p ./etc/nix

      cat <<- EOF >./etc/nix/nix.conf
      build-users-group =
      experimental-features = nix-command flakes
      extra-platforms = ${hostCtx.pkgs.stdenv.system} ${pkgs.stdenv.system}
      EOF
    '';

    enableFakechroot = hostCtx.pkgs.stdenv.isx86_64;
    fakeRootCommands = ''
    '';
  }
