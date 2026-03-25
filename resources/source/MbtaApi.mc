using Toybox.Communications as Comm;
using Toybox.Json as Json;
import Toybox.Lang;

class MbtaApi {
    var _cbOk;
    var _cbErr;

    function fetchNearbyStops(cfg, lat, lon, radiusMeters, maxStops, onOk, onErr) {
        if (cfg == null || cfg[:mbtaApiKey] == null) {
            onErr.invoke("Missing API key");
            return;
        }

        var url = "https://api-v3.mbta.com/stops";
        var q = [];
        q.add("filter[latitude]=" + lat);
        q.add("filter[longitude]=" + lon);
        q.add("filter[radius]=" + radiusMeters);
        q.add("filter[route_type]=0,1");
        if (maxStops != null) {
            q.add("page[limit]=" + maxStops);
        }
        url = url + "?" + _join(q, "&");

        _cbOk = onOk;
        _cbErr = onErr;

        Log.info("MBTA GET " + url);
        var headers = { "x-api-key" => cfg[:mbtaApiKey] };
        Comm.makeWebRequest(url, null, { :headers => headers,
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, method(:_handleStopsResponse));
    }

    function fetchPredictions(cfg, stopId, onOk, onErr) {
        if (cfg == null || cfg[:mbtaApiKey] == null) {
            onErr.invoke("Missing API key");
            return;
        }
        if (stopId == null) {
            onErr.invoke("Missing stop");
            return;
        }

        var url = "https://api-v3.mbta.com/predictions";
        var q = [ "filter[stop]=" + stopId, "sort=departure_time" ];
        url = url + "?" + _join(q, "&");

        _cbOk = onOk;
        _cbErr = onErr;

        Log.info("MBTA GET " + url);
        var headers = { "x-api-key" => cfg[:mbtaApiKey] };
        Comm.makeWebRequest(url, null, { :headers => headers,
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, method(:_handlePredictionsResponse));
    }

    function _handleStopsResponse(respCode as Number, data as Dictionary or String or Null) as Void {
        try {
            if (respCode != 200) {
                _cbErr.invoke("HTTP " + respCode);
                return;
            }
            var json = data;
            var arr = (json != null && json.hasKey("data")) ? json["data"] : [];
            var out = [];

            for (var i = 0; i < arr.size(); i += 1) {
                out.add(Stop.fromJson(arr[i]));
            }
            _cbOk.invoke(out);
        } catch(e) {
            _cbErr.invoke("Parse error");
        }
    }

    function _handlePredictionsResponse(respCode as Number, data as Dictionary or String or Null) as Void {
        try {
            if (respCode != 200) {
                _cbErr.invoke("HTTP " + respCode);
                return;
            }
            var json = data;
            var arr = (json != null && json.hasKey("data")) ? json["data"] : [];
            Log.info("MBTA predictions respCode=" + respCode + " count=" + arr.size());
            if (arr.size() > 0) {
                var first = arr[0];
                var firstId = (first != null && first.hasKey("id")) ? first["id"] : "";
                Log.info("MBTA predictions firstId=" + firstId);
            }
            var out = [];

            for (var i = 0; i < arr.size(); i += 1) {
                out.add(Prediction.fromJson(arr[i]));
            }
            _cbOk.invoke(out);
        } catch(e) {
            _cbErr.invoke("Parse error");
        }
    }

    function _join(parts, sep) {
        var out = "";
        for (var i = 0; i < parts.size(); i += 1) {
            if (i > 0) {
                out += sep;
            }
            out += parts[i];
        }
        return out;
    }
}
