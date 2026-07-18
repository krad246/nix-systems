{
  self,
  lib,
  ...
}: {
  flake.modules.darwin.applications = {
    imports = with self.modules.darwin; [
      groupme
      magnet
    ];

    appStore = {
      installations = {
        groupme = lib.modules.mkDefault "mas";
        magnet = lib.modules.mkDefault "mas";
      };

      backends.mas.enable = true;
    };
  };
}
