// Feather ignore all
/// @ignore  (Internal) __CassetteTape_HandleCallback(_method, _val) Executes a callback safely or raw (based on deck config).
function __CassetteTape_HandleCallback(_method, _val) {
    if (!is_method(_method)) return;

    if (CASSETTE_SAFE_MODE) {
        try {
            _method(_val);
        } catch(_e) {
            __CassetteError("Callback Execution Failed", _e);
        }
    }
    else {
        _method(_val);
    }
}