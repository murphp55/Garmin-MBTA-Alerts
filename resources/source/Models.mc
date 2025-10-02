class Models {
    class Alert {
        var id, header, effect, route, updatedAt;

        static function fromJson(j) {
            var a = new Alert();
            a.id = j["id"];
            var attrs = j["attributes"];
            a.header = attrs["header"] ?: attrs["short_header"] ?: "Alert";
            a.effect = attrs["effect"];
            a.updatedAt = attrs["updated_at"];
            // Optional: pull route from relationships
            a.route = null;
            return a;
        }

        function toLine() {
            // TODO: make concise: EFFECT • HEADER (time)
            return (effect ? effect + " • " : "") + (header ?: "Alert");
        }
    }
}
