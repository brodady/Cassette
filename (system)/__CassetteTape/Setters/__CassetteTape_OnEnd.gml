// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnEnd(callback)
/// @desc    Sets a function to run when the ENTIRE sequence finishes.
/// @param   {Function} callback
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnEnd(_func) { 
    if (is_method(_func)) {
        __onEnd = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onEnd = variable_clone(_func);
    }
    else {
        __onEnd = _func;
    }
    return self;
}
