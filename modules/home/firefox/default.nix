{
  withSystem,
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    enableGnomeExtensions = lib.modules.mkIf pkgs.stdenv.isLinux true;

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

        extensions = withSystem pkgs.stdenv.system ({inputs', ...}:
          with inputs'.nur.legacyPackages.repos; [
            rycee.firefox-addons.bitwarden
            rycee.firefox-addons.ghostery
            rycee.firefox-addons.multi-account-containers
            rycee.firefox-addons.tab-retitle
            rycee.firefox-addons.vimium
          ]);

        search = {
          default = "DuckDuckGo";
          privateDefault = "DuckDuckDuckGo";

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
          "app.installation.timestamp" = "133834157218590900";
          "app.normandy.first_run" = false;
          "app.normandy.migrationsApplied" = 12;
          "app.normandy.user_id" = "4447558c-eeac-4011-bfd2-a8d332218cd2";
          "app.update.auto.migrated" = true;
          "app.update.background.previous.reasons" = "[\"app.update.auto=false\",\"on Windows but cannot usually use BITS\",\"the maintenance service registry key is not present\"]";
          "app.update.background.rolledout" = true;
          "app.update.disable_button.showUpdateHistory" = false;
          "app.update.download.attempts" = 0;
          "app.update.elevate.attempts" = 0;
          "app.update.lastUpdateTime.addon-background-update-timer" = 1739373606;
          "app.update.lastUpdateTime.background-update-timer" = 1739389979;
          "app.update.lastUpdateTime.browser-cleanup-thumbnails" = 1739393699;
          "app.update.lastUpdateTime.region-update-timer" = 1738858604;
          "app.update.lastUpdateTime.services-settings-poll-changes" = 1739373606;
          "app.update.lastUpdateTime.suggest-ingest" = 1739373606;
          "app.update.lastUpdateTime.xpi-signature-verification" = 1739373606;
          "app.update.migrated.updateDir3.F0DC299D809B9700" = true;
          "browser.bookmarks.defaultLocation" = "menu________";
          "browser.bookmarks.editDialog.confirmationHintShowCount" = 3;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.contentblocking.category" = "standard";
          "browser.contextual-services.contextId" = "{4abdcfab-f2e5-44a4-9aa9-8db4740e85b3}";
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "browser.download.lastDir" = "C:\\Users\\keerad\\Downloads";
          "browser.download.panel.shown" = true;
          "browser.download.viewableInternally.typeWasRegistered.avif" = true;
          "browser.download.viewableInternally.typeWasRegistered.jxl" = true;
          "browser.download.viewableInternally.typeWasRegistered.webp" = true;
          "browser.engagement.ctrlTab.has-used" = true;
          "browser.engagement.downloads-button.has-used" = true;
          "browser.engagement.home-button.has-removed" = true;
          "browser.engagement.home-button.has-used" = true;
          "browser.firefox-vifew.feature-tour" = "{\"screen\":\"\",\"complete\":true}";
          "browser.formfill.enable" = true;
          "browser.laterrun.bookkeeping.profileCreationTime" = 1736439205;
          "browser.laterrun.bookkeeping.sessionCount" = 1;
          "browser.launcherProcess.enabled" = true;
          "browser.migrate.interactions.bookmarks" = true;
          "browser.migrate.interactions.history" = true;
          "browser.migrate.interactions.passwords" = true;
          "browser.migration.version" = 150;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = true;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = true;
          "browser.newtabpage.activity-stream.impressionId" = "{56290c98-df89-43a9-a1a8-933d173a12d4}";
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "google";
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.pinned" = "[{\"url\":\"https://google.com\",\"label\":\"@google\",\"searchTopSite\":true}]";
          "browser.newtabpage.storageVersion" = 1;
          "browser.open.lastDir" = "C:\\Users\\keerad\\OneDrive - ASSA ABLOY Group\\Documents";
          "browser.pageActions.persistedActions" = "{\"ids\":[\"bookmark\",\"_testpilot-containers\"],\"idsInUrlbar\":[\"_testpilot-containers\",\"bookmark\"],\"idsInUrlbarPreProton\":[],\"version\":1}";
          "browser.pagethumbnails.storage_version" = 3;
          "browser.protections_panel.infoMessage.seen" = true;
          "browser.proton.toolbar.version" = 3;
          "browser.region.update.updated" = 1738858605;
          "browser.rights.3.shown" = true;
          "browser.safebrowsing.provider.mozilla.lastupdatetime" = "1739389950321";
          "browser.safebrowsing.provider.mozilla.nextupdatetime" = "1739411550321";
          "browser.search.region" = "US";
          "browser.search.serpEventTelemetryCategorization.regionEnabled" = true;
          "browser.search.suggest.enabled" = true;
          "browser.search.totalSearches" = 101;
          "browser.sessionstore.upgradeBackup.latestBuildID" = "20250207070754";
          "browser.shell.mostRecentDateSetAsDefault" = "1739383465";
          "browser.startup.couldRestoreSession.count" = 2;
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.startup.homepage_override.buildID" = "20250207070754";
          "browser.startup.homepage_override.mstone" = "135.0";
          "browser.startup.lastColdStartupCheck" = 1739383465;
          "browser.startup.page" = 1;
          "browser.startup.windowsLaunchOnLogin.disableLaunchOnLoginPrompt" = true;
          "browser.tabs.inTitlebar" = 1;
          "browser.tabs.loadBookmarksInTabs" = true;
          "browser.taskbar.previews.enable" = true;
          "browser.theme.toolbar-theme" = 0;
          "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"firefox_ghostery_com-browser-action\",\"_testpilot-containers-browser-action\",\"_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action\",\"_e855175b-f84a-429d-85d6-a61831c8291c_-browser-action\",\"gsconnect_andyholmes_github_io-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"vertical-spacer\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"wrapper-sidebar-button\",\"unified-extensions-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"personal-bookmarks\"],\"zen-sidebar-top-buttons\":[],\"zen-sidebar-icons-wrapper\":[\"zen-profile-button\",\"zen-workspaces-button\",\"downloads-button\"]},\"seen\":[\"developer-button\",\"_testpilot-containers-browser-action\",\"_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action\",\"_e855175b-f84a-429d-85d6-a61831c8291c_-browser-action\",\"gsconnect_andyholmes_github_io-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"firefox_ghostery_com-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"zen-sidebar-icons-wrapper\",\"PersonalToolbar\",\"toolbar-menubar\",\"TabsToolbar\",\"zen-sidebar-top-buttons\",\"unified-extensions-area\"],\"currentVersion\":21,\"newElementCount\":2}";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.urlbar.quicksuggest.migrationVersion" = 2;
          "browser.urlbar.quicksuggest.scenario" = "offline";
          "browser.urlbar.recentsearches.lastDefaultChanged" = "1738943397145";
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = true;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.tabToSearch.onboard.interactionsLeft" = 0;
          "browser.urlbar.tipShownCount.searchTip_onboard" = 4;
          "browser.zoom.full" = false;
          "captchadetection.lastSubmission" = 1738941;
          "cfs.font.size.footer" = "1.5em";
          "cfs.font.size.searchbar" = "1.4em";
          "cfs.font.size.tabbar.tabs" = "1.3em";
          "cfs.font.size.workspace.title" = "1.5em";
          "datareporting.dau.cachedUsageProfileID" = "beefbeef-beef-beef-beef-beeefbeefbee";
          "devtools.everOpened" = true;
          "devtools.netmonitor.columnsData" = "[{\"name\":\"status\",\"minWidth\":30,\"width\":5.56},{\"name\":\"method\",\"minWidth\":30,\"width\":5.56},{\"name\":\"domain\",\"minWidth\":30,\"width\":11.11},{\"name\":\"file\",\"minWidth\":30,\"width\":27.78},{\"name\":\"url\",\"minWidth\":30,\"width\":25},{\"name\":\"initiator\",\"minWidth\":30,\"width\":11.11},{\"name\":\"type\",\"minWidth\":30,\"width\":5.56},{\"name\":\"transferred\",\"minWidth\":30,\"width\":11.11},{\"name\":\"contentSize\",\"minWidth\":30,\"width\":5.56},{\"name\":\"waterfall\",\"minWidth\":150,\"width\":16.67}]";
          "devtools.netmonitor.msg.visibleColumns" = "[\"data\",\"time\"]";
          "devtools.toolbox.selectedTool" = "netmonitor";
          "devtools.toolsidebar-height.inspector" = 350;
          "devtools.toolsidebar-width.inspector" = 700;
          "devtools.toolsidebar-width.inspector.splitsidebar" = 350;
          "distribution.iniFile.exists.appversion" = "1.7.5b";
          "distribution.iniFile.exists.value" = false;
          "doh-rollout.doneFirstRun" = true;
          "doh-rollout.home-region" = "US";
          "doh-rollout.mode" = 0;
          "doh-rollout.self-enabled" = true;
          "doh-rollout.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
          "dom.forms.autocomplete.formautofill" = true;
          "dom.push.userAgentID" = "ce5f9879bc454c99bea8fdd7121e4c2c";
          "dom.security.https_only_mode_ever_enabled" = true;
          "extensions.activeThemeID" = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
          "extensions.blocklist.pingCountVersion" = -1;
          "extensions.databaseSchema" = 37;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.formautofill.creditCards.reauth.optout" = "MDIEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECFflGDA+JCQdBAgifEiNQ/hDhg==";
          "extensions.getAddons.cache.lastUpdate" = 1739373606;
          "extensions.getAddons.databaseSchema" = 6;
          "extensions.lastAppBuildId" = "20250207070754";
          "extensions.lastAppVersion" = "1.7.5b";
          "extensions.lastPlatformVersion" = "135.0";
          "extensions.pendingOperations" = false;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
          "extensions.quarantineIgnoredByUser.{d7742d87-e61d-4b78-b8a1-b469842139fa}" = false;
          "extensions.quarantinedDomains.list" = "autoatendimento.bb.com.br,ibpf.sicredi.com.br,ibpj.sicredi.com.br,internetbanking.caixa.gov.br,www.ib12.bradesco.com.br,www2.bancobrasil.com.br";
          "extensions.systemAddonSet" = "{\"schema\":1,\"addons\":{}}";
          "extensions.ui.dictionary.hidden" = true;
          "extensions.ui.extension.hidden" = false;
          "extensions.ui.lastCategory" = "addons://list/theme";
          "extensions.ui.locale.hidden" = true;
          "extensions.ui.sitepermission.hidden" = true;
          "extensions.ui.theme.hidden" = false;
          "extensions.webcompat.enable_shims" = true;
          "extensions.webcompat.perform_injections" = true;
          "extensions.webcompat.perform_ua_overrides" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.@testpilot-containers" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.firefox@ghostery.com" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.screenshots@mozilla.org" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.{446900e4-71c2-419f-a6a7-df9c091e268b}" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.{d7742d87-e61d-4b78-b8a1-b469842139fa}" = true;
          "extensions.webextensions.ExtensionStorageIDB.migrated.{e855175b-f84a-429d-85d6-a61831c8291c}" = true;
          "extensions.webextensions.uuids" = "{\"formautofill@mozilla.org\":\"4f10af11-643e-40a7-a274-79e4df067b5c\",\"pictureinpicture@mozilla.org\":\"e8a84674-7f53-4274-bed7-4328d1c9d4b0\",\"screenshots@mozilla.org\":\"edde2344-5865-4dad-8f54-16e6685b4e84\",\"webcompat-reporter@mozilla.org\":\"f77b9e24-736d-4385-9aab-32b4c7ec29c7\",\"webcompat@mozilla.org\":\"03410284-bf65-41f5-9642-dee8ae5ed0e2\",\"firefox-compact-dark@mozilla.org\":\"9c2b97e1-6fb5-47a7-b40c-9b4420678cc8\",\"addons-search-detection@mozilla.com\":\"96ce566e-3912-4e1d-83aa-72b2996f1bf8\",\"@testpilot-containers\":\"e2ff70c4-100a-42fd-bb25-fb11c7fd3ddf\",\"{d7742d87-e61d-4b78-b8a1-b469842139fa}\":\"e3a66770-d4a3-442b-bab1-d5b9d5bcbaeb\",\"{e855175b-f84a-429d-85d6-a61831c8291c}\":\"f19610e3-48be-4789-8ef5-46dca71d2e95\",\"default-theme@mozilla.org\":\"9344fc45-63cb-41d8-9e5a-af4bca9c053e\",\"{446900e4-71c2-419f-a6a7-df9c091e268b}\":\"ce82d1a9-9a96-4277-b522-12712d793f44\",\"firefox@ghostery.com\":\"251544a9-c79e-4961-bb94-ddc1aa02218e\",\"firefox-compact-light@mozilla.org\":\"c523f473-edac-4fd2-b6a2-f3333ad3c7d9\",\"{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}\":\"8011508f-b4c2-464c-bec8-d346a2a298a7\"}";
          "findbar.entireword" = true;
          "findbar.highlightAll" = false;
          "font.minimum-size.x-western" = 16;
          "font.name.serif.x-western" = "MesloLGL Nerd Font";
          "gecko.handlerService.defaultHandlersVersion" = 1;
          "general.autoScroll" = false;
          "gfx-shader-check.build-version" = "20250207070754";
          "gfx-shader-check.device-id" = "0xa7a0";
          "gfx-shader-check.driver-version" = "31.0.101.5186";
          "gfx-shader-check.ptr-size" = 8;
          "identity.fxaccounts.account.device.name" = "keerad’s Zen on USNEWL-GG4XDY3";
          "identity.fxaccounts.account.telemetry.sanitized_uid" = "d90522b35b7d172914596c40c2504499";
          "identity.fxaccounts.commands.missed.last_fetch" = 1739374915;
          "identity.fxaccounts.lastSignedInUserHash" = "SDfyHE6G5xyV1l3GpjjanmTfA252KbQyiX+0TygrFpk=";
          "idle.lastDailyNotification" = 1739376180;
          "layout.css.always_underline_links" = true;
          "media.gmp-gmpopenh264.abi" = "x86_64-msvc-x64";
          "media.gmp-gmpopenh264.hashValue" = "b667086ed49579592d435df2b486fe30ba1b62ddd169f19e700cd079239747dd3e20058c285fa9c10a533e34f22b5198ed9b1f92ae560a3067f3e3feacc724f1";
          "media.gmp-gmpopenh264.lastDownload" = 1736439236;
          "media.gmp-gmpopenh264.lastInstallStart" = 1736439236;
          "media.gmp-gmpopenh264.lastUpdate" = 1736439236;
          "media.gmp-gmpopenh264.version" = "2.3.2";
          "media.gmp-manager.buildID" = "20250207070754";
          "media.gmp-manager.lastCheck" = 1739368621;
          "media.gmp-manager.lastEmptyCheck" = 1739368621;
          "media.gmp-widevinecdm.abi" = "x86_64-msvc-x64";
          "media.gmp-widevinecdm.hashValue" = "03105dcf804e4713b6ed7c281ad0343ac6d6eb2aed57a897c6a09515a8c7f3e06b344563e224365dc9159cfd8ed3ef665d6aec18cc07aaad66eed0dc4957dde3";
          "media.gmp-widevinecdm.lastDownload" = 1736439236;
          "media.gmp-widevinecdm.lastInstallStart" = 1736439236;
          "media.gmp-widevinecdm.lastUpdate" = 1736439237;
          "media.gmp-widevinecdm.version" = "4.10.2830.0";
          "media.gmp.storage.version.observed" = 1;
          "media.hardware-video-decoding.failed" = false;
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          "network.http.windows-sso.container-enabled.2" = true;
          "network.http.windows-sso.enabled" = true;
          "pdfjs.enabledCache.state" = true;
          "pdfjs.migrationVersion" = 2;
          "places.database.lastMaintenance" = 1739201612;
          "pref.browser.homepage.disable_button.bookmark_page" = false;
          "pref.privacy.disable_button.cookie_exceptions" = false;
          "pref.privacy.disable_button.view_passwords" = false;
          "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
          "privacy.clearHistory.cookiesAndStorage" = false;
          "privacy.clearHistory.siteSettings" = true;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearSiteData.historyFormDataAndDownloads" = true;
          "privacy.clearSiteData.siteSettings" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.was_ever_enabled" = true;
          "privacy.history.custom" = true;
          "privacy.purge_trackers.date_in_cookie_database" = "0";
          "privacy.purge_trackers.last_purge" = "1738592450319";
          "privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs2" = true;
          "privacy.sanitize.cpd.hasMigratedToNewPrefs2" = true;
          "privacy.sanitize.pending" = "[{\"id\":\"shutdown\",\"itemsToClear\":[\"historyFormDataAndDownloads\"],\"options\":{}},{\"id\":\"newtab-container\",\"itemsToClear\":[],\"options\":{}}]";
          "privacy.sanitize.sanitizeOnShutdown" = true;
          "privacy.sanitize.timeSpan" = 0;
          "privacy.userContext.extension" = "@testpilot-containers";
          "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
          "sanity-test.device-id" = "0xa7a0";
          "sanity-test.driver-version" = "31.0.101.5186";
          "sanity-test.running" = false;
          "sanity-test.version" = "20250207070754";
          "security.webauthn.show_ms_settings_link" = true;
          "services.settings.blocklists.addons-bloomfilters.last_check" = 1739390664;
          "services.settings.blocklists.gfx.last_check" = 1739390664;
          "services.settings.clock_skew_seconds" = 12;
          "services.settings.last_etag" = "\"1739393975196\"";
          "services.settings.last_update_seconds" = 1739394269;
          "services.settings.main.addons-manager-settings.last_check" = 1739390664;
          "services.settings.main.anti-tracking-url-decoration.last_check" = 1739390664;
          "services.settings.main.bounce-tracking-protection-exceptions.last_check" = 1739390664;
          "services.settings.main.cfr.last_check" = 1739390664;
          "services.settings.main.cookie-banner-rules-list.last_check" = 1739390664;
          "services.settings.main.devtools-compatibility-browsers.last_check" = 1739390664;
          "services.settings.main.devtools-devices.last_check" = 1739390664;
          "services.settings.main.doh-config.last_check" = 1739390664;
          "services.settings.main.doh-providers.last_check" = 1739390664;
          "services.settings.main.fingerprinting-protection-overrides.last_check" = 1739390664;
          "services.settings.main.fxmonitor-breaches.last_check" = 1739390664;
          "services.settings.main.hijack-blocklists.last_check" = 1739390664;
          "services.settings.main.language-dictionaries.last_check" = 1739390664;
          "services.settings.main.message-groups.last_check" = 1739390664;
          "services.settings.main.newtab-wallpapers-v2.last_check" = 1739390664;
          "services.settings.main.normandy-recipes-capabilities.last_check" = 1739390664;
          "services.settings.main.partitioning-exempt-urls.last_check" = 1739390664;
          "services.settings.main.password-recipes.last_check" = 1739390664;
          "services.settings.main.password-rules.last_check" = 1739390664;
          "services.settings.main.public-suffix-list.last_check" = 1739390664;
          "services.settings.main.query-stripping.last_check" = 1739390664;
          "services.settings.main.search-categorization.last_check" = 1739390664;
          "services.settings.main.search-config-icons.last_check" = 1739390664;
          "services.settings.main.search-config-overrides-v2.last_check" = 1739390664;
          "services.settings.main.search-config-v2.last_check" = 1739390664;
          "services.settings.main.search-default-override-allowlist.last_check" = 1739390664;
          "services.settings.main.search-telemetry-v2.last_check" = 1739390664;
          "services.settings.main.sites-classification.last_check" = 1739390664;
          "services.settings.main.tippytop.last_check" = 1739390664;
          "services.settings.main.top-sites.last_check" = 1739390664;
          "services.settings.main.tracking-protection-lists.last_check" = 1739390664;
          "services.settings.main.translations-models.last_check" = 1739390664;
          "services.settings.main.translations-wasm.last_check" = 1739390664;
          "services.settings.main.url-classifier-skip-urls.last_check" = 1739390664;
          "services.settings.main.url-parser-default-unknown-schemes-interventions.last_check" = 1739390664;
          "services.settings.main.urlbar-persisted-search-terms.last_check" = 1739390664;
          "services.settings.main.websites-with-shared-credential-backends.last_check" = 1739390664;
          "services.settings.security-state.cert-revocations.last_check" = 1739390664;
          "services.settings.security-state.intermediates.last_check" = 1739390664;
          "services.settings.security-state.onecrl.last_check" = 1739390664;
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
