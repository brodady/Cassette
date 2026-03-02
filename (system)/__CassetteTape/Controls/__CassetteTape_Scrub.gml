// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Scrub(input, attack, decay, [ease])
/// @desc    Drives playback speed based on input (Velocity Impulse).
///          Great for "Jog-Wheel" style control.
///          This should be called in a step event!
/// @param {Real} input      The target speed/direction.
/// @param {Real} attack     Lerp amount when accelerating.
/// @param {Real} decay      Lerp amount when decelerating.
/// @param {Function} [ease] Optional easing for the speed curve.
/// @return {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Scrub(_input, _att, _dec, _ease = undefined) {
    if (__manualPause) return self;

    var _in  = __Cassette_ResolveValue(_input);
    var _at  = __Cassette_ResolveValue(_att);
    var _dc  = __Cassette_ResolveValue(_dec);

    var _isAccel = abs(_in) > abs(__reactVel);
    var _lerpAmt = _isAccel ? _at : _dc;
    
    __reactVel = lerp(__reactVel, _in, _lerpAmt);
    var _finalSpeed = __reactVel;
    
    if (_ease != undefined) {
        var _sign = sign(_finalSpeed);
        var _mag = clamp(abs(_finalSpeed), 0, 1);
        _finalSpeed = _ease(_mag) * _sign;
    }

    __speed = _finalSpeed;
    
    // Auto-Pause if signal is dead
    if (abs(__speed) < 0.001 && _in == 0) {
        __paused = true;
        __reactVel = 0;
    } else {
        __paused = false;
    }
    return self;
}