// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnSkip(callback)
/// @desc    Sets a function to run when .skip() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnSkip(_func) {
    if (is_method(_func)) {
        __onSkip = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onSkip = variable_clone(_func);
    }
    else {
        __onSkip = _func;
    }
    return self;
}
