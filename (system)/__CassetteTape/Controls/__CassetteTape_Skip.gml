// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Skip()
/// @desc    Jumps to the start of the next track.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Skip() {
    if (__isSkipping) return self;
    __isSkipping = true;

    var _t = __tracks[__trackIndex];

    __CassetteTape_HandleCallback(__onSkip);
    __CassetteTape_HandleCallback(_t.onTrackEnd);
    __CassetteTape_HandleCallback(__onAnyTrackEnd);

    if (__trackIndex < array_length(__tracks) - 1) {
        __trackIndex++;
        __CASSETTE_RESET_TRACK;
        __CassetteTape_Calculate();
    } else {
        __CassetteTape_Ffwd();
    }

    __isSkipping = false;
    return self;
}
