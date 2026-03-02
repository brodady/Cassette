// Feather ignore all
/// @ignore  __CassetteTape_By(amount)
/// @desc    Sets target relative to start. Infers start value from target if missing.
/// @param   {Real|Struct} amount The relative amount.
/// @return  {Struct.CassetteTape} Self
function __CassetteTape_By(_amount) {
    var _t = array_last(__tracks);

    var _shouldResolve = (_t.fromVal == undefined);
    if (!_shouldResolve && is_struct(_amount) && !is_struct(_t.fromVal) && _t.fromVal == 0) {
        _shouldResolve = true;
    }

    if (_shouldResolve) {
        if (__target != undefined) {
            if (is_struct(_amount)) _t.fromVal = __Cassette_FillStartValues(__target, _amount);
            else _t.fromVal = 0;
        } else {
            if (is_struct(_amount)) _t.fromVal = __Cassette_FillStartValues(undefined, _amount);
            else _t.fromVal = 0;
        }
    }

    // Struct + Struct
    if (is_struct(_t.fromVal) && is_struct(_amount)) {
        _t.propNames = variable_struct_get_names(_amount);
        _t.toVal = {};

        var _addRecursive = function(_dest, _source, _add, _func) {
            var _keys = variable_struct_get_names(_add);
            var _i = 0; 
            repeat(array_length(_keys)) {
                var _k = _keys[_i];
                if (variable_struct_exists(_source, _k)) {
                    var _sVal = _source[$ _k];
                    var _aVal = _add[$ _k];
                    
                    if (is_struct(_sVal) && is_struct(_aVal)) {
                        _dest[$ _k] = {};
                        _func(_dest[$ _k], _sVal, _aVal, _func);
                    } else {
                        _dest[$ _k] = _sVal + _aVal;
                    }
                }
                _i++;
            }
        };
        _addRecursive(_t.toVal, _t.fromVal, _amount, _addRecursive);

    }
    // Struct + Scalar 
    else if (is_struct(_t.fromVal) && is_numeric(_amount)) {
        _t.toVal = variable_clone(_t.fromVal);
        
        var _keys = (_t.propNames != undefined) ? _t.propNames : variable_struct_get_names(_t.fromVal);
        if (_t.propNames == undefined) _t.propNames = _keys;

        var _addScalar = function(_targetStruct, _keys, _val, _func) {
            var _i = 0; repeat(array_length(_keys)) {
                var _k = _keys[_i];
                var _v = _targetStruct[$ _k];
                if (is_struct(_v)) {
                    var _subKeys = variable_struct_get_names(_v);
                    _func(_v, _subKeys, _val, _func);
                } else if (is_numeric(_v)) {
                    _targetStruct[$ _k] += _val;
                }
                _i++;
            }
        };
        _addScalar(_t.toVal, _keys, _amount, _addScalar);
    }
    // Scalar + Scalar
    else {
        _t.toVal = _t.fromVal + _amount;
    }

    return self;
}