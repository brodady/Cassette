// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Loop([times], [apply_to_chain])
/// @desc    Repeats the current track.
/// @param   {Real} [times] Number of loops. -1 is infinite.
/// @param   {Bool} [apply_to_chain] Loop entire Tape chain (defaults to last Track/Tween).
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Loop(_times = -1) {
    var _val = _times;
    if (__copyStructs && is_struct(_times)) {
        _val = variable_clone(_times);
    }

    var _t = array_last(__tracks);
    _t.type = __CASSETTE_ANIM.LOOP;
    _t.loops = _val;

    if (array_length(__tracks) == 1) {
        __loops = _val;
        __type = __CASSETTE_ANIM.LOOP;
    }

    if (__trackIndex == array_length(__tracks) - 1) {
        __trackLoops = _val;
    }

    return self;
}