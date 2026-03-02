// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Ease(function_or_curve)
/// @desc    Sets the easing function or Animation Curve.
/// @param   {Function|Struct|Struct.GMAnimCurve} function_or_curve Easing function or AnimCurve Asset.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Ease(_func) {
    var _t = array_last(__tracks);

    if (__copyStructs && is_struct(_func)) {
        _t.ease = variable_clone(_func);
    } else {
        _t.ease = _func;
    }

    if (!is_struct(_t.ease) && !is_method(_t.ease) && animcurve_exists(_t.ease)) {
        _t.ease = animcurve_get(_t.ease);
    }

    return self;
}