// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Duration(amount)
/// @desc    Sets the duration of the current track.
/// @param   {Real || Struct} amount Time in frames or seconds.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Duration(_val) {
    var _t = array_last(__tracks);
    if (__copyStructs && is_struct(_val)) {
        _t.duration = variable_clone(_val);
    } else {
        _t.duration = _val;
    }
    return self;
}
