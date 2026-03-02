// Feather ignore all
/// @ignore  (Internal) __CassetteTape_GetDuration()
/// @desc    Returns the total duration of all tracks, accounting for finite loops/pingpongs.
/// @return  {Real}
/// @self __CassetteTape
function __CassetteTape_GetDuration() {
    var _dur = 0;
    var _i = 0;
    repeat(array_length(__tracks)) {
        var _t = __tracks[_i];
        var _trackDur = __Cassette_ResolveValue(_t.duration);
        var _rawLoops = __Cassette_ResolveValue(_t.loops);
        var _loopCount = (_rawLoops < 0) ? 0 : _rawLoops;
        
        _dur += _trackDur * (1 + _loopCount);
        _i++;
    }
    return _dur;
}
