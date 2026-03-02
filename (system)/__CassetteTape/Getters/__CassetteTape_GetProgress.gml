// Feather ignore all
/// @ignore  (Internal) __CassetteTape_GetProgress()
/// @desc    Returns the normalized progress (0.0 to 1.0) of the entire Tape sequence.
/// @return  {Real}
/// @self __CassetteTape
function __CassetteTape_GetProgress() {
    var _totalDur = __CassetteTape_GetDuration();
    if (_totalDur <= 0) return 0;

    var _elapsed = 0;
    for (var _i = 0; _i < __trackIndex; _i++) {
        var _t = __tracks[_i];
        var _d = __Cassette_ResolveValue(_t.duration);
        var _rawLoops = __Cassette_ResolveValue(_t.loops);
        var _l = (_rawLoops < 0) ? 0 : _rawLoops;
        
        _elapsed += _d * (1 + _l);
    }

    _elapsed += __timer;

    return clamp(_elapsed / _totalDur, 0, 1);
}