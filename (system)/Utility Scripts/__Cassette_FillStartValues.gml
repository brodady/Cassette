// Feather ignore all
/// @ignore (Internal) __Cassette_FillStartValues(target, structure)
/// @desc Recursively reads values from the target that match the structure of the input.
function __Cassette_FillStartValues(_target, _structure) {
    var _dest = {};
    var _keys = variable_struct_get_names(_structure);
    var _len = array_length(_keys);
    var _i = 0; 

    repeat(_len) {
        var _k = _keys[_i];
        var _valOnTarget = undefined;
        var _targetHasKey = false;

        if (is_struct(_target)) {
            if (variable_struct_exists(_target, _k)) {
                _valOnTarget = _target[$ _k];
                _targetHasKey = true;
            }
        } 
        else if (instance_exists(_target)) {
            if (variable_instance_exists(_target, _k)) {
                _valOnTarget = variable_instance_get(_target, _k);
                _targetHasKey = true;
            }
        }

        if (_targetHasKey) {
            if (is_struct(_structure[$ _k]) && is_struct(_valOnTarget)) {
                _dest[$ _k] = __Cassette_FillStartValues(_valOnTarget, _structure[$ _k]);
            } else {
                _dest[$ _k] = _valOnTarget;
            }
        } else {
            if (is_struct(_structure[$ _k])) {
                _dest[$ _k] = __Cassette_FillStartValues(undefined, _structure[$ _k]);
            } else {
                _dest[$ _k] = 0; 
            }
        }
        _i++;
    }
    return _dest;
}