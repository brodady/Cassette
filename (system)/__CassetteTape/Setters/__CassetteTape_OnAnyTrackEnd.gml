// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnAnyTrackEnd(callback)
/// @desc    Sets a function to run whenever ANY track on this tape finishes.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnAnyTrackEnd(_func) {
    if (is_method(_func)) {
        __onAnyTrackEnd = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onAnyTrackEnd = variable_clone(_func);
    }
    else {
        __onAnyTrackEnd = _func;
    }
    return self;
}
