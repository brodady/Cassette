// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnRewind(callback)
/// @desc    Sets a function to run when .rewind() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnRewind(_func) {
    if (is_method(_func)) {
        __onRewind = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onRewind = variable_clone(_func);
    }
    else {
        __onRewind = _func;
    }
    return self;
}
