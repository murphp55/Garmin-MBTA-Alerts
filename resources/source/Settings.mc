using Toybox.Application as App;

class Settings {
    static function getConfig() {
        return {
            :mbtaApiKey => App.getApp().getProperty("mbtaApiKey"),
            :radiusMeters => App.getApp().getProperty("radiusMeters"),
            :maxStops     => App.getApp().getProperty("maxStops"),
            :stopId       => App.getApp().getProperty("stopId"),
            :routeFilter  => App.getApp().getProperty("routeFilter"),
            :direction    => App.getApp().getProperty("direction"),
            :maxRows      => App.getApp().getProperty("maxRows")
        };
    }
}
