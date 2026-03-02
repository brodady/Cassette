// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Rewind()
/// @desc    Resets the sequence to the beginning.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Rewind() {

    __CassetteTape_HandleCallback(__onRewind);

    __trackIndex = 0;
    __timer = 0;
    __finished = false;
    __active = true;

    if (array_length(__tracks) > 0) {
        __CassetteTape_UpdateValue(__tracks[0].fromVal)
    } else {
        __val = 0;
    }
    
    __CASSETTE_RESET_TRACK;
    return self;
}
