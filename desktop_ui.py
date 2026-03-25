import json
import math
import os
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
import tkinter as tk
from tkinter import messagebox, ttk


APP_TITLE = "MBTA Stations (Desktop)"
BASE_URL = "https://api-v3.mbta.com"
CONFIG_PATH = os.path.join(os.path.dirname(__file__), "desktop_ui_settings.json")
STOPS_PATH = os.path.join(os.path.dirname(__file__), "resources", "mbta_stops.json")


def load_config():
    cfg = {
        "mbtaApiKey": "",
        "radiusMeters": "1000",
        "maxStops": "10",
        "latitude": "42.3860278",
        "longitude": "-71.1123611",
    }
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                saved = json.load(f)
            if isinstance(saved, dict):
                cfg.update(saved)
        except Exception:
            pass
    return cfg


def save_config(cfg):
    try:
        with open(CONFIG_PATH, "w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2)
    except Exception as exc:
        messagebox.showerror("Error", f"Failed to save settings: {exc}")


def parse_int(value, default=None):
    try:
        if value == "" or value is None:
            return default
        return int(value)
    except ValueError:
        return default


def parse_float(value, default=None):
    try:
        if value == "" or value is None:
            return default
        return float(value)
    except ValueError:
        return default


def iso_to_display(iso):
    if not iso:
        return ""
    try:
        if isinstance(iso, str) and iso.endswith("Z"):
            iso = iso.replace("Z", "+00:00")
        dt = datetime.fromisoformat(iso)
        if dt.tzinfo is None:
            return dt.strftime("%Y-%m-%d %H:%M")
        return dt.astimezone().strftime("%Y-%m-%d %H:%M")
    except Exception:
        return str(iso)


def minutes_from_iso(iso):
    if not iso:
        return None
    try:
        if isinstance(iso, str) and iso.endswith("Z"):
            iso = iso.replace("Z", "+00:00")
        dt = datetime.fromisoformat(iso)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        now = datetime.now(timezone.utc)
        diff = (dt - now).total_seconds() / 60.0
        mins = int(round(diff))
        return max(mins, 0)
    except Exception:
        return None


def distance_miles(lat1, lon1, lat2, lon2):
    pi = math.pi
    to_rad = pi / 180.0
    d_lat = (lat2 - lat1) * to_rad
    d_lon = (lon2 - lon1) * to_rad
    a = math.sin(d_lat / 2.0) ** 2 + math.cos(lat1 * to_rad) * math.cos(lat2 * to_rad) * math.sin(d_lon / 2.0) ** 2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return 3958.7613 * c


def mbta_get(path, params, api_key):
    query = urllib.parse.urlencode(params)
    url = f"{BASE_URL}{path}"
    if query:
        url = f"{url}?{query}"
    req = urllib.request.Request(url, headers={"x-api-key": api_key})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            if resp.status != 200:
                raise RuntimeError(f"HTTP {resp.status}")
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"HTTP {exc.code}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Network error: {exc.reason}") from exc


def fetch_predictions(cfg, stop_id):
    if not cfg["mbtaApiKey"]:
        raise RuntimeError("Missing API key")
    if not stop_id:
        raise RuntimeError("Missing stop id (select a platform first)")
    params = {"filter[stop]": stop_id, "sort": "departure_time"}
    payload = mbta_get("/predictions", params, cfg["mbtaApiKey"])
    items = payload.get("data", []) if isinstance(payload, dict) else []
    out = []
    for item in items:
        attrs = item.get("attributes") or {}
        time_value = attrs.get("arrival_time") or attrs.get("departure_time")
        rel = item.get("relationships") or {}
        route = None
        route_data = (rel.get("route") or {}).get("data")
        if route_data:
            route = route_data.get("id")
        out.append(
            {
                "route": route or "",
                "direction": attrs.get("direction_id"),
                "time": time_value,
                "time_display": iso_to_display(time_value),
                "minutes": minutes_from_iso(time_value),
                "relationship": attrs.get("schedule_relationship") or "",
            }
        )
    return out


