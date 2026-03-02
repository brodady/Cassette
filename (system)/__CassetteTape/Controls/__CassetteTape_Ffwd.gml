// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Ffwd()
/// @desc    Jumps immediately to the end of the sequence.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Ffwd() {
    if (__finished) return self;

    __CassetteTape_HandleCallback(__onFfwd);

    var _lastIdx = array_length(__tracks) - 1;
    var _lastTrack = __tracks[_lastIdx];

    __trackIndex = _lastIdx;
    __trackLoops = _lastTrack.loops;

    var _loops = (__trackLoops < 0) ? 0 : __trackLoops;
    __timer = _lastTrack.duration * (1 + _loops);

    __CassetteTape_UpdateValue(_lastTrack.toVal);

    __CassetteTape_HandleCallback(__onUpdate);
    __CassetteTape_HandleCallback(__onEnd);

    return self;
}
