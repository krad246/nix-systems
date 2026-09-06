{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.search.webEngine = lib.options.mkOption {
      type = lib.types.nullOr (lib.types.enum ["Bing" "DuckDuckGo" "Ecosia" "Google" "Yahoo"]);
      default = "Google";
      description = "Default web search engine on desktop backends that expose one.";
    };
  };
}
