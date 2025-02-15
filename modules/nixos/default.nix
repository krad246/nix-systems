{self, ...}: {
  imports = with self.nixosModules; [base-configuration];
}
