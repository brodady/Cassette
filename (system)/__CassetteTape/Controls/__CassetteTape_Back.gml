// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Back()
/// @desc    Jumps to the start or the previous track.
///          Conditional:
///             - If we are deep into the current track, just rewind to start of this track.
///             - If we are already at the start, go to previous track (configure threshold via __CASSETTE_EPSILON in 'Cassette/(internal)/__CassetteMacros')
///             - If finished, resurrect.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Back() {

    __CassetteTape_HandleCallback(__onBack);

    if (__timer > __CASSETTE_EPSILON) {
        __timer = 0;
        __direction = 1;
        __loops = __tracks[__trackIndex].loops;
    }
    else if (__trackIndex > 0) {
        __trackIndex--;
        __CASSETTE_RESET_TRACK;
    }
    if (__finished) {
        __finished = false;
        __active = true;
    }
    
    __CassetteTape_Calculate();
    return self;
}
