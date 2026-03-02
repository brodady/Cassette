// Feather ignore all
/// @ignore (Internal) __CassetteTape_GetName()
/// @desc   Returns the key of an animation.
/// @return {String} CassetteTape key or anonymous id if undefined.
/// @self __CassetteTape
function __CassetteTape_GetName() {
    return (__key != undefined) ? __key : ("<anonymous_tape:" + string(__id) + ">");
}
