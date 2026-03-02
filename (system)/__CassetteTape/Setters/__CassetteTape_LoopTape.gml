// Feather ignore all
/// @ignore  (Internal) __CassetteTape_LoopTape([times])
/// @desc    Repeats the ENTIRE tape sequence.
/// @param   {Real} [times] Number of loops. -1 is infinite.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_LoopTape(_times = -1) {
    var _val = _times;
    if (__copyStructs && is_struct(_times)) {
        _val = variable_clone(_times);
    }
    __loops = _val;
    __type = __CASSETTE_ANIM.LOOP;
    return self;
}
