class Util {
    static function truncate(s, max) {
        return (s.size() > max) ? s.substring(0, max-1) + "…" : s;
    }
}
