// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Loop([times])
/// @desc    Repeats the Mixtape sequence.
/// @param   {Real} [times] Number of loops. -1 is infinite.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Loop(_times = -1) {
    __type = __CASSETTE_ANIM.LOOP;
    __loops = _times;
    return self;
}
