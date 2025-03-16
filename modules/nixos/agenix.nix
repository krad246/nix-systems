args @ {
  lib,
  pkgs,
  ...
}: let
  # prefer flake inputs version of agenix, unless the arg is missing
  # fall back to main of the repo otherwise
  commit = "main";
  pinned = builtins.fetchTarball {
    url = "https://github.com/ryantm/agenix/archive/${commit}.tar.gz";
    sha256 = "006ngydiykjgqs85cl19h9klq8kaqm5zs0ng51dnwy7nzgqxzsdr";
  };
  repo = lib.attrsets.attrByPath ["inputs" "agenix"] pinned args;
in {
  imports = ["${repo}/modules/age.nix"];

  environment.systemPackages = [
    (pkgs.callPackage "${repo}/pkgs/agenix.nix" {})
  ];
}
