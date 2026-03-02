// Feather ignore all
/// @ignore  (Internal) __CassetteTape_GetTime()
/// @desc    Returns the playhead value of the current Track on the Tape (frames/seconds).
/// @return  {Real}
/// @self __CassetteTape
function __CassetteTape_GetTime() {
    return __timer;
}
