// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Rewind()
/// @desc    Resets the timeline and start delays to the beginning.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Rewind() { 
    var _wasPaused = __paused;

    __currentDelay = 0;

    stop();

    if (!_wasPaused) {
        play(); 
    }

    return self;
}
