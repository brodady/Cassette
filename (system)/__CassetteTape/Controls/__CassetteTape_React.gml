// Feather ignore all
/// @ignore  (Internal) __CassetteTape_React(target, tension, damping, [snap_threshold])
/// @self __CassetteTape
function __CassetteTape_React(_target, _tension, _damping, _snap = 0.001) {

    var _targ = __Cassette_ResolveValue(_target);
    var _tens = __Cassette_ResolveValue(_tension);
    var _damp = __Cassette_ResolveValue(_damping);
    var _snp  = __Cassette_ResolveValue(_snap);
    var _currentSpeed = __Cassette_ResolveValue(__speed);

    // (Not sure if springs should be manually pausable or not, might revisit this.)
    if (__paused) {
        if (abs(__timer - _targ) > _snp) {
            __paused = false;
            __manualPause = false;
            if (__deck != undefined) __deck.__playingCount++;
        } else {
            return self;
        }
    }

    // Physics
    var _displacement = __timer - _targ;
    var _force = -_tens * _displacement - _damp * _currentSpeed;
    
    // Apply
    __speed = _currentSpeed + _force;
    
    if (abs(_displacement) < _snp && abs(__speed) < _snp) {
        __timer = _targ;
        __speed = 0;
        __paused = true;
        if (__deck != undefined) __deck.__playingCount--;
        __CassetteTape_Calculate(__timer);
    }

    return self;
}