{pkgs, ...}: let
  unionfs = pkgs.unionfs-fuse.overrideAttrs (_previous: {
    version = "3.5";
    src = pkgs.fetchFromGitHub {
      owner = "rpodgorny";
      repo = "unionfs-fuse";
      rev = "v3.5";
      hash = "sha256-yosS1x15E8Rtuvikkl0cr6VHTEWn/up+EzFybyiU0Lk=";
    };

    nativeBuildInputs = _previous.nativeBuildInputs ++ [pkgs.pkg-config pkgs.fuse];
    meta.broken = false;
  });
in {
  home = {packages = [unionfs];};
}
