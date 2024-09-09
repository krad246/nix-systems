{
  self,
  inputs,
  ...
}: let
  # Make a script for pkgs.stdenv.system's architecture
  # that runs our devshell parametrized on 'platform'
  # TODO: flake-parts might have an equivalent replacement.
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
        # TODO: on darwin there needs to be a tmpfs on this directory otherwise stuff is readonly
        tmpdir="$(mktemp -d ${lib.strings.optionalString pkgs.stdenv.isDarwin "-p \"$HOME/.cache\""})";
        vname="$(basename "$tmpdir")"
        export vname

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

        # TODO: probably drop this
        user="$(cat <(docker image inspect -f '{{.Config.User}}' ${tagString}))"
        gid="''${user#*:}"
        export user gid

        # spawn unprivileged user shell session
        cidfile="$tmpdir/container.cid"
        hostStore=/host-store
        containerStore=/container-store
        mergedStore=/overlay-store
        docker run --rm -itd \
          --cap-add SYS_ADMIN \
          --net=host \
          -u "$user" \
          --platform linux/${platPkgs.go.GOARCH} \
          --cidfile "$cidfile" \
          --group-add "$gid" \
          --mount=type=bind,src="$FLAKE_ROOT",dst="$WDIR" \
          --mount=type=bind,src=/nix/store,dst="$hostStore/lowerdir",readonly \
          --tmpfs "$hostStore/rw" \
          --tmpfs "$containerStore/rw" \
          --tmpfs "$mergedStore/rw" \
        ${tagString} && docker ps

        # Install an exit handler
        bailout() {
          docker container stop "$(cat "$cidfile")"
          docker volume rm "$vname"
        }

        trap bailout EXIT

        # Determine entry point of container (with the associated environment variables, etc.)
        cmd="$(cat <(docker image inspect -f '{{join .Config.Cmd " "}}' ${tagString}))"
        export cmd

        # mount command for overlay nix store
        # shellcheck disable=SC2086
        mounter="$(cat << EOM
            set -x;

            # mount tmpfs on hostStore
            # shellcheck disable=SC2086
            mkdir -p $hostStore/rw/{upperdir,workdir} &&
              mount -t overlay \
                -o X-mount.mkdir \
                -o lowerdir="$hostStore/lowerdir" \
                -o upperdir="$hostStore/rw/upperdir" \
                -o workdir="$hostStore/rw/workdir" \
                overlay "$hostStore"

            # mount tmpfs on containerStore
            # shellcheck disable=SC2086
            mkdir -p $containerStore/rw/{upperdir,workdir} && \
              mount -B -o X-mount.mkdir,ro \
                /nix/store "$containerStore/lowerdir" && \
              mount -t overlay \
                -o X-mount.mkdir \
                -o lowerdir="$containerStore/lowerdir" \
                -o upperdir="$containerStore/rw/upperdir" \
                -o workdir="$containerStore/rw/workdir" \
              overlay "$containerStore"

            # merge hostStore and containerStore
            # shellcheck disable=SC2086
            mkdir -p $mergedStore/rw/{upperdir,workdir} && \
              mount -B -o X-mount.mkdir,ro \
                "$hostStore" "$mergedStore/lowerdir" && \
              mount -B -o X-mount.mkdir \
                "$containerStore" "$mergedStore/rw/upperdir" && \
              mount -t overlay \
                -o X-mount.mkdir \
                -o lowerdir="$mergedStore/lowerdir" \
                -o upperdir="$mergedStore/rw/upperdir" \
                -o workdir="$mergedStore/rw/workdir" \
              overlay "$mergedStore"

            set +x
        EOM

        )"

        # run as root for a small command to mount
        # needs extended capabilities for this one command
        # shellcheck disable=SC2086
        docker exec -it \
          --privileged \
          -u root \
          -it \
          "$(cat "$cidfile")" \
          $cmd -ci \
          "$mounter"

        docker attach "$(cat "$cidfile")"
      '';
    };

  mkDocker = {
    pkgs,
    platform ? pkgs.stdenv.system,
    ...
  }: let
    inherit (pkgs) lib;
    wrapDockerRun = pkgs.mkShell {
      shellHook = ''
        exec ${lib.getExe (mkDockerRun {inherit pkgs platform;})}
      '';
    };
  in {
    "${platform}" = wrapDockerRun;
    "docker/${platform}" = wrapDockerRun;
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
            ++ [nixFlakes nix-tree nil]
            ++ [docker dive];
        };
      }
      # Expose a dockerized environment for this architecture
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (mkDocker {inherit pkgs;});

    packages = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      "docker/devshell" = pkgs.dockerTools.buildNixShellImage {
        drv = self'.devShells.default;
        gid = 100;
      };
    };
  };

  flake = {
    # Provide an aarch64-linux dockerized environment as well as an x86_64-linux env
    # TODO: Might also be made obsolete by flake-parts.
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
