{
  imports = let
    # replace this with an actual commit id or tag
    commit = "master";
    tarball = builtins.fetchTarball {
      url = "https://github.com/nix-community/impermanence/archive/${commit}.tar.gz";
      # replace this with an actual hash
      sha256 = "1mig6ns8l5iynsm6pfbnx2b9hmr592s1kqbw6gq1n25czdlcniam";
    };
    impermanence = "${tarball}/nixos.nix";
  in ["${impermanence}"];
}
