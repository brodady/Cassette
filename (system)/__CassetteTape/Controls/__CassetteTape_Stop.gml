// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Stop()
/// @desc    Stops playback and resets to start. Keeps tape in memory.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Stop() { 

    __CassetteTape_HandleCallback(__onStop);

    var _isRegistered = __CASSETTE_TAPE_CHECK_REGISTERED;
    if (!__paused && _isRegistered) {
        __deck.__playingCount--;
    }

    __paused = true;
    __manualPause = true;
    __finished = false;
    __trackIndex = 0;
    __timer = 0;

    if (array_length(__tracks) > 0) {
        var _start = __tracks[0].fromVal;
        __CassetteTape_UpdateValue(_start);
    } else {
        __val = 0;
    }
    
    __CASSETTE_RESET_TRACK;

   __CassetteTape_HandleCallback(__onUpdate)

    return self; 
}
