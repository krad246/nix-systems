{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; (
      [coreutils safe-rm]
      ++ [bashmount]
    );
  };
}
