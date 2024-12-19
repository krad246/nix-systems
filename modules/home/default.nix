{self, ...}: {
  imports = with self.homeModules;
    [shellenv]
    ++ (with self.modules.generic; [
      home-link-registry
      flake-registry
    ]);
}
