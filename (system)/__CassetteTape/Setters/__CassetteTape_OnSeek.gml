// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnSeek(callback)
/// @desc    Sets a function to run when .seek() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnSeek(_func) {
    if (is_method(_func)) {
        __onSeek = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onSeek = variable_clone(_func);
    }
    else {
        __onSeek = _func;
    }
    return self;
}
