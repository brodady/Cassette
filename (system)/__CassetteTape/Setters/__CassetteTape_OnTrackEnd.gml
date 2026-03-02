// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnTrackEnd(callback)
/// @desc    Sets a function to run when the CURRENT track (segment) finishes.
/// @param   {Function} callback
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnTrackEnd(_func) {
    if (is_method(_func)) {
        array_last(__tracks).onTrackEnd = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        array_last(__tracks).onTrackEnd = variable_clone(_func);
    }
    else {
        array_last(__tracks).onTrackEnd = _func;
    }
    return self;
}
