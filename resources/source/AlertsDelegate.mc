using Toybox.Json as Json;

class AlertsDelegate {
    var _cbOk, _cbErr;
    var _model;

    function initialize(cbOk, cbErr) {
        _cbOk = cbOk; _cbErr = cbErr;
        _model = { :state => :loading, :lines => [], :errorMessage => null };
    }

    function getModel() { return _model; }

    function loadAlerts() {
        _model = { :state => :loading, :lines => [], :errorMessage => null };

        var cfg = Settings.getConfig();
        MbtaApi.fetchAlerts(cfg, method(:_onSuccess), method(:_onFailure));
    }

    function _onSuccess(alerts as Array<Alert>) {
        var lines = [];
        // TODO: tune formatting (route, effect, short header, time)
        foreach (a in alerts) {
            lines += [ a.toLine() ];
        }
        _model = { :state => :ready, :lines => (lines.size() > 0 ? lines : [ "No alerts" ]) };
        _cbOk();
    }

    function _onFailure(msg) {
        _model = { :state => :error, :lines => [], :errorMessage => msg };
        _cbErr();
    }
}
