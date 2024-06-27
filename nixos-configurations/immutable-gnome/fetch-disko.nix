{
  imports = let
    # replace this with an actual commit id or tag
    commit = "v1.3.0";
    tarball = builtins.fetchTarball {
      url = "https://github.com/nix-community/disko/archive/${commit}.tar.gz";
      # replace this with an actual hash
      sha256 = "1lrnvgd5w41wrgidp3vwv2ahpvl0a61c2lai6qs16ri71g00kqn0";
    };
    disko = "${tarball}/module.nix";
  in ["${disko}"];
}
