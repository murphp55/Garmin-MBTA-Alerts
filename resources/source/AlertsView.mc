using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

class AlertsView extends Ui.View {
    var _delegate;
    var _title;
    var _body;

    function onShow() {
        _delegate = new AlertsDelegate(self.method(:onData), self.method(:onError));
        Ui.requestUpdate(); // initial paint
        _delegate.loadAlerts(); // async fetch
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ViewAlertsLayout(dc));
        _title = findDrawableById("title");
        _body = findDrawableById("body");
    }

    function onUpdate(dc) {
        var model = null;
        if (_delegate != null) {
            model = _delegate.getModel();
        }

        if (_title != null) {
            _title.setText(Rez.Strings.MenuAlerts);
        }
        if (_body != null) {
            if (model == null || model[:state] == :loading) {
                _body.setText(Rez.Strings.Loading);
            } else if (model[:state] == :error) {
                _body.setText(Rez.Strings.Error + ": " + model[:errorMessage]);
            } else {
                _body.setText(Util.join(model[:lines], "\n"));
            }
        }
        View.onUpdate(dc);
    }

    function onData() { Ui.requestUpdate(); }
    function onError() { Ui.requestUpdate(); }
}
