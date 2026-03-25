using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;

class HomeMenu extends Ui.Menu2 {
    var _itemCount;

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.HomeTitle });
        _itemCount = 0;
        _buildItems();
    }

    function onShow() {
        _buildItems();
    }

    function _buildItems() {
        for (var i = _itemCount - 1; i >= 0; i -= 1) {
            deleteItem(i);
        }
        _itemCount = 0;
        addItem(new Ui.MenuItem(Rez.Strings.MenuNearby, null, { :id => :nearby }, {}));
        _itemCount = 1;
    }
}

class HomeMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onBack() {
        Log.info("HomeMenu back");
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onNextPage() {
        Log.info("HomeMenu nextPage");
        return false;
    }

    function onPreviousPage() {
        Log.info("HomeMenu prevPage");
        return false;
    }

    function onWrap(key) {
        Log.info("HomeMenu wrap " + key);
        return true;
    }

    function onTitle() {
        Log.info("HomeMenu title");
    }

    function onFooter() {
        Log.info("HomeMenu footer");
    }

    function onSelect(item) {
        Log.info("HomeMenu select");
        var info = item.getId() as Lang.Dictionary;
        if (info == null) {
            return;
        }
        if (info[:id] == :nearby) {
            Ui.pushView(new StationsMenu(), new StationsMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        }
    }
}
