// Feather ignore all
/// @ignore  (Internal) __CassetteTape_To(value)
/// @desc    Sets the end value. Infers start value from target if missing.
/// @param   {Real|Struct} value The target value.
/// @return  {Struct.CassetteTape} Self
function __CassetteTape_To(_val) { 
    var _t = array_last(__tracks);

    var _shouldResolve = (_t.fromVal == undefined);
    if (!_shouldResolve && is_struct(_val) && !is_struct(_t.fromVal) && _t.fromVal == 0) {
        _shouldResolve = true;
    }

    if (_shouldResolve) {
        if (__target != undefined) {
            if (is_struct(_val)) _t.fromVal = __Cassette_FillStartValues(__target, _val);
            else _t.fromVal = 0;
        } else {
            if (is_struct(_val)) _t.fromVal = __Cassette_FillStartValues(undefined, _val);
            else _t.fromVal = 0;
        }
    }

    // Struct
    if (is_struct(_val)) {
        _t.toVal = (__copyStructs) ? variable_clone(_val) : _val;
        _t.propNames = variable_struct_get_names(_val);
    }
    // Struct + Scalar 
    else if (is_struct(_t.fromVal) && is_numeric(_val)) {
        
        _t.toVal = variable_clone(_t.fromVal);
        var _keys = (_t.propNames != undefined) ? _t.propNames : variable_struct_get_names(_t.fromVal);
        if (_t.propNames == undefined) _t.propNames = _keys;

        var _setScalar = function(_targetStruct, _keys, _vIn, _func) {
            var _i = 0;
            repeat(array_length(_keys)) {
                var _k = _keys[_i];
                var _current = _targetStruct[$ _k];
                
                if (is_struct(_current)) {
                    var _subKeys = variable_struct_get_names(_current);
                    _func(_current, _subKeys, _vIn, _func);
                } 
                else {
                    _targetStruct[$ _k] = _vIn;
                }
                _i++;
            }
        };
        _setScalar(_t.toVal, _keys, _val, _setScalar);
    }
    // Simple assignment
    else {
        _t.toVal = _val;
    }
    
    return self;
}