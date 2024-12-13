{self, ...}: {
  imports = with self.homeModules;
    [shellenv]
    ++ (with self.modules.generic; [
      home-registry
      flake-registry
    ]);
}
