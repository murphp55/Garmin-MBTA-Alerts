using Toybox.Position as Position;
using Toybox.Application as App;

class StationsLoader {
    var _cbOk, _cbErr;
    var _maxStops;
    var _lat, _lon;

    function initialize(cbOk, cbErr) {
        _cbOk = cbOk;
        _cbErr = cbErr;
    }

    function load() {
        var cfg = Settings.getConfig();
        if (cfg == null || cfg[:mbtaApiKey] == null) {
            _cbErr.invoke("Missing API key");
            return;
        }
        // TEMP: use a fixed location in the simulator; skip GPS.
        _useFixedLocation();
    }

    function _useFixedLocation() as Void {
        _lat = 42.3860278;
        _lon = -71.1123611;
        _fetchStops();
    }

    function _onPosition(info as Position.Info) as Void {
        if (info == null || info.position == null) {
            _cbErr.invoke("No GPS fix");
            return;
        }

        var coords = info.position.toDegrees();
        if (coords == null || coords.size() < 2) {
            _cbErr.invoke("No GPS fix");
            return;
        }

        _lat = coords[0];
        _lon = coords[1];
        _fetchStops();
    }

    function _fetchStops() as Void {
        var cfg = Settings.getConfig();
        var radiusMeters = 1000;
        if (cfg != null && cfg[:radiusMeters] != null) {
            radiusMeters = cfg[:radiusMeters];
        }
        _maxStops = 10;
        if (cfg != null && cfg[:maxStops] != null) {
            _maxStops = cfg[:maxStops];
        }

        var stops = _loadLocalStops();
        if (stops == null) {
            _cbErr.invoke("Missing local stops");
            return;
        }

        var nearby = [];
        for (var i = 0; i < stops.size(); i += 1) {
            var s = stops[i];
            if (s.latitude == null || s.longitude == null) {
                continue;
            }
            s.distanceMiles = Util.distanceMiles(_lat, _lon, s.latitude, s.longitude);
            if (radiusMeters == null || s.distanceMiles * 1609.344 <= radiusMeters) {
                nearby.add(s);
            }
        }

        _onStops(nearby);
    }

    function _loadLocalStops() {
        try {
            var arr = App.loadResource(Rez.JsonData.Stops);
            if (arr == null) {
                return null;
            }

            var out = [];
            for (var i = 0; i < arr.size(); i += 1) {
                var j = arr[i];
                var attrs = j["attributes"];
                var s = new Stop();
                s.id = j["id"];
                if (attrs != null) {
                    s.name = (attrs["name"] != null) ? attrs["name"] : "Station";
                    s.latitude = attrs["latitude"];
                    s.longitude = attrs["longitude"];
                    s.platformName = attrs["platform_name"];
                    s.parentStation = attrs["parent_station"];
                    s.stationColors = attrs["station_colors"];
                    s.platformColors = attrs["platform_colors"];
                } else {
                    s.name = (j["name"] != null) ? j["name"] : "Station";
                    s.latitude = j["latitude"];
                    s.longitude = j["longitude"];
                    s.platformName = j["platform_name"];
                    s.parentStation = j["parent_station"];
                    s.stationColors = j["station_colors"];
                    s.platformColors = j["platform_colors"];
                }
                if (s.parentStation == null) {
                    var rel = j["relationships"];
                    if (rel != null && rel.hasKey("parent_station")) {
                        var data = rel["parent_station"]["data"];
                        if (data != null) {
                            s.parentStation = data["id"];
                        }
                    }
                }
                s.distanceMiles = null;
                out.add(s);
            }
            return out;
        } catch(e) {
            return null;
        }
    }

    function _onStops(stops) {
        if (stops == null) {
            stops = [];
        }

        for (var i = 0; i < stops.size(); i += 1) {
            var s = stops[i];
            if (s.latitude != null && s.longitude != null) {
                s.distanceMiles = Util.distanceMiles(_lat, _lon, s.latitude, s.longitude);
            }
        }

        for (var i = 0; i < stops.size() - 1; i += 1) {
            var minIndex = i;
            for (var j = i + 1; j < stops.size(); j += 1) {
                if (stops[j].distanceMiles != null && stops[minIndex].distanceMiles != null &&
                    stops[j].distanceMiles < stops[minIndex].distanceMiles) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                var tmp = stops[i];
                stops[i] = stops[minIndex];
                stops[minIndex] = tmp;
            }
        }

        var trimmed = [];
        for (var k = 0; k < stops.size(); k += 1) {
            if (_maxStops != null && k >= _maxStops) {
                break;
            }
            trimmed.add(stops[k]);
        }
        _cbOk.invoke(trimmed);
    }

    function _onErr(msg) {
        _cbErr.invoke(msg);
    }
}
