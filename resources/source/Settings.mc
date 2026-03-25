using Toybox.Application as App;

class Settings {
    static function getConfig() {
        return {
            :mbtaApiKey => App.getApp().getProperty("mbtaApiKey"),
            :radiusMeters => App.getApp().getProperty("radiusMeters"),
            :maxStops     => App.getApp().getProperty("maxStops")
        };
    }
}
