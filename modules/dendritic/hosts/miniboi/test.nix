{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks.miniboi-automated-install = pkgs.testers.runNixOSTest {
      name = "miniboi-automated-install";

      nodes.miniboi = {
        imports = self.nixosConfigurations.miniboi-aarch64-linux.graph;
      };

      testScript = ''
        miniboi.start()

        miniboi.wait_for_unit("default.target")
        t.assertIn("Linux", miniboi.succeed("uname"), "Wrong OS")

        miniboi.shutdown()
      '';
    };
  };
}
