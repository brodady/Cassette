// Feather ignore all
/// @ignore  (Internal) __CassetteTape_RemoveTag(tag)
/// @desc    Removes a tag from the tape.
/// @param   {String} tag The tag name.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_RemoveTag(_tag) {
    var _idx = -1;
    for (var _i = 0; _i < array_length(__tags); _i++) {
        if (__tags[_i] == _tag) {
            _idx = _i;
            break;
        }
    }
    
    if (_idx != -1) {
        array_delete(__tags, _idx, 1);
    }
    return self;
}