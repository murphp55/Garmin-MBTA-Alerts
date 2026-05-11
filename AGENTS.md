# Garmin-MBTA-Alerts — Agent Notes

## One-liner
Garmin Connect IQ smartwatch app (Monkey C, Fenix 7) for real-time MBTA predictions, with a Python/Tkinter desktop testing UI.

## Run it
```powershell
# Smartwatch (Windows + Connect IQ SDK 8.2.3 required, developer_key.der at repo root)
.\build.ps1 -DeviceId fenix7
# Outputs bin\app.prg + bin\app.iq, then auto-launches the simulator via monkeydo.

# Desktop test UI
python desktop_ui.py
```

## Where we are right now
- Last touched: 2026-04-16 (commit 6dec153 "Sync uncommitted changes")
- Working on: Dormant — no recent activity. Repo is post-prototype, feature-complete, pre-release.
- Known broken: Nothing known. `git status` shows one unstaged tweak to `ReadMe.md` (note: actual file is `README.md` — Windows is case-insensitive but be aware).

*This section goes stale fast. Check `git log -5` and `git status` before trusting it.*

## Gotchas
- MBTA API key is hardcoded in `resources/properties.xml` (and referenced by `desktop_ui.py`). Don't commit a new key; this needs externalization before any store release.
- `build.ps1` hardcodes SDK path `%APPDATA%\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.2.3-*\bin`. Other SDK versions won't be picked up.
- `developer_key.der` is required at repo root (or `%APPDATA%\Garmin\ConnectIQ\`) — gitignored, must be generated locally via SDK manager.
- `resources/mbta_stops.json` (~77KB, 3,700+ stops) is manually synced from MBTA API — no script exists to refresh it.
- Build only targets Windows (PowerShell + Garmin SDK Windows layout). Desktop UI runs cross-platform.
- Monkey C has no `String.split` and limited formatting — don't reach for stdlib idioms.

## Non-obvious conventions
- Two languages, two worlds: smartwatch logic lives in `resources/source/*.mc` (Monkey C); `desktop_ui.py` is a standalone test harness, not a shared module.
- `monkey.jungle` is the Connect IQ build manifest — edit it (not a Makefile) to change sources/resources.
- Layouts/strings/settings are XML under `resources/` per Connect IQ conventions.

See README.md for project description, tech stack, and feature list.
