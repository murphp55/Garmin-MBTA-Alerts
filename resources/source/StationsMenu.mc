using Toybox.WatchUi as Ui;

class StationsMenu extends Ui.Menu2 {
    var _loader;
    var _itemCount;

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.MenuNearby });
        _itemCount = 0;
        _loader = new StationsLoader(method(:_onStops), method(:_onError));
        _setMessage("Finding nearby stations...");
    }

    function onShow() {
        _setMessage("Finding nearby stations...");
        _loader.load();
    }

    function _setMessage(msg) {
        _clearItems();
        addItem(new Ui.MenuItem(msg, null, null, {}));
        _itemCount = 1;
    }

    function _onStops(stops) {
        _clearItems();
        if (stops == null || stops.size() == 0) {
            addItem(new Ui.MenuItem("No nearby stations", null, null, {}));
            _itemCount = 1;
            return;
        }
        var stations = _groupStations(stops);
        _sortStations(stations);

        for (var i = 0; i < stations.size(); i += 1) {
            var station = stations[i];
            var subLabel = null;
            if (station[:distanceMiles] != null) {
                subLabel = Util.formatDistanceMiles(station[:distanceMiles]);
            }
            var colorTag = _colorKey(station[:colors]);
            if (colorTag != "") {
                if (subLabel == null) {
                    subLabel = colorTag;
                } else {
                    subLabel = subLabel + " | " + colorTag;
                }
            }
            addItem(new Ui.MenuItem(station[:name], subLabel, { :station => station }, {}));
            _itemCount += 1;
        }
    }

    function _onError(msg) {
        _setMessage("Error: " + msg);
    }

    function _clearItems() {
        for (var i = _itemCount - 1; i >= 0; i -= 1) {
            deleteItem(i);
        }
        _itemCount = 0;
    }

    function _groupStations(stops) {
        var map = {};
        for (var i = 0; i < stops.size(); i += 1) {
            var s = stops[i];
            var key = (s.parentStation != null) ? s.parentStation : s.id;
            var station = map[key];
            if (station == null) {
                station = {
                    :id => key,
                    :name => s.name,
                    :distanceMiles => s.distanceMiles,
                    :platforms => [],
                    :colors => []
                };
                map[key] = station;
            }
            station[:platforms].add(s);
            _mergeColors(station[:colors], s.stationColors);
            _mergeColors(station[:colors], s.platformColors);
            if (station[:distanceMiles] == null ||
                (s.distanceMiles != null && s.distanceMiles < station[:distanceMiles])) {
                station[:distanceMiles] = s.distanceMiles;
            }
        }

        var list = [];
        var keys = map.keys();
        for (var j = 0; j < keys.size(); j += 1) {
            list.add(map[keys[j]]);
        }
        return list;
    }

    function _mergeColors(out, colors) {
        if (colors == null) {
            return;
        }
        for (var i = 0; i < colors.size(); i += 1) {
            var c = colors[i];
            var exists = false;
            for (var j = 0; j < out.size(); j += 1) {
                if (out[j] == c) { exists = true; break; }
            }
            if (!exists) {
                out.add(c);
            }
        }
    }

    function _sortStations(stations) {
        for (var i = 0; i < stations.size() - 1; i += 1) {
            var minIndex = i;
            for (var j = i + 1; j < stations.size(); j += 1) {
                var dMin = stations[minIndex][:distanceMiles];
                var dCur = stations[j][:distanceMiles];
                if (dCur != null && (dMin == null || dCur < dMin)) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                var tmp = stations[i];
                stations[i] = stations[minIndex];
                stations[minIndex] = tmp;
            }
        }
    }

    function _colorKey(colors) {
        if (colors == null) { return ""; }
        var out = [];
        if (_hasColor(colors, "DA291C")) { out.add("R"); }
        if (_hasColor(colors, "ED8B00")) { out.add("O"); }
        if (_hasColor(colors, "003DA5")) { out.add("B"); }
        if (_hasColor(colors, "00843D")) { out.add("G"); }
        return Util.join(out, " ");
    }

    function _hasColor(colors, hex) {
        for (var i = 0; i < colors.size(); i += 1) {
            if (colors[i] == hex) { return true; }
        }
        return false;
    }
}

class StationsMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onBack() {
        Log.info("StationsMenu back");
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onNextPage() {
        Log.info("StationsMenu nextPage");
        return false;
    }

    function onPreviousPage() {
        Log.info("StationsMenu prevPage");
        return false;
    }

    function onWrap(key) {
        Log.info("StationsMenu wrap " + key);
        return true;
    }

    function onTitle() {
        Log.info("StationsMenu title");
    }

    function onFooter() {
        Log.info("StationsMenu footer");
    }

    function onSelect(item) {
        Log.info("StationsMenu select");
        var info = item.getId();
        if (info == null) {
            return;
        }
        var station = info[:station];
        if (station == null) {
            return;
        }
        Ui.pushView(new PlatformsMenu(station), new PlatformsMenuDelegate(), Ui.SLIDE_IMMEDIATE);
    }
}

class PlatformsMenu extends Ui.Menu2 {
    var _station;
    var _itemCount;

    function initialize(station) {
        Menu2.initialize({ :title => station[:name] });
        _station = station;
        _itemCount = 0;
        _buildItems();
    }

    function _buildItems() {
        _clearItems();
        var platforms = _station[:platforms];
        if (platforms == null || platforms.size() == 0) {
            addItem(new Ui.MenuItem("No platforms", null, null, {}));
            _itemCount = 1;
            return;
        }

        for (var i = 0; i < platforms.size(); i += 1) {
            var s = platforms[i];
            var label = (s.platformName != null && s.platformName != "") ? s.platformName : s.name;
            var title = _station[:name];
            if (s.platformName != null && s.platformName != "") {
                title = title + " - " + s.platformName;
            }
            addItem(new Ui.MenuItem(label, null, { :stopId => s.id, :stopName => title }, {}));
            _itemCount += 1;
        }
    }

    function _clearItems() {
        for (var i = _itemCount - 1; i >= 0; i -= 1) {
            deleteItem(i);
        }
        _itemCount = 0;
    }
}

class PlatformsMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onBack() {
        Log.info("PlatformsMenu back");
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onNextPage() {
        Log.info("PlatformsMenu nextPage");
        return false;
    }

    function onPreviousPage() {
        Log.info("PlatformsMenu prevPage");
        return false;
    }

    function onWrap(key) {
        Log.info("PlatformsMenu wrap " + key);
        return true;
    }

    function onTitle() {
        Log.info("PlatformsMenu title");
    }

    function onFooter() {
        Log.info("PlatformsMenu footer");
    }

    function onSelect(item) {
        Log.info("PlatformsMenu select");
        var info = item.getId();
        if (info == null) {
            return;
        }
        Ui.pushView(new PredictionsView(info[:stopId], info[:stopName]), new LogInputDelegate("PredictionsView"), Ui.SLIDE_IMMEDIATE);
    }
}
