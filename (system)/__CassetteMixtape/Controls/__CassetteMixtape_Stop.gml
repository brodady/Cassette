// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Stop()
/// @desc    Stops playback, resets the timer, and stops all children.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Stop() { 
    __paused = true;
    __timer = 0; 
    
    var _i = 0; repeat(array_length(__items)) {
        __items[_i].started = false;
        __items[_i].tape.stop();
        _i++;
    }
    return self; 
}
