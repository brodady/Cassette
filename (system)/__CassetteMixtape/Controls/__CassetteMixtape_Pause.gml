// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Pause()
/// @desc    Pauses the Mixtape and all its active children.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Pause() { 
    __paused = true; 
    
    var _i = 0; repeat(array_length(__items)) {
        if (__items[_i].started) __items[_i].tape.pause();
        _i++;
    }
    
    return self; 
}
