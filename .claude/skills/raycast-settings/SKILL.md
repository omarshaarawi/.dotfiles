---
name: raycast-settings
description: "Read or change Raycast Beta's settings programmatically (they live in encrypted SQLite that only Raycast's own engine can open). Use when the user wants to view or modify Raycast configuration — appearance/theme, global hotkey, window mode, pop-to-root timeout, open-at-login, menu-bar visibility, navigation bindings, hyper key, favicon provider, MCP servers, per-command settings, or any user_defaults value. Trigger phrases: 'change my Raycast setting', 'set Raycast appearance/hotkey/window mode', 'read my Raycast settings', 'what's my Raycast X set to', 'toggle Raycast open at login', 'edit Raycast config'."
---

# raycast-settings — read/write Raycast Beta's encrypted settings

Raycast Beta stores settings in **fully page-encrypted** SQLite DBs (custom
SQLite3MultipleCiphers cipher, 12 reserved bytes/page) under
`~/Library/Application Support/com.raycast-x.macos/`. No off-the-shelf SQLite tool
can open them — only Raycast's own Rust napi addon, which the CLI here drives.

**Tool:** `~/git/setup/raycast-settings-agent/raycast-settings.cjs` (Node CJS).
Full docs + key facts: `~/git/setup/raycast-settings-agent/README.md`.

## When to use

- User wants to **read** a Raycast setting ("what's my pop-to-root timeout?", "show my Raycast settings", "list my MCP servers").
- User wants to **change** a Raycast setting ("set appearance to dark", "turn off open at login", "change window mode to default").

If the user is talking about Raycast *v2 stable* (`com.raycast.macos`, not Beta) this tool is pointed at Beta — confirm before using.

## How to run

```sh
cd ~/git/setup/raycast-settings-agent
```

### Reads (safe anytime — even while Raycast is running; run on a temp copy)

```sh
node raycast-settings.cjs status                 # DB health + key check
node raycast-settings.cjs get general            # all general settings (default)
node raycast-settings.cjs get mcp                # MCP servers
node raycast-settings.cjs get commands           # per-command settings
node raycast-settings.cjs get extensions         # node-extension settings
node raycast-settings.cjs ud-get <key>           # a user_defaults value
node raycast-settings.cjs list-types             # settable Types + current values (for `set`)
node raycast-settings.cjs list-commands [filter] # command ids + hotkeys (for `hotkey-set`)
node raycast-settings.cjs hotkey-list            # all command hotkeys (chord + command id)
node raycast-settings.cjs mcp-list               # MCP servers
node raycast-settings.cjs apply-hyper-layout --dry-run   # preview the Hyper-key scheme
```

### Writes (need Raycast quit; `--restart` auto quits + relaunches)

```sh
node raycast-settings.cjs set <Type> <jsonValue> --restart
node raycast-settings.cjs ud-set <key> <jsonValue> --restart
node raycast-settings.cjs ud-delete <key> --restart

# command hotkeys
node raycast-settings.cjs hotkey-set <commandId> <chord> --restart   # add or update
node raycast-settings.cjs hotkey-clear <commandId> --restart
node raycast-settings.cjs apply-hyper-layout --restart               # built-in scheme

# themes (no special cmd — use the theme id)
node raycast-settings.cjs set ThemeLightId '"<id>"' --restart
node raycast-settings.cjs set ThemeDarkId  '"<id>"' --restart

# MCP servers
node raycast-settings.cjs mcp-upsert '<json>' --restart

# extensions / aliases / cloud sync / themes
node raycast-settings.cjs ext-list                                   # (read) extensions + on/off
node raycast-settings.cjs ext-disable <extId> --restart              # ext-enable / ext-pref <id> <key> <json>
node raycast-settings.cjs alias-set <commandId> <alias> --restart    # alias-clear / cmd-enable / cmd-disable
node raycast-settings.cjs cloud-sync                                 # (read); cloud-sync-set <bool> --restart
node raycast-settings.cjs theme-list                                 # (read); theme-add '<json>' / theme-rm <id>

# anything else (content: snippets, quicklinks, notes, ai, clipboard, calculator, ...)
node raycast-settings.cjs repos                                      # list repositories
node raycast-settings.cjs repo <repo> [method] [json...]             # e.g. repo snippets list ; repo quicklinks insertOne '<json>' --restart
```

