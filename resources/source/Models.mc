class Stop {
    var id, name, latitude, longitude, distanceMiles, parentStation, platformName, stationColors, platformColors;

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
            s.platformName = attrs["platform_name"];
        } else {
            s.latitude = null;
            s.longitude = null;
            s.platformName = null;
        }
        s.stationColors = null;
        s.platformColors = null;
        var rel = j["relationships"];
        if (rel != null && rel.hasKey("parent_station")) {
            var data = rel["parent_station"]["data"];
            if (data != null) {
                s.parentStation = data["id"];
            }
        }
        s.distanceMiles = null;
        return s;
    }
}

class Prediction {
    var directionId, time, routeId, scheduleRelationship;

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
            p.scheduleRelationship = attrs["schedule_relationship"];
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
