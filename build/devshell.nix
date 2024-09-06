{
  self,
  inputs,
  ...
}: let
  # Make a script for pkgs.stdenv.system's architecture
  # that runs our devshell parametrized on 'platform'
  mkDockerRun = {
    pkgs,
    platform,
    ...
  }:
    pkgs.writeShellApplication {
      name = "docker-run";
      text = let
        img = self.packages.${platform}."docker/devshell";
        platPkgs = import inputs.nixpkgs {system = platform;};
        tagString = "${img.imageName}:${img.imageTag}";
      in ''
        set -x

        # Load image if it hasn't already been loaded
        if ! docker image inspect ${tagString}; then
          docker load < ${img}
        fi

        # Generate a random tmpdir - also used as volume name
        tmpdir="$(mktemp -d -p "$PWD/.cache")"
        vname="$(basename "$tmpdir")"

        # Create overlay dirs
        lowerdir="$tmpdir/ro"
        upperdir="$tmpdir/rw/upper"
        workdir="$tmpdir/rw/work"
        mkdir -p "$lowerdir"
        mkdir -p "$upperdir"
        mkdir -p "$workdir"

        # Create overlayfs mount as docker volume using dirs above
        docker volume create --driver local --opt type=overlay \
          --opt o="lowerdir=$lowerdir,upperdir=$upperdir,workdir=$workdir" \
          --opt device=overlay "$vname"

        # TODO: query the WorkingDir through the Nix interface instead of at runtime
        WDIR="$(cat <(docker image inspect -f '{{.Config.WorkingDir}}' ${tagString}))"

        # Mount the overlay volume onto the repo
        docker run --rm -it --read-only \
          --platform linux/${platPkgs.go.GOARCH} \
          --net host \
          -v "$vname:$WDIR:rw" \
          ${img.imageName}:${img.imageTag}

        docker volume rm "$vname"
      '';
    };

  mkDocker = {
    pkgs,
    platform ? pkgs.stdenv.system,
    ...
  }: let
    inherit (pkgs) lib;
  in {
    "docker/${platform}" = pkgs.mkShell {
      shellHook = ''
        exec ${lib.getExe (mkDockerRun {inherit pkgs platform;})}
      '';
    };
  };
in {
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    devShells =
      {
        default = self'.devShells.nix-shell;
        nix-shell = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell
            config.just-flake.outputs.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];

          packages = with pkgs;
            [git]
            ++ [direnv nix-direnv]
            ++ [just fd fzf ripgrep]
            ++ [uutils-coreutils nano]
            ++ [safe-rm]
            ++ [nixFlakes nix-tree]
            ++ [dive];
        };
      }
      # Expose a dockerized environment for this architecture
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (mkDocker {inherit pkgs;});
  };

  flake = {
    # Provide an aarch64-linux dockerized environment as well as an x86_64-linux env
    devShells.aarch64-darwin =
      (mkDocker {
        pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
        platform = "aarch64-linux";
      })
      // (mkDocker {
        pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
        platform = "x86_64-linux";
      });
  };
}
