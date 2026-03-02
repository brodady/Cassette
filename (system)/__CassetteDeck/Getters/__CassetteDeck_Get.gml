// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Get(target, [default])
/// @desc    Directly retrieves the current interpolated value of animation(s).
/// @param   {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} target The Key(s) or Handle(s).
/// @param   {Any} [default] Value to return if animation doesn't exist.
/// @return  {Any|Array<Any>} A single value or an array of values.
/// @self CassetteDeck
function __CassetteDeck_Get(_target, _default = undefined) {

    // Array Recursion
    if (is_array(_target)) {
        var _len = array_length(_target);
        var _results = array_create(_len);
        var _i = 0; repeat(_len) {
            _results[_i] = __CassetteDeck_Get(_target[_i], _default);
            _i++;
        }
        return _results;
    }
    else {
        var _core = undefined;

        // Direct Lookup (Optimization + Scalar Return)
        if (is_string(_target)) {
            _core = __tapesMap[$ _target];
        } 
        else if (is_struct(_target)) {
             if (variable_struct_exists(_target, "__id")) _core = __getCore(_target.__id);
             else if (variable_struct_exists(_target, "__active")) _core = _target;
        }

        // Found specific tape? Return single value.
        if (_core != undefined) {
            return _core.get();
        }

        // If we didn't find a single tape, try resolving as a Tag/Group.
        var _group = __CassetteDeck_Resolve(_target);
        var _gLen = array_length(_group);
        
        if (_gLen > 0) {
            var _groupResults = array_create(_gLen);
            var _j = 0; repeat(_gLen) {
                _groupResults[_j] = _group[_j].get();
                _j++;
            }
            return _groupResults;
        }
        
        return _default;
    }
}