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
        mktemp = lib.getExe' pkgs.coreutils "mktemp";
        docker = lib.getExe pkgs.docker;
        cat = lib.getExe' pkgs.coreutils "cat";
      in ''
        set -x

        tmpdir="$(${mktemp} -d ${lib.strings.optionalString pkgs.stdenv.isDarwin "-p \"$HOME/.cache\""})";

        # Load image if it hasn't already been loaded
        if ! ${docker} image inspect ${tagString} >/dev/null; then
          ${docker} load < ${img}
        fi

        # TODO: query the WorkingDir through the Nix interface instead of at runtime
        WDIR="$(${cat} <(${docker} image inspect -f '{{.Config.WorkingDir}}' ${tagString}))"
        export WDIR

        # TODO: probably drop this
        user="$(${cat} <(${docker} image inspect -f '{{.Config.User}}' ${tagString}))"
        gid="''${user#*:}"
        export user gid

        # spawn unprivileged container
        # mount the host nix store and the project workspace
        cidfile="$tmpdir/container.cid"
        hostStore=/host-store
        ${docker} run --rm -itd \
          --cap-add SYS_ADMIN \
          --net=host \
          -u "$user" \
          --platform linux/${platPkgs.go.GOARCH} \
          --cidfile "$cidfile" \
          --group-add "$gid" \
          --mount=type=bind,src="$FLAKE_ROOT",dst="$WDIR" \
          --mount=type=bind,src=/nix/store,dst="$hostStore",readonly \
          --tmpfs /tmp \
        ${tagString} && ${docker} ps

        bailout() {
          ${docker} container stop "$(cat "$cidfile")"
          ${lib.getExe pkgs.safe-rm} -dr "$tmpdir"
        }

        # Install an exit handler
        trap bailout EXIT

        # Determine entry point of container (with the associated environment variables, etc.)
        cmd="$(${cat} <(${docker} image inspect -f '{{join .Config.Cmd " "}}' ${tagString}))"
        export cmd

        # put tmpfs on upperdir, merge host store and container store
        # shellcheck disable=SC2086
        mounter="$(${cat} << EOM
            set -x;
            ${lib.getExe' pkgs.coreutils "mkdir"} -p /tmp/{workdir,upperdir} &&
            ${lib.getExe' pkgs.util-linux "mount"} -t overlay \
              -o X-mount.mkdir \
              -o lowerdir=/nix/store:"$hostStore" \
              -o upperdir=/tmp/upperdir \
              -o workdir=/tmp/workdir \
              overlay /nix/store;
            set +x
        EOM

        )"

        # run as root for a small command to mount overlayfs
        # needs extended capabilities for this one command
        # shellcheck disable=SC2086
        ${docker} exec -itd \
          --privileged \
          -u root \
          -it \
          "$(${cat} "$cidfile")" \
          $cmd -ci \
          "$mounter"

        ${docker} attach "$(${cat} "$cidfile")"
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
