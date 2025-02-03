{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; (
      [coreutils safe-rm]
      ++ [bashmount duf dust]
      ++ [
        procps
        procs
        nodePackages.fkill-cli
      ]
    );
  };
}
