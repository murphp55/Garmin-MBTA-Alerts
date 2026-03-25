# MBTA Alerts (Garmin Connect IQ)

## Quickstart
1. Install Connect IQ SDK & simulator.
2. Set your `developer_key`.
3. Build & run:
   ```powershell
   ./build.ps1 -DeviceId fenix7
   ```

## Simple Desktop UI (Tkinter)
Run a basic desktop UI that shows nearby stations/platforms and live predictions.

```powershell
python .\desktop_ui.py
```

Notes:
- The MBTA API key is read from `desktop_ui_settings.json` (no UI entry).
- Nearby stops uses `resources\mbta_stops.json` plus the latitude/longitude values in `desktop_ui_settings.json`.

## How the Garmin App Works (User View + Example)
High level:
- Open the app and choose "Nearby Stations" to see nearby stations.
- Select a station, then a platform to view live prediction times for that stop.
- The MBTA API key is embedded in the app configuration, so users do not need to enter it.

Example use case:
1. You commute on the Red Line from Davis toward Alewife.
2. Open the app and choose "Nearby Stations".
3. Select "Davis" and then the Alewife-bound platform.
4. The app shows the next trains and minutes away for that platform.
## TODOs (Session Notes)
- Fix prediction time parsing robustly without unsupported String methods; confirm minutes-away works on device.
- Verify predictions view rendering/scrolling with full train list; consider limiting to next N trains.
- Decide on logging visibility (terminal only vs in-app log view) and implement if needed.
- Clean up debug logging once stable (or gate behind a flag).
- Revisit local stops JSON update flow (script/command to refresh and keep size manageable).
- Remove hardcoded API key before committing and restore settings-based config.
- Confirm nearby stations list layout (colors text tags, platform screen UX) is final.
