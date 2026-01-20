using Toybox.Math as Math;

class Util {
    static function truncate(s, max) {
        if (s.size() > max) {
            return s.substring(0, max - 1) + ".";
        }
        return s;
    }

    static function distanceMiles(lat1, lon1, lat2, lon2) {
        var pi = 3.141592653589793;
        var toRad = pi / 180.0;
        var dLat = (lat2 - lat1) * toRad;
        var dLon = (lon2 - lon1) * toRad;
        var a = Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0) +
                Math.cos(lat1 * toRad) * Math.cos(lat2 * toRad) *
                Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0);
        var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
        return 3958.7613 * c;
    }

    static function formatDistanceMiles(miles) {
        if (miles == null) {
            return null;
        }
        var rounded = Math.round(miles * 10.0) / 10.0;
        return rounded + " mi";
    }

    static function formatPredictionTime(pred) {
        if (pred == null || pred.time == null) {
            return "No prediction";
        }
        var s = "" + pred.time;
        if (s.size() >= 16) {
            return s.substring(11, 16);
        }
        return s;
    }

    static function formatIsoTime(iso) {
        if (iso == null) {
            return null;
        }
        var s = "" + iso;
        if (s.size() >= 16) {
            return s.substring(11, 16);
        }
        return s;
    }

    static function join(lines, sep) {
        var out = "";
        if (lines == null) {
            return out;
        }
        for (var i = 0; i < lines.size(); i += 1) {
            if (i > 0) {
                out += sep;
            }
            out += lines[i];
        }
        return out;
    }
}
