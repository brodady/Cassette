// Feather ignore all
/// @ignore  (Internal) __CassetteTape_PingPong([times], [apply_to_chain])
/// @desc    Ping-pongs the animation (A->B->A).
/// @param   {Real} [times] Number of full cycles. -1 is infinite.
/// @param   {Bool} [apply_to_chain] PingPong entire Tape chain (defaults to last Track/Tween).
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_PingPong(_times = -1, _applyToChain = false) {

    var _val = _times;
    if (__copyStructs && is_struct(_times)) {
        _val = variable_clone(_times);
    }

    if (_applyToChain) {
        // Tape
        __type = __CASSETTE_ANIM.PING_PONG;
        __loops = _val;
    } else {
        // Track
        var _t = array_last(__tracks);
        _t.type = __CASSETTE_ANIM.PING_PONG;
        _t.loops = _val;

        if (array_length(__tracks) == 1) {
            // Sync to Tape if single
            __loops = _val;
            __type = __CASSETTE_ANIM.PING_PONG;
        }

        if (__trackIndex == array_length(__tracks) - 1) {
            __trackLoops = _val;
        }
    }
    return self;
}
