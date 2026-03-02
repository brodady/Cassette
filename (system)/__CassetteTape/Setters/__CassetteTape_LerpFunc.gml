// Feather ignore all
/// @ignore  (Internal) __CassetteTape_LerpFunc(function)
/// @desc    Sets a custom interpolation function for this track.
/// @param   {Function} function The function to use. Must accept (from, to, t).
/// @return  {Struct.CassetteTape} Self
function __CassetteTape_LerpFunc(_func) {
    var _t = array_last(__tracks);
    if (__copyStructs && is_struct(_func)) {
        _t.lerpFunc = variable_clone(_func);
    } else {
        _t.lerpFunc = _func;
    }
    return self;
}