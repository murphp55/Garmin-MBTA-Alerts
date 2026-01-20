using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;

class PredictionsView extends Ui.View {
    var _stopId, _stopName;
    var _delegate;
    var _title;
    var _body;

    function initialize(stopId, stopName) {
        View.initialize();
        _stopId = stopId;
        _stopName = stopName;
    }

    function onShow() {
        _delegate = new PredictionsDelegate(_stopId, method(:onData), method(:onError));
        Ui.requestUpdate();
        _delegate.loadPredictions();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ViewAlertsLayout(dc));
        _title = findDrawableById("title");
        _body = findDrawableById("body");
    }

    function onUpdate(dc) {
        if (_body == null) {
            return;
        }
        if (_title != null && _stopName != null) {
            _title.setText(_stopName);
        }

        var model = null;
        if (_delegate != null) {
            model = _delegate.getModel();
        }

        if (model == null || model[:state] == :loading) {
            _body.setText(Rez.Strings.Loading);
        } else if (model[:state] == :error) {
            _body.setText(Rez.Strings.Error + ": " + model[:errorMessage]);
        } else {
            _body.setText(Util.join(model[:lines], "\n"));
        }
        View.onUpdate(dc);
    }

    function onData() { Ui.requestUpdate(); }
    function onError() { Ui.requestUpdate(); }
}
