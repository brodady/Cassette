// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_IsPlaying([target])
/// @desc    Checks if animation(s) are active and NOT paused.
/// @param   {String|Struct|Array} [target] The Cassette struct(s) or String Key(s) to check.
/// @return  {Bool}
/// @self CassetteDeck
function __CassetteDeck_IsPlaying(_target = undefined) {
    var _candidates = __CassetteDeck_Resolve(_target);

    var _i = 0;
    repeat(array_length(_candidates)) {
        var _t = _candidates[_i];
        if (_t.__active && !_t.__paused) return true;
        _i++;
    }
    
    return false;
}
