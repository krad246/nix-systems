{
  self,
  lib,
  ...
}: {
  perSystem = {
    packages = lib.attrsets.optionalAttrs (!lib.trivial.inPureEvalMode) {
      hx = self.homeConfigurations.standalone.config.programs.helix.package;
    };
  };
}