def load_local_stops():
    if not os.path.exists(STOPS_PATH):
        raise RuntimeError("Missing resources/mbta_stops.json")
    with open(STOPS_PATH, "r", encoding="utf-8") as f:
        raw = json.load(f)
    if not isinstance(raw, list):
        raise RuntimeError("Invalid stops file format")
    out = []
    for item in raw:
        attrs = item.get("attributes") or {}
        name = attrs.get("name") or item.get("name") or "Station"
        lat = attrs.get("latitude", item.get("latitude"))
        lon = attrs.get("longitude", item.get("longitude"))
        platform = attrs.get("platform_name", item.get("platform_name"))
        parent = attrs.get("parent_station", item.get("parent_station"))
        if parent is None:
            rel = item.get("relationships") or {}
            parent_data = (rel.get("parent_station") or {}).get("data")
            if parent_data:
                parent = parent_data.get("id")
        out.append(
            {
                "id": item.get("id"),
                "name": name,
                "latitude": lat,
                "longitude": lon,
                "platform": platform or "",
                "parent": parent or "",
            }
        )
    return out


def compute_nearby(cfg):
    lat = parse_float(cfg.get("latitude"))
    lon = parse_float(cfg.get("longitude"))
    if lat is None or lon is None:
        raise RuntimeError("Latitude/Longitude required for nearby stops")
    radius_m = parse_int(cfg.get("radiusMeters"), 1000)
    max_stops = parse_int(cfg.get("maxStops"), 10)
    stops = load_local_stops()
    nearby = []
    for s in stops:
        if s["latitude"] is None or s["longitude"] is None:
            continue
        dist_mi = distance_miles(lat, lon, s["latitude"], s["longitude"])
        if radius_m is None or dist_mi * 1609.344 <= radius_m:
            s2 = dict(s)
            s2["distance_miles"] = dist_mi
            nearby.append(s2)
    nearby.sort(key=lambda x: x["distance_miles"])
    if max_stops is not None:
        nearby = nearby[:max_stops]
    return nearby


class DesktopApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.geometry("980x620")

        self.cfg = load_config()
        self.selected_stop_id = None
        self.selected_stop_name = None
        self.refresh_ms = 30_000
        self._build_ui()
        self._schedule_refresh()

    def _build_ui(self):
        self.columnconfigure(0, weight=1)
        self.rowconfigure(0, weight=1)

        self.notebook = ttk.Notebook(self)
        self.notebook.grid(row=0, column=0, sticky="nsew", padx=10, pady=6)

        self.nearby_tab = self._build_nearby_tab()
        self.pred_tab = self._build_predictions_tab()

        status_frame = ttk.Frame(self)
        status_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=6)
        status_frame.columnconfigure(0, weight=1)
        self.status_var = tk.StringVar(value="Ready.")
        ttk.Label(status_frame, textvariable=self.status_var).grid(row=0, column=0, sticky="w")

    def _build_nearby_tab(self):
        tab = ttk.Frame(self.notebook)
        self.notebook.add(tab, text="Nearby Stations")
        tab.columnconfigure(0, weight=1)
        tab.rowconfigure(1, weight=1)

        btn_frame = ttk.Frame(tab)
        btn_frame.grid(row=0, column=0, sticky="w", padx=6, pady=6)
        ttk.Button(btn_frame, text="Find Nearby", command=self._load_nearby).grid(row=0, column=0, padx=3)
        ttk.Button(btn_frame, text="Show Predictions for Selected", command=self._load_predictions_for_selected).grid(
            row=0, column=1, padx=3
        )

        columns = ("name", "distance", "stop_id", "platform")
        self.nearby_tree = ttk.Treeview(tab, columns=columns, show="headings")
        for col, label, width in [
            ("name", "Station", 280),
            ("distance", "Distance (mi)", 120),
            ("stop_id", "Stop ID", 140),
            ("platform", "Platform", 300),
        ]:
            self.nearby_tree.heading(col, text=label)
            self.nearby_tree.column(col, width=width, anchor="w")
        self._add_scrollbar(tab, self.nearby_tree)
        self.nearby_tree.grid(row=1, column=0, sticky="nsew", padx=6, pady=6)
        self.nearby_tree.bind("<Double-1>", self._on_nearby_double_click)
        return tab

    def _build_predictions_tab(self):
        tab = ttk.Frame(self.notebook)
        self.notebook.add(tab, text="Predictions")
        tab.columnconfigure(0, weight=1)
        tab.rowconfigure(1, weight=1)

        btn = ttk.Button(tab, text="Fetch Predictions for Selected", command=self._load_predictions_for_selected)
        btn.grid(row=0, column=0, sticky="w", padx=6, pady=6)

        columns = ("route", "direction", "minutes", "time", "relationship")
        self.pred_tree = ttk.Treeview(tab, columns=columns, show="headings")
        for col, label, width in [
            ("route", "Route", 90),
            ("direction", "Dir", 60),
            ("minutes", "Minutes", 90),
            ("time", "Time", 170),
            ("relationship", "Schedule", 160),
        ]:
            self.pred_tree.heading(col, text=label)
            self.pred_tree.column(col, width=width, anchor="w")
        self._add_scrollbar(tab, self.pred_tree)
        self.pred_tree.grid(row=1, column=0, sticky="nsew", padx=6, pady=6)
        return tab

    def _add_scrollbar(self, parent, tree):
        scroll = ttk.Scrollbar(parent, orient="vertical", command=tree.yview)
        tree.configure(yscrollcommand=scroll.set)
        scroll.grid(row=1, column=1, sticky="ns", pady=6)

    def _get_cfg(self):
        self.cfg = load_config()
        return self.cfg

    def _set_busy(self, busy=True):
        self.config(cursor="watch" if busy else "")
        self.update_idletasks()

    def _load_predictions_for_selected(self):
        stop_id, stop_name = self._get_selected_stop()
        if not stop_id:
            messagebox.showerror("Error", "Select a platform from Nearby Stations first.")
            return
        self._load_predictions(stop_id, stop_name)

    def _load_predictions(self, stop_id, stop_name):
        self._set_busy(True)
        try:
            cfg = self._get_cfg()
            preds = fetch_predictions(cfg, stop_id)
            self.pred_tree.delete(*self.pred_tree.get_children())
            for pred in preds:
                minutes = pred["minutes"]
                minutes_str = "" if minutes is None else str(minutes)
                self.pred_tree.insert(
                    "",
                    "end",
                    values=(
                        pred["route"],
                        pred["direction"],
                        minutes_str,
                        pred["time_display"],
                        pred["relationship"],
                    ),
                )
            if stop_name:
                self.status_var.set(f"Loaded {len(preds)} predictions for {stop_name}.")
            else:
                self.status_var.set(f"Loaded {len(preds)} predictions.")
        except Exception as exc:
            messagebox.showerror("Error", str(exc))
            self.status_var.set("Failed to load predictions.")
        finally:
            self._set_busy(False)

    def _load_nearby(self):
        self._set_busy(True)
        try:
            cfg = self._get_cfg()
            stops = compute_nearby(cfg)
            self.nearby_tree.delete(*self.nearby_tree.get_children())
            for stop in stops:
                dist = stop.get("distance_miles")
                dist_str = "" if dist is None else f"{dist:.2f}"
                self.nearby_tree.insert(
                    "",
                    "end",
                    values=(
                        stop.get("name", ""),
                        dist_str,
                        stop.get("id", ""),
                        stop.get("platform", ""),
                    ),
                )
            self.status_var.set(f"Loaded {len(stops)} nearby stops.")
        except Exception as exc:
            messagebox.showerror("Error", str(exc))
            self.status_var.set("Failed to load nearby stops.")
        finally:
            self._set_busy(False)

    def _get_selected_stop(self):
        selection = self.nearby_tree.selection()
        if not selection:
            return None, None
        values = self.nearby_tree.item(selection[0], "values")
        if not values or len(values) < 3:
            return None, None
        stop_name = values[0]
        stop_id = values[2]
        self.selected_stop_id = stop_id
        self.selected_stop_name = stop_name
        return stop_id, stop_name

    def _on_nearby_double_click(self, event):
        stop_id, stop_name = self._get_selected_stop()
        if stop_id:
            self.notebook.select(self.pred_tab)
            self._load_predictions(stop_id, stop_name)

    def _schedule_refresh(self):
        try:
            current = self.notebook.select()
            if current == str(self.nearby_tab):
                self._load_nearby()
            elif current == str(self.pred_tab):
                if self.selected_stop_id:
                    self._load_predictions(self.selected_stop_id, self.selected_stop_name)
        finally:
            self.after(self.refresh_ms, self._schedule_refresh)


def main():
    app = DesktopApp()
    app.mainloop()


if __name__ == "__main__":
    main()
