using Toybox.Communications as Comm;
using Toybox.Json as Json;

class MbtaApi {
    // Alerts: https://api-v3.mbta.com/alerts?filter[stop]=...&filter[route]=...&filter[direction_id]=...
    static function fetchAlerts(cfg, onOk, onErr) {
        var url = "https://api-v3.mbta.com/alerts";
        var q = [];

        if (cfg.stopId)       q += [ "filter[stop]=" + cfg.stopId ];
        if (cfg.routeFilter)  q += [ "filter[route]=" + cfg.routeFilter ];
        if (cfg.direction != null) q += [ "filter[direction_id]=" + cfg.direction ];

        // Only active alerts, sorted by updated_at desc
        q += [ "filter[activity]=BOARD,EXIT" ];
        q += [ "sort=-updated_at" ];
        if (q.size() > 0) url = url + "?" + Lang.join(q, "&");

        var headers = { "x-api-key" => cfg.mbtaApiKey };
        Comm.makeWebRequest(url, {}, { :headers => headers, :method => "GET", :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON },
            method(:_handleResponse, onOk, onErr, cfg.maxRows));
    }

    static function _handleResponse(respCode, data, onOk, onErr, maxRows) {
        try {
            if (respCode != 200) {
                onErr("HTTP " + respCode);
                return;
            }
            var json = data as Dictionary;
            var arr = (json != null && json.hasKey("data")) ? json["data"] : [];
            var out = [];
            var count = 0;

            foreach (item in arr) {
                if (maxRows != null && count >= maxRows) break;
                var a = Models.Alert.fromJson(item);
                out += [ a ];
                count += 1;
            }
            onOk(out);
        } catch(e) {
            onErr("Parse error");
        }
    }
}
