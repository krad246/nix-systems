# Zen Home-Manager Bundle

Artifacts:
- `zen-hm-zen-profile.nix` — drop-in module using only Home-Manager's programs.firefox + home.file.
- `zen-prefs.nix` — ~360 prefs extracted from your profile.
- `profiles/zen/qnu52oxt.keerad/zen-keyboard-shortcuts.json` — Zen keybindings (if present).
- `profiles/zen/qnu52oxt.keerad/zen-themes.json` — Zen themes (if present).
- `profiles/zen/qnu52oxt.keerad/chrome/zen-themes.css` — Zen theme CSS (if present).
- `profiles.ini` — written to ~/.zen via Home-Manager to set default profile.

Usage:

1. Copy this folder into your repo, e.g. `profiles/zen-bundle/`.
2. In your `home.nix`:
   ```nix
   {
     imports = [ ./profiles/zen-bundle/zen-hm-zen-profile.nix ];
   }
   ```
3. If `home-manager switch` complains about `package = lib.mkForce null;`, delete that line and let HM install Firefox.
4. Zen will use the profile at `~/.zen/nix.default-release/`. The declared files are replaced on each switch.
