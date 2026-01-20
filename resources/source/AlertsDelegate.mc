using Toybox.Json as Json;

class AlertsDelegate {
    var _cbOk, _cbErr;
    var _model;
    var _api;
    var _maxRows;

    function initialize(cbOk, cbErr) {
        _cbOk = cbOk; _cbErr = cbErr;
        _model = { :state => :loading, :lines => [], :errorMessage => null };
    }

    function getModel() { return _model; }

    function loadAlerts() {
        _model = { :state => :loading, :lines => [], :errorMessage => null };

        var cfg = Settings.getConfig();
        _maxRows = (cfg != null && cfg[:maxRows] != null) ? cfg[:maxRows] : 6;
        _api = new MbtaApi();
        _api.fetchAlerts(cfg, method(:_onSuccess), method(:_onFailure));
    }

    function _onSuccess(alerts) {
        var lines = [];
        if (alerts != null) {
            for (var i = 0; i < alerts.size(); i += 1) {
                if (_maxRows != null && lines.size() >= _maxRows) {
                    break;
                }
                lines.add(alerts[i].toLine());
            }
        }
        if (lines.size() > 0) {
            _model = { :state => :ready, :lines => lines };
        } else {
            _model = { :state => :ready, :lines => [ Rez.Strings.NoAlerts ] };
        }
        _cbOk.invoke();
    }

    function _onFailure(msg) {
        _model = { :state => :error, :lines => [], :errorMessage => msg };
        _cbErr.invoke();
    }
}
