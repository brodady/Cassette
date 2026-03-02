// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_PingPong([times])
/// @desc    Ping-pongs the Mixtape sequence (A->B->A).
/// @param   {Real} [times] Number of full cycles. -1 is infinite.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_PingPong(_times = -1) {
    __type = __CASSETTE_ANIM.PING_PONG;
    __loops = _times;
    return self;
}
