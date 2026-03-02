// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnPlay(callback)
/// @desc    Sets a function to run when .play() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnPlay(_func) {
    if (is_method(_func)) {
        __onPlay = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onPlay = variable_clone(_func);
    }
    else {
        __onPlay = _func;
    }
    return self;
}
