// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_SetStartDelay(duration)
/// @desc    Sets a delay before the entire Mixtape begins playing.
/// @param   {Real} duration Delay in frames or seconds.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_SetStartDelay(_dur) {
    __startDelay = _dur;
    return self;
}
