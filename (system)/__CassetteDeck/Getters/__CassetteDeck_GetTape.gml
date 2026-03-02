// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_GetTape(target)
/// @desc    Retrieves safe Cassette Handle(s) for the given target(s).
/// @param   {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} _target The Key(s) or Handle(s).
/// @return  {Struct.Cassette|Array<Struct.Cassette>|Undefined}
/// @self CassetteDeck
function __CassetteDeck_GetTape(_target) {

    // Array Recursion
    if (is_array(_target)) {
        var _len = array_length(_target);
        var _results = array_create(_len);
        var _i = 0; repeat(_len) {
            _results[_i] = __CassetteDeck_GetTape(_target[_i]);
            _i++;
        }
        return _results;
    }
    else {
        var _core = undefined;

        // Direct Lookup
        if (is_string(_target)) {
            _core = __tapesMap[$ _target];
        }
        else if (is_struct(_target)) {
             if (variable_struct_exists(_target, "__id")) _core = __getCore(_target.__id);
             else if (variable_struct_exists(_target, "__active")) _core = _target;
        }

        if (_core != undefined) {
            return new Cassette(_core.__id, self);
        }
        
        // Tag/Group Lookup
        var _group = __CassetteDeck_Resolve(_target);
        var _gLen = array_length(_group);

        if (_gLen > 0) {
            var _groupResults = array_create(_gLen);
            var _j = 0; repeat(_gLen) {
                _groupResults[_j] = new Cassette(_group[_j].__id, self);
                _j++;
            }
            return _groupResults;
        }
        
        return undefined;
    }
}