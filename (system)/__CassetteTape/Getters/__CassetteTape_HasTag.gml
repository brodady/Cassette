// Feather ignore all
/// @ignore  (Internal) __CassetteTape_HasTag(tag)
/// @desc    Checks if the tape possesses a specific tag.
/// @param   {String} tag The tag to check.
/// @return  {Bool}
/// @self __CassetteTape
function __CassetteTape_HasTag(_tag) {
    var _i = 0; 
    repeat(array_length(__tags)) {
        if (__tags[_i] == _tag) return true;
        _i++;
    }
    return false;
}