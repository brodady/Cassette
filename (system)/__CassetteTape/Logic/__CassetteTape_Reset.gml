// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Reset(_key, _deck, _id = undefined) Resets the tape for reuse from the pool.
/// @self __CassetteTape
function __CassetteTape_Reset(_key, _deck, _id = undefined) {
    __key = _key;
    __deck = _deck;
    __target = undefined;
    __targetRef = undefined;
    __bindScopeRef = undefined;
    __bindKey = undefined;
    __parent = _deck;
    if (_id != undefined) __id = _id;

    __CASSETTE_REGISTER_TRACK; 

    // Reset State
    __active = true;
    __paused = !_deck.__autoStart;
    __finished = false;
    __copyStructs = false;

    if (!__paused) _deck.__playingCount++;

    // Reset Track
    var _len = array_length(__tracks);
    if (!is_array(__tracks)) __tracks = [];
    if (_len == 0) array_push(__tracks, {});
    if (_len > 1) {
        for (var _i = 1; _i < _len; _i++) {
            __tracks[_i] = undefined;
        }
        array_resize(__tracks, 1);
    }
    
    var _t = __tracks[0];
    _t.fromVal      = 0;
    _t.toVal        = 0;
    _t.duration     = 1.0;
    _t.ease         = __CASSETTE_DEFAULT_EASE;
    _t.lerpFunc     = _deck.__defaultLerp;
    _t.isCurve      = false;
    _t.type         = __CASSETTE_ANIM.ONCE;
    _t.loops        = 0;
    _t.isWait       = false;
    _t.onTrackEnd   = undefined;
    _t.propNames    = undefined;

    __trackIndex = 0;
    __timer = 0;
    __val = 0;
    __speed = 1.0;
    __reactVel = 0;
    __direction = 1;
    __loops = 0;

    __CASSETTE_TAPE_CLEAR_CALLBACKS;
    return self;
}