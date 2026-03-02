// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_IsActive([key_or_array])
/// @desc    Checks if animation(s) exist and are currently active.
/// @param   {String|Array<String>|Undefined} [key] The ID(s) to check.
///          - Undefined: Returns true if ANY tape in the deck is active.
///          - Array: Returns true if ANY tape in the array is active.
///          - String: Returns true if that specific tape is active.
/// @return  {Bool}
function __CassetteDeck_IsActive(_key = undefined) {
    if (_key == undefined) {
        var _i = 0;
        repeat(array_length(__tapesList)) {
            if (__tapesList[_i].__active) return true;
            _i++;
        }
        return false;
    } else if (is_array(_key)) {
        var _i = 0;
        repeat(array_length(_key)) {
            var _t = __tapesMap[$ _key[_i]];
            if (_t != undefined && _t.__active) return true;
            _i++;
        }
        return false;
    } else {
        var _t = __tapesMap[$ _key];
        return (_t != undefined && _t.__active);
    }
}