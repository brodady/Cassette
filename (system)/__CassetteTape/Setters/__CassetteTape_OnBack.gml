// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnBack(callback)
/// @desc    Sets a function to run when .back() is called on this tape.
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnBack(_func) {
    if (is_method(_func)) {
        __onBack = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onBack = variable_clone(_func);
    }
    else {
        __onBack = _func;
    }
    return self;
}
