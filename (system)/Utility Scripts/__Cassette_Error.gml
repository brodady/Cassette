// Feather ignore all
/// @ignore  (Internal) __CassetteError(event, error_struct)
/// @desc    Internal error reporter. Respects CASSETTE_STRICT_MODE.
function __CassetteError(_event, _error) {
    var _key = (variable_instance_exists(self, "__key")) ? string(__key) : "Unknown Tape";
    
    var _msg = $"CASSETTE ERROR :: {_key} :: Event '{_event}' failed.\n";
    _msg += "--------------------------------------------------------------\n";
    _msg += _error.message + "\n";
    _msg += "--------------------------------------------------------------";
    
    if (CASSETTE_STRICT_MODE) {
        show_error(_msg, true);
    } else {
        show_debug_message(_msg);
        show_debug_message(_error.stacktrace);
    }
}