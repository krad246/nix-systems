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
  }: let
    inherit (pkgs) lib;
  in
    pkgs.writeShellApplication {
      name = "docker-run";
      text = let
        img = self.packages.${platform}."docker/devshell";
        platPkgs = import inputs.nixpkgs {system = platform;};
        tagString = "${img.imageName}:${img.imageTag}";
      in ''
        set -x

        # Generate a random tmpdir - also used as volume name
        tmpdir="$(mktemp -d ${lib.strings.optionalString pkgs.stdenv.isDarwin "-p \"$HOME/.cache\""})";
        vname="$(basename "$tmpdir")"

        # Install an exit handler
        bailout() {
          docker volume rm "$vname"
        }

        trap bailout EXIT

        # Load image if it hasn't already been loaded
        # Dump it to a logfile
        json="$tmpdir/image.json"
        if ! docker image inspect ${tagString} >"$json"; then
          docker load < ${img}
        fi

        # Create overlay dirs
        lowerdir="$FLAKE_ROOT"
        upperdir="$tmpdir/rw/upper"
        workdir="$tmpdir/rw/work"
        mkdir -p {"$workdir","$upperdir"}

        # Create overlayfs mount as docker volume using dirs above
        docker volume create --driver local --opt type=overlay \
          --opt o="lowerdir=$lowerdir,upperdir=$upperdir,workdir=$workdir" \
          --opt device=overlay "$vname"

        # TODO: query the WorkingDir through the Nix interface instead of at runtime
        WDIR="$(cat <(docker image inspect -f '{{.Config.WorkingDir}}' ${tagString}))"
        export WDIR

        user="$(cat <(docker image inspect -f '{{.Config.User}}' ${tagString}))"
        gid="''${user#*:}"

        # Mount the overlay volume onto the repo
        docker run --rm -it \
          --platform linux/${platPkgs.go.GOARCH} \
          --group-add "$gid" \
          --mount=type=volume,src="$vname",dst="$WDIR" \
          ${img.imageName}:${img.imageTag}
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
            ++ [procps util-linux]
            ++ [nixFlakes nix-tree]
            ++ [docker dive];
        };
      }
      # Expose a dockerized environment for this architecture
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (mkDocker {inherit pkgs;});
  };

  flake = {
    # Provide an aarch64-linux dockerized environment as well as an x86_64-linux env
    devShells = {
      aarch64-darwin =
        (mkDocker {
          pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
          platform = "aarch64-linux";
        })
        // (mkDocker {
          pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
          platform = "x86_64-linux";
        });

      x86_64-linux = mkDocker {
        pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
        platform = "aarch64-linux";
      };
      aarch64-linux = mkDocker {
        pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
        platform = "x86_64-linux";
      };
    };
  };
}
