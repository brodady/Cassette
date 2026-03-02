// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnStop(callback)
/// @desc    Sets a function to run when .stop() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnStop(_func) {
    if (is_method(_func)) {
        __onStop = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onStop = variable_clone(_func);
    }
    else {
        __onStop = _func;
    }
    return self;
}
