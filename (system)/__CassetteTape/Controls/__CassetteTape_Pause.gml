// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Pause()
/// @desc    Pauses the tape.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Pause() { 
    var _isRegistered = (__deck != undefined) && variable_struct_exists(__deck.__tapesMap, __key) && (__deck.__tapesMap[$ __key] == self);
    
    if (!__paused) {
        __paused = true;
        __manualPause = true;
        if (_isRegistered) __deck.__playingCount--;

        __CassetteTape_HandleCallback(__onPause)
    }
    return self;
}
