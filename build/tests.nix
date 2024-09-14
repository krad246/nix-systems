_: {
  perSystem = {pkgs, ...}: {
    checks = {
      hello = pkgs.testers.runNixOSTest {
        name = "hello";
        nodes.machine = {pkgs, ...}: {
          environment.systemPackages = [pkgs.hello];
        };
        testScript = ''
          machine.succeed("hello")
        '';
      };
    };
  };
}
