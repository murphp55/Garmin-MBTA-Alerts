using Toybox.Application as App;

class Settings {
    static function getConfig() {
        var s = App.getApp().getProperty("settings") as Dictionary; // some SDKs use getAppSettings()
        // Fallback to individual props if needed:
        return {
            :mbtaApiKey => App.getApp().getProperty("mbtaApiKey"),
            :stopId     => App.getApp().getProperty("stopId"),
            :routeFilter=> App.getApp().getProperty("routeFilter"),
            :direction  => App.getApp().getProperty("direction"),
            :maxRows    => App.getApp().getProperty("maxRows")
        };
    }
}
