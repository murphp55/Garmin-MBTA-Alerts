class Stop {
    var id, name, latitude, longitude, distanceMiles;

    static function fromJson(j) {
        var s = new Stop();
        s.id = j["id"];
        var attrs = j["attributes"];
        if (attrs != null && attrs.hasKey("name") && attrs["name"] != null) {
            s.name = attrs["name"];
        } else {
            s.name = "Station";
        }
        if (attrs != null) {
            s.latitude = attrs["latitude"];
            s.longitude = attrs["longitude"];
        } else {
            s.latitude = null;
            s.longitude = null;
        }
        s.distanceMiles = null;
        return s;
    }
}

class Prediction {
    var directionId, time, routeId;

    static function fromJson(j) {
        var p = new Prediction();
        var attrs = j["attributes"];
        if (attrs != null) {
            p.directionId = attrs["direction_id"];
            if (attrs["arrival_time"] != null) {
                p.time = attrs["arrival_time"];
            } else {
                p.time = attrs["departure_time"];
            }
        }

        var rel = j["relationships"];
        if (rel != null && rel.hasKey("route")) {
            var data = rel["route"]["data"];
            if (data != null) {
                p.routeId = data["id"];
            }
        }
        return p;
    }
}

class Alert {
    var id, header, effect, route, updatedAt;

    static function fromJson(j) {
        var a = new Alert();
        a.id = j["id"];
        var attrs = j["attributes"];
        if (attrs != null && attrs["header"] != null) {
            a.header = attrs["header"];
        } else if (attrs != null && attrs["short_header"] != null) {
            a.header = attrs["short_header"];
        } else {
            a.header = "Alert";
        }
        if (attrs != null) {
            a.effect = attrs["effect"];
            a.updatedAt = attrs["updated_at"];
        } else {
            a.effect = null;
            a.updatedAt = null;
        }
        a.route = null;
        var rel = j["relationships"];
        if (rel != null && rel.hasKey("routes")) {
            var routes = rel["routes"]["data"];
            if (routes != null && routes.size() > 0) {
                a.route = routes[0]["id"];
            }
        }
        return a;
    }

    function toLine() {
        var prefix = "";
        if (route != null) {
            prefix = route;
        }
        if (effect != null) {
            if (prefix != "") { prefix += " "; }
            prefix += effect;
        }
        if (updatedAt != null) {
            if (prefix != "") { prefix += " "; }
            prefix += Util.formatIsoTime(updatedAt);
        }

        var msg = (header != null) ? header : "Alert";
        if (prefix != "") {
            return Util.truncate(prefix + " - " + msg, 60);
        }
        return Util.truncate(msg, 60);
    }
}
