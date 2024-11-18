{
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in {
  packages =
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      disko-install = import ./disko-install.nix {inherit self pkgs;};
    })
    // (let
      # TODO: must port devShell inputsFrom.
      targetPkgs = tpkgs:
        with tpkgs;
          [git]
          ++ [direnv nix-direnv]
          ++ [just gnumake]
          ++ [shellcheck nil];

      profile = ''
        if [[ -f /.dockerenv ]]; then
          # nix-build doesn't play very nice with the sticky bit
          # and /tmp in a docker environment. unsetting it enables
          # the container to manage its tmpfs as it pleases.
          unset TEMP TMPDIR NIX_BUILD_TOP
        else
          :
        fi
      '';
    in
      lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        devshell-bwrapenv = pkgs.buildFHSEnvBubblewrap {
          name = "devshell";
          inherit targetPkgs profile;
        };
        devshell-chrootenv = pkgs.buildFHSEnvChroot {
          name = "devshell";
          inherit targetPkgs profile;
        };
      });
}
