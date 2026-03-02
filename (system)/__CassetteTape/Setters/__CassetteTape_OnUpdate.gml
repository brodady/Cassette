// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnUpdate(callback, [interval])
/// @desc    Sets a function to run every frame this tape is active.
/// @param   {Function} callback Receives current value as argument.
/// @param   {Real} [interval] Optional. If set, callback runs every N frames/seconds.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnUpdate(_func, _interval = undefined) {
    if (is_method(_func)) {
        __onUpdate = _func;
    }
    else if (__copyStructs && is_struct(_func)) {
        __onUpdate = variable_clone(_func);
    }
    else {
        __onUpdate = _func;
    }
    __onUpdateInterval = _interval;
    return self;
}