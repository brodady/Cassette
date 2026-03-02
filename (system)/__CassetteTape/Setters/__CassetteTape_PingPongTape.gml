// Feather ignore all
/// @ignore  (Internal) __CassetteTape_PingPongTape([times])
/// @desc    Ping-pongs the ENTIRE tape sequence (A->B->C->B->A).
/// @param   {Real} [times] Number of full cycles. -1 is infinite.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_PingPongTape(_times = -1) {
    var _val = _times;
    if (__copyStructs && is_struct(_times)) {
        _val = variable_clone(_times);
    }
    __loops = _val;
    __type = __CASSETTE_ANIM.PING_PONG;
    return self;
}