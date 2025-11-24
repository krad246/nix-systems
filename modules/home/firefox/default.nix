{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    enableGnomeExtensions = pkgs.stdenv.isLinux;

    package = pkgs.firefox-bin;

    languagePacks = [];
    nativeMessagingHosts = [
    ];

    policies = {
    };

    profiles = {
      default = {
        bookmarks = [];

        containers = {
          Personal = {
            color = "blue";
            icon = "fingerprint";
            id = 0;
          };

          Work = {
            color = "orange";
            icon = "briefcase";
            id = 1;
          };

          Banking = {
            color = "green";
            icon = "dollar";
            id = 2;
          };
        };

        containersForce = true;

        extensions = with pkgs.krad246.firefox-addons; [
          bitwarden
          ghostery
          multi-account-containers
          vimium
        ];

        search = rec {
          default = "DuckDuckGo";
          privateDefault = default;

          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };
          };

          force = true;

          order = [
            "DuckDuckGo"
            "Google"
          ];
        };

        settings = {
          "extensions.autoDisableScopes" = 0;
          "accessibility.typeaheadfind.autostart" = false;
          "accessibility.typeaheadfind.enablesound" = false;
          "accessibility.typeaheadfind.flashBar" = 0;
          "accessibility.typeaheadfind.manual" = false;
          "app.normandy.first_run" = false;
          "browser.bookmarks.defaultLocation" = "menu________";
          "browser.bookmarks.editDialog.confirmationHintShowCount" = 3;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.contentblocking.category" = "standard";
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "browser.download.panel.shown" = true;
          "browser.download.viewableInternally.typeWasRegistered.avif" = true;
          "browser.download.viewableInternally.typeWasRegistered.jxl" = true;
          "browser.download.viewableInternally.typeWasRegistered.webp" = true;
          "browser.engagement.ctrlTab.has-used" = true;
          "browser.engagement.downloads-button.has-used" = true;
          "browser.engagement.home-button.has-removed" = true;
          "browser.engagement.home-button.has-used" = true;
          "browser.formfill.enable" = true;
          "browser.launcherProcess.enabled" = true;
          "browser.search.region" = "US";
          "browser.search.serpEventTelemetryCategorization.regionEnabled" = true;
          "browser.search.suggest.enabled" = true;
          "browser.startup.windowsLaunchOnLogin.disableLaunchOnLoginPrompt" = true;
          "browser.tabs.inTitlebar" = 1;
          "browser.tabs.loadBookmarksInTabs" = true;
          "browser.taskbar.previews.enable" = true;
          "browser.theme.toolbar-theme" = 0;
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.urlbar.quicksuggest.scenario" = "offline";
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = true;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.zoom.full" = false;
          "cfs.font.size.footer" = "1.5em";
          "cfs.font.size.searchbar" = "1.4em";
          "cfs.font.size.tabbar.tabs" = "1.3em";
          "cfs.font.size.workspace.title" = "1.5em";
          "dom.forms.autocomplete.formautofill" = true;
          "extensions.activeThemeID" = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.webextensions.uuids" = "{\"formautofill@mozilla.org\":\"4f10af11-643e-40a7-a274-79e4df067b5c\",\"pictureinpicture@mozilla.org\":\"e8a84674-7f53-4274-bed7-4328d1c9d4b0\",\"screenshots@mozilla.org\":\"edde2344-5865-4dad-8f54-16e6685b4e84\",\"webcompat-reporter@mozilla.org\":\"f77b9e24-736d-4385-9aab-32b4c7ec29c7\",\"webcompat@mozilla.org\":\"03410284-bf65-41f5-9642-dee8ae5ed0e2\",\"firefox-compact-dark@mozilla.org\":\"9c2b97e1-6fb5-47a7-b40c-9b4420678cc8\",\"addons-search-detection@mozilla.com\":\"96ce566e-3912-4e1d-83aa-72b2996f1bf8\",\"@testpilot-containers\":\"e2ff70c4-100a-42fd-bb25-fb11c7fd3ddf\",\"{d7742d87-e61d-4b78-b8a1-b469842139fa}\":\"e3a66770-d4a3-442b-bab1-d5b9d5bcbaeb\",\"{e855175b-f84a-429d-85d6-a61831c8291c}\":\"f19610e3-48be-4789-8ef5-46dca71d2e95\",\"default-theme@mozilla.org\":\"9344fc45-63cb-41d8-9e5a-af4bca9c053e\",\"{446900e4-71c2-419f-a6a7-df9c091e268b}\":\"ce82d1a9-9a96-4277-b522-12712d793f44\",\"firefox@ghostery.com\":\"251544a9-c79e-4961-bb94-ddc1aa02218e\",\"firefox-compact-light@mozilla.org\":\"c523f473-edac-4fd2-b6a2-f3333ad3c7d9\",\"{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}\":\"8011508f-b4c2-464c-bec8-d346a2a298a7\"}";
          "font.minimum-size.x-western" = 16;
          "font.name.serif.x-western" = "MesloLGL Nerd Font";
          "general.autoScroll" = false;
          "network.http.windows-sso.container-enabled.2" = true;
          "network.http.windows-sso.enabled" = true;
          "pref.browser.homepage.disable_button.bookmark_page" = false;
          "pref.privacy.disable_button.cookie_exceptions" = false;
          "pref.privacy.disable_button.view_passwords" = false;
          "privacy.clearHistory.cookiesAndStorage" = false;
          "privacy.clearHistory.siteSettings" = true;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearSiteData.historyFormDataAndDownloads" = true;
          "privacy.clearSiteData.siteSettings" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.was_ever_enabled" = true;
          "privacy.history.custom" = true;
          "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
          "sidebar.position_start" = false;
          "signon.rememberSignons" = false;
          "uc.essentials.box-like-corners" = false;
          "uc.essentials.gap" = "";
          "uc.essentials.width" = "";
          "uc.fixcontext.extensionmargins" = true;
          "uc.hidecontext.bookmark" = true;
          "uc.hidecontext.closetab" = true;
          "uc.hidecontext.inspect" = true;
          "uc.hidecontext.movetaboptions" = true;
          "uc.hidecontext.mutetab" = false;
          "uc.hidecontext.newcontainer" = false;
          "uc.hidecontext.newtab" = true;
          "uc.hidecontext.reloadtab" = false;
          "uc.hidecontext.selectalltabs" = false;
          "uc.hidecontext.sendtodevice" = false;
          "uc.hidecontext.separators" = true;
          "uc.hidecontext.unloadactions" = true;
          "uc.pins.bg" = true;
          "uc.pins.essentials-layout" = false;
          "uc.pins.hide-reset-button" = false;
          "uc.pins.legacy-layout" = false;
          "uc.superpins.border" = "";
          "ui.osk.debug.keyboardDisplayReason" = "IKPOS: Touch screen not found.";
          "zen.glance.activation-method" = "ctrl";
          "zen.keyboard.shortcuts.version" = 8;
          "zen.migration.version" = 1;
          "zen.pinned-tab-manager.close-shortcut-behavior" = "reset-unload-switch";
          "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
          "zen.sidebar.close-on-blur" = false;
          "zen.splitView.change-on-hover" = true;
          "zen.tab-unloader.timeout-minutes" = 5;
          "zen.theme.pill-button" = true;
          "zen.themes.disable-all" = false;
          "zen.themes.updated-value-observer" = true;
          "zen.urlbar.behavior" = "float";
          "zen.view.compact" = true;
          "zen.view.show-bottom-border" = true;
          "zen.view.sidebar-expanded.on-hover" = false;
          "zen.welcome-screen.seen" = true;
          "zen.workspaces.active" = "bad0ab6c-eb3f-4d02-91d9-5ea89b1b6a08";
          "zen.workspaces.container-specific-essentials-enabled" = true;
          "zen.workspaces.force-container-workspace" = true;
          "zen.workspaces.hide-deactivated-workspaces" = true;
          "zen.workspaces.hide-default-container-indicator" = false;
        };
      };
    };
  };
}
