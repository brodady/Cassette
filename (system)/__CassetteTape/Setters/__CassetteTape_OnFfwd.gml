// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnFfwd(callback)
/// @desc    Sets a function to run when .ffwd() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnFfwd(_func) {
    if (is_method(_func)) {
        __onFfwd = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onFfwd = variable_clone(_func);
    }
    else {
        __onFfwd = _func;
    }
    return self;
}