Coverage: General/Launcher/Keyboard/Advanced (`set`/`list-types`), Shortcuts
(`hotkey-*`), aliases & enable/disable (`alias-*`/`cmd-*`/`ext-*`), MCP, Cloud
Sync, themes, and ALL content repos via `repo`. Read methods (all/list/get/count/
search) are safe anytime; everything else needs Raycast quit (`--restart`).

**Hotkeys:** run `hotkey-list` to find the `commandId` (e.g.
`c:r:window-management::-::leftHalf`, `c:r:applications::*::application::=::/Applications/Ghostty.app`).
**Chords:** `hyper` (= Ctrl+Alt+Meta, this user's Hyper key), `cmd`, `ctrl`,
`alt`, `shift`, `meh` + a key, e.g. `hyper+h`, `shift+hyper+m`,
`ctrl+alt+meta+return`. `apply-hyper-layout` writes the user's standard scheme
(apps→Hyper+G/Z/S/D, halves→H/L/J/K, maximize→Return, quarters→U/I/N/M);
edit `HYPER_LAYOUT` in the .cjs to change it.

Examples:
```sh
node raycast-settings.cjs set Appearance '"dark"' --restart
node raycast-settings.cjs set OpenAtLogin false --restart
node raycast-settings.cjs set PopToRootTimeout 60 --restart
```

## Rules

1. **Always `get general` first** before a write, to confirm the exact Type name
   and current value, and to echo the before/after to the user.
2. Setting **Types** are PascalCase keys from `get general`, e.g.: `Appearance`,
   `GlobalHotkey`, `OpenAtLogin`, `ShowInMenuBar`, `WindowMode`,
   `WindowActivationBehavior`, `PopToRootTimeout`, `NavigationBindings`,
   `PageNavigationKeys`, `RootSearchSensitivity`, `EscapeKeyBehavior`,
   `EscapeKeyClosesWindow`, `FaviconProvider`, `BuiltinHotkeysPreset`,
   `HyperKeyCode`, `HyperKeyCapsLockAction`, `HyperKeyIncludeShift`,
   `AdditionalCertificateAuthorities`, `UseSystemProxySettings`.
3. `value` is **JSON**: `'"dark"'` (string), `60` (number), `false` (bool), or a
   nested object (e.g. `GlobalHotkey`). Mirror the shape from `get general`.
4. **Writes quit Raycast.** Use `--restart` so it relaunches. Warn the user it
   will briefly restart Raycast. Without `--restart` the tool refuses while
   Raycast is running.
5. After a write, re-run `get general` (or the relevant `get`) to confirm it
   stuck, and report the new value.
6. If `status` reports a **key mismatch** (Raycast rotated the DB key, or after a
   Raycast upgrade), run `node raycast-settings.cjs capture-key` — it restarts
   Raycast once, captures the key, and stores it in the keychain automatically.

## Notes

- Reads never touch live data (they copy the DBs to a temp dir first).
- Verified: after a `--restart` write, Raycast keeps the externally-written value.
- The DB key is in the login keychain (`raycast-edit` / `com.raycast-x.macos`),
  put there by `capture-key`; override with `RAYCAST_EDIT_KEY`. It is NOT a plain
  keychain value Raycast exposes — it's captured from Raycast's backend at launch.
- This tool is also packaged for OSS as `raycast-edit` (npm/npx); the local skill
  invokes it as `node raycast-settings.cjs`.
