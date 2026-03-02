// Feather ignore all
/// @ignore  (Internal) __CassetteTape_AddTag(tag)
/// @desc    Adds a tag to the tape for group control.
/// @param   {String} tag The tag name.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_AddTag(_tag) {
    if (!__CassetteTape_HasTag(_tag)) {
        array_push(__tags, _tag);
    }
    return self;
}