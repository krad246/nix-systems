{self, ...}: {
  imports = with self.darwinModules; [
    base-configuration
  ];
}
