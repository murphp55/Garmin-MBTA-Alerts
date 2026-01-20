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

        for (var i = 0; i < stops.size(); i += 1) {
            var s = stops[i];
            var subLabel = null;
            if (s.distanceMiles != null) {
                subLabel = Util.formatDistanceMiles(s.distanceMiles);
            }
            addItem(new Ui.MenuItem(s.name, subLabel, { :stopId => s.id, :stopName => s.name }, {}));
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
}

class StationsMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var info = item.getId();
        if (info == null) {
            return;
        }
        Ui.pushView(new PredictionsView(info[:stopId], info[:stopName]), null, Ui.SLIDE_IMMEDIATE);
    }
}
