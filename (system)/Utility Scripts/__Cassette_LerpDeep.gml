// Feather ignore all
/// @ignore (Internal) __Cassette_LerpDeep(from, to, t, lerp_func, target, is_inst)
/// @desc Recursively interpolates two structs and applies them to a target, with specialized handling for colours.
function __Cassette_LerpDeep(_from, _to, _t, _lerp, _target, _isInst) {
    var _keys = variable_struct_get_names(_to);
    var _len = array_length(_keys);
    var _i = 0;

    repeat(_len) {
        var _k = _keys[_i];
        if (variable_struct_exists(_from, _k)) {
            var _f = _from[$ _k];
            var _e = _to[$ _k];
            var _k_lower = string_lower(_k);
            var _is_color = (string_pos("color", _k_lower) > 0 || string_pos("colour", _k_lower) > 0);

            if (is_struct(_f) && is_struct(_e)) {
                var _subTarget = undefined;
                if (_target != undefined) {
                    _subTarget = _isInst ? variable_instance_get(_target, _k) : _target[$ _k];
                }
                __Cassette_LerpDeep(_f, _e, _t, _lerp, _subTarget, false);
            } 
            else if (is_array(_f) && is_array(_e)) {
                var _val = undefined;
                // If the user provided a custom lerp function use it.
                if (_lerp != lerp && _lerp != undefined) {
                    _val = _lerp(_f, _e, _t, _k);
                } else {
                    var _arr_len = min(array_length(_f), array_length(_e));
                    _val = array_create(_arr_len);
                    for (var _a = 0; _a < _arr_len; _a++) {
                        // Blend via merge_colour for color arrays, otherwise standard lerp.
                        if (_is_color) _val[_a] = merge_colour(_f[_a], _e[_a], _t);
                        else           _val[_a] = lerp(_f[_a], _e[_a], _t);
                    }
                }

                if (_target != undefined) {
                    if (_isInst) variable_instance_set(_target, _k, _val);
                    else         _target[$ _k] = _val;
                }
            }
            else {
                var _val = undefined;
                if (_lerp != lerp && _lerp != undefined) {
                    _val = _lerp(_f, _e, _t, _k);
                } else {
                    // Single value interpolation
                    if (_is_color) {
                         _val = merge_colour(_f, _e, _t);
                    } else {
                         _val = (is_numeric(_f) && is_numeric(_e)) ? lerp(_f, _e, _t) : _f;
                    }
                }

                if (_target != undefined) {
                    if (_isInst) variable_instance_set(_target, _k, _val);
                    else         _target[$ _k] = _val;
                }
            }
        }
        _i++;
    }
}