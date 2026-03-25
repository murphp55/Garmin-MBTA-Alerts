using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class Log {
    static function info(msg) {
        Sys.println(_timestamp() + " " + msg);
    }

    static function _timestamp() {
        var t = Sys.getClockTime();
        return t.hour.format("%02d") + ":" + t.min.format("%02d") + ":" + t.sec.format("%02d");
    }
}

class LogInputDelegate extends Ui.InputDelegate {
    var _context;

    function initialize(context) {
        InputDelegate.initialize();
        _context = context;
    }

    function onKey(evt) {
        Log.info(_ctx() + "key " + evt.getKey());
        return false;
    }

    function onKeyPressed(evt) {
        Log.info(_ctx() + "keyDown " + evt.getKey());
        return false;
    }

    function onKeyReleased(evt) {
        Log.info(_ctx() + "keyUp " + evt.getKey());
        return false;
    }

    function onTap(evt) {
        Log.info(_ctx() + "tap");
        return false;
    }

    function onSwipe(evt) {
        Log.info(_ctx() + "swipe " + evt.getDirection());
        return false;
    }

    function onHold(evt) {
        Log.info(_ctx() + "hold");
        return false;
    }

    function onRelease(evt) {
        Log.info(_ctx() + "release");
        return false;
    }

    function _ctx() {
        return (_context != null && _context != "") ? (_context + " ") : "";
    }
}
