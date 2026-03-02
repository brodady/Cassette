// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Next()
/// @desc    Starts a new track segment, inheriting the end value of the previous track.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Next() {
    var _prevTo = undefined;
    var _i = array_length(__tracks) - 1;
    while (_i >= 0) {
        var _t = __tracks[_i];
        if (!_t.isWait) {
            _prevTo = _t.toVal;
            break;
        }
        _i--;
    }

    var _props = undefined;
    if (is_struct(_prevTo)) {
        _props = variable_struct_get_names(_prevTo);
    }

    var _def = {
        fromVal: _prevTo,
        toVal: _prevTo, 
        duration: 1.0,
        ease: __CASSETTE_DEFAULT_EASE, 
        lerpFunc: undefined,
        isCurve: false,
        type: __CASSETTE_ANIM.ONCE, 
        loops: 0, 
        isWait: false,
        onTrackEnd: undefined,
        propNames: _props
    };
    
    array_push(__tracks, _def);
    if (array_length(__tracks) == 1) __CassetteTape_ResetTrack();
    
    return self;
}
