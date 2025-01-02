{
  lib,
  host,
  cross,
  ...
}:
host.pkgs.dockerTools.streamLayeredImage {
  name = "vscode-devcontainer";

  # Based on Ubuntu 22.04 of the mapped architecture
  fromImage = cross.self'.packages.ubuntu;
  architecture = cross.pkgs.go.GOARCH;

  contents = cross.pkgs.buildEnv {
    name = "vscode-devcontainer-env";
    paths = with cross.pkgs;
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
    SSL_CERT_FILE = "${cross.pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "${cross.pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
    TERM = "xterm-256color";
  };

  # Reconfigure the Nix install as single-user, but with flake support.
  extraCommands = ''
    mkdir -p ./etc/nix

    cat <<- EOF >./etc/nix/nix.conf
    build-users-group =
    experimental-features = nix-command flakes
    platforms = ${cross.pkgs.stdenv.system}
    cores = 0
    max-jobs = auto
    EOF
  '';

  enableFakechroot = !host.pkgs.stdenv.isAarch64;
  fakeRootCommands = ''
  '';
}
