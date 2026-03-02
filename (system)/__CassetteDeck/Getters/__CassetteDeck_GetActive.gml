// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_GetActive([filter])
/// @desc    Returns an array of HANDLES for animations that are active (Playing OR Paused).
/// @param   {String|Struct|Array|Undefined} [filter] If provided, limits the check to these targets.
/// @return  {Array<Struct.Cassette>} Array of Cassette Handles.
/// @self CassetteDeck
function __CassetteDeck_GetActive(_filter = undefined) {
    var _results = [];
    var _candidates = (_filter == undefined) ? __tapesList : __CassetteDeck_Resolve(_filter);

    var _i = 0; repeat(array_length(_candidates)) {
        var _t = _candidates[_i];
        if (_t.__active) {
            array_push(_results, new Cassette(_t.__id, self));
        }
        _i++;
    }
    
    return _results;
}