// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Resolve(_input)
/// @desc Resolves mixed inputs (Strings, Handles, Arrays) into a clean array of Core Structs.
///       Handles Strings as both Specific Keys and Tags.
function __CassetteDeck_Resolve(_input) {
    var _result = [];
    if (_input == undefined) {
        var _i = 0;
        repeat(array_length(__tapesList)) {
            array_push(_result, __tapesList[_i]);
            _i++;
        }
        return _result;
    }

    var _inputs = is_array(_input) ? _input : [_input];

    var _i = 0; repeat(array_length(_inputs)) {
        var _item = _inputs[_i];
        var _core = undefined;

        // String (Key OR Tag)
        if (is_string(_item)) {
            // Check for Direct Key Match
            if (variable_struct_exists(__tapesMap, _item)) {
                _core = __tapesMap[$ _item];
                array_push(_result, _core);
            }

            // Scan for Tags (Add all matching active tapes)
            var _k = 0;
            repeat(array_length(__tapesList)) {
                var _t = __tapesList[_k];
                if (_t != _core && _t.__active && _t.hasTag(_item)) {
                    array_push(_result, _t);
                }
                _k++;
            }
        }
        // Cassette Handle
        else if (is_struct(_item) && variable_struct_exists(_item, "__id")) {
            _core = __getCore(_item.__id);
            if (_core != undefined) array_push(_result, _core);
        }
        // Already a Core
        else if (is_struct(_item) && variable_struct_exists(_item, "__active")) {
             _core = _item;
             array_push(_result, _core);
        }

        _i++;
    }

    return _result;
}