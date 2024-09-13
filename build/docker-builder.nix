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

        # Load image if it hasn't already been loaded
        if ! ${docker} image inspect ${tagString} >/dev/null; then
          ${docker} load < ${img}
        fi

        # TODO: query the WorkingDir through the Nix interface instead of at runtime
        WDIR="$(${cat} <(${docker} image inspect -f '{{.Config.WorkingDir}}' ${tagString}))"
        export WDIR

        # TODO: probably drop this
        user="$(${cat} <(${docker} image inspect -f '{{.Config.User}}' ${tagString}))"
        uid="''${user%:*}"
        gid="''${user#*:}"
        export user uid gid

        # spawn unprivileged container
        # mount the host nix store and the project workspace
        tmpdir="$(${mktemp} -d ${lib.strings.optionalString pkgs.stdenv.isDarwin "-p \"$HOME/.cache\""})";
        cidfile="$tmpdir/container.cid"
        hostStore=/host-store
        tmpfs=/tmp

        ${docker} run --rm -itd \
          --cap-add SYS_ADMIN \
          --net=host \
          --device /dev/fuse \
          -u "$user" \
          --platform linux/${platPkgs.go.GOARCH} \
          --cidfile "$cidfile" \
          --group-add "$gid" \
          --mount=type=bind,src="${self}",dst=/self,readonly \
          --mount=type=bind,src=/nix/store,dst="$hostStore",readonly \
          --tmpfs "$tmpfs" \
        ${tagString} && ${docker} ps

        bailout() {
          ${lib.getExe pkgs.safe-rm} -drv "$tmpdir"
        }

        # Install an exit handler
        trap bailout EXIT

        # Determine entry point of container (with the associated environment variables, etc.)
        cmd="$(${cat} <(${docker} image inspect -f '{{join .Config.Cmd " "}}' ${tagString}))"
        export cmd

        # put tmpfs on upperdir, merge host store and container store
        # shellcheck disable=SC2086
        mounter="$(${cat} << EOM
            set -eux

            # make tmpfs dirs and give exclusive ownership of nix store
            ${lib.getExe' platPkgs.findutils "find"} /nix -print0 | \
              ${lib.getExe' platPkgs.findutils "xargs"} -P$(nproc) -0 -I{} \
                ${lib.getExe platPkgs.bashInteractive} -c \
                  '${lib.getExe' platPkgs.coreutils "chown"} "$user" {}' || \
                    ${lib.getExe' platPkgs.coreutils "true"};

            ${lib.getExe' platPkgs.coreutils "install"} -d \
              -m 0755 -o "$uid" -g "$gid" \
                "$tmpfs/nix" \
                "$tmpfs/nix/store" \
                "$tmpfs/nix/store/upperdir" \
                "$tmpfs/nix/store/workdir" \
                "$tmpfs/$WDIR" \
                "$tmpfs/$WDIR/upperdir" \
                "$tmpfs/$WDIR/workdir" \
                /overlay-store \
                /container-store \
                /flake

            # rebind host store with permissions changed

            # merge container store
            ${lib.getExe' platPkgs.bindfs "bindfs"} \
              -u "$uid" -g "$gid" -p 755 "$hostStore" /overlay-store &&
            ${lib.getExe' platPkgs.util-linux "mount"} -t overlay \
              -o X-mount.mkdir \
              -o lowerdir=/nix/store:/overlay-store \
              -o upperdir="$tmpfs/nix/store/upperdir" \
              -o workdir="$tmpfs/nix/store/workdir" \
            overlay /nix/store;

            # merge workspace
            ${lib.getExe' platPkgs.bindfs "bindfs"} \
              -u "$uid" -g "$gid" -p 755 /self /flake &&
            ${lib.getExe' platPkgs.util-linux "mount"} -t overlay \
              -o X-mount.mkdir \
              -o lowerdir=/flake \
              -o upperdir="$tmpfs/$WDIR/upperdir" \
              -o workdir="$tmpfs/$WDIR/workdir" \
            overlay "$WDIR";

            ${lib.getExe' platPkgs.coreutils "echo"} \
              user_allow_other >/etc/fuse.conf &&
            ${lib.getExe' platPkgs.coreutils "echo"} \
              'experimental-features = nix-command flakes'>>/etc/nix/nix.conf
        EOM

        )"

        # run as root for a small command to mount overlayfs
        # needs extended capabilities for this one command
        # shellcheck disable=SC2086
        ${docker} exec -it \
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
    lib,
    pkgs,
    ...
  }: {
    devShells = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (mkDocker {inherit pkgs;});

    packages = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      "docker/devshell" = pkgs.dockerTools.buildNixShellImage {
        drv = self'.devShells.default;
        homeDirectory = "/tmp";
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
