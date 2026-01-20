class PredictionsDelegate {
    var _stopId, _cbOk, _cbErr;
    var _model;
    var _api;

    function initialize(stopId, cbOk, cbErr) {
        _stopId = stopId;
        _cbOk = cbOk;
        _cbErr = cbErr;
        _model = { :state => :loading, :lines => [], :errorMessage => null };
    }

    function getModel() { return _model; }

    function loadPredictions() {
        _model = { :state => :loading, :lines => [], :errorMessage => null };
        var cfg = Settings.getConfig();
        _api = new MbtaApi();
        _api.fetchPredictions(cfg, _stopId, method(:_onSuccess), method(:_onFailure));
    }

    function _onSuccess(predictions) {
        var inbound = null;
        var outbound = null;

        if (predictions != null) {
            for (var i = 0; i < predictions.size(); i += 1) {
                var p = predictions[i];
                if (p.directionId == 0 && inbound == null) {
                    inbound = p;
                }
                if (p.directionId == 1 && outbound == null) {
                    outbound = p;
                }
                if (inbound != null && outbound != null) {
                    break;
                }
            }
        }

        var lines = [
            "Inbound: " + Util.formatPredictionTime(inbound),
            "Outbound: " + Util.formatPredictionTime(outbound)
        ];
        _model = { :state => :ready, :lines => lines };
        _cbOk.invoke();
    }

    function _onFailure(msg) {
        _model = { :state => :error, :lines => [], :errorMessage => msg };
        _cbErr.invoke();
    }
}
