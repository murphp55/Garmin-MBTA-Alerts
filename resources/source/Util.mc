using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;

class Util {
    static function truncate(s, max) {
        if (s.length() > max) {
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
        return pred.time.toString();
    }

    static function formatIsoTime(iso) {
        if (iso == null) {
            return null;
        }
        return iso.toString();
    }

    static function minutesFromIso(iso) {
        if (iso == null) {
            return null;
        }
        var s = iso.toString();
        if (s.length() < 19) {
            return null;
        }

        var year = s.substring(0, 4).toNumber();
        var month = s.substring(5, 7).toNumber();
        var day = s.substring(8, 10).toNumber();
        var hour = s.substring(11, 13).toNumber();
        var minute = s.substring(14, 16).toNumber();
        var second = s.substring(17, 19).toNumber();
        if (year == null || month == null || day == null ||
            hour == null || minute == null || second == null) {
            return null;
        }

        var moment = Gregorian.moment({
            :year => year,
            :month => month,
            :day => day,
            :hour => hour,
            :minute => minute,
            :second => second
        });
        var now = new Time.Moment(Time.now().value());
        var diffSec = moment.compare(now);
        var mins = Math.round(diffSec / 60.0);
        if (mins < 0) { mins = 0; }
        return mins;
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
