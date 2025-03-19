{
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      concurrentTasks = "auto";
      nixVerbosity = "Warn";
    };
  };
}
