// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnPause(callback)
/// @desc    Sets a function to run when .pause() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnPause(_func) {
    if (is_method(_func)) {
        __onPause = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onPause = variable_clone(_func);
    }
    else {
        __onPause = _func;
    }
    return self;
}
