using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

class AlertsView extends Ui.View {
    var _delegate;

    function onShow() {
        _delegate = new AlertsDelegate(self.method(:onData), self.method(:onError));
        Ui.requestUpdate(); // initial paint
        _delegate.loadAlerts(); // async fetch
    }

    function onUpdate(dc) {
        var layout = Ui.loadResource(Ui.RESOURCES_LAYOUT, Rez.Layouts.ViewAlertsLayout);
        var list = layout.findById("alertsList") as Ui.List;

        var model = _delegate?.getModel();
        if (model == null || model.state == :loading) {
            list.setItems([ "Loading…" ]);
        } else if (model.state == :error) {
            list.setItems([ "Error: " + model.errorMessage ]);
        } else {
            list.setItems(model.lines); // array of strings
        }
        layout.draw(dc);
    }

    function onData() { Ui.requestUpdate(); }
    function onError() { Ui.requestUpdate(); }
}
