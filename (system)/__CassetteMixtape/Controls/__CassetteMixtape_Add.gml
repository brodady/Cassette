// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Add(tape, [position])
/// @desc    Adds a Tape (or another Mixtape) to the timeline and keeps the timeline sorted.
/// @param   {Struct.Cassette|String|Struct} tape The Handle, Key, or Core of the Tape/Mixtape.
/// @param   {String|Real} [position]  GSAP-style position: Number (absolute), "+=10" (gap), "-=5" (overlap), "<" (sync).
/// @param   {Struct} [options] Configuration (e.g. { block: false }).
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Add(_tape, _pos = undefined, _options = undefined) {

    var _core = undefined;
    // Resolve Inputs
    if (is_string(_tape)) {
        if (__deck != undefined) {
            _core = __deck.__tapesMap[$ _tape];
        }
        if (_core == undefined) {
             __CassetteError("Add", { message: "Tape with key '" + _tape + "' not found in Deck." });
             return self;
        }
    }
    // Cassette Handle
    else if (is_struct(_tape) && variable_struct_exists(_tape, "__deck")) {
        _core = _tape.__deck.__getCore(_tape.__id);
        if (_core == undefined) {
             __CassetteError("Add", { message: "Cannot add a destroyed/invalid tape to a Mixtape." });
             return self;
        }
    }
    // Raw Core
    else {
        _core = _tape;
    }


    if (!is_struct(_core)) {
         __CassetteError("Add", { message: "Invalid tape argument provided." });
         return self;
    }

    // Transfer Ownership
    if (_core.__parent != undefined && _core.__parent != self) {
        // If the parent is the Deck, we do NOT detach it from the list.
        // We simply take over the parent reference so the Deck stops stepping it.
        // If the parent is another Mixtape, we DO detach it.
        if (_core.__parent != __deck) {
            if (variable_struct_exists(_core.__parent, "__DetachChild")) {
                _core.__parent.__DetachChild(_core);
            }
        }
    }
    _core.__parent = self;

    // Duration Calculation
    var _baseDur = 0;
    if (variable_struct_exists(_core, "getDuration")) {
        _baseDur = _core.getDuration();
    } 
    else if (variable_struct_exists(_core, "__tracks")) {
        var _i = 0;
        repeat(array_length(_core.__tracks)) {
            var _d = __Cassette_ResolveValue(_core.__tracks[_i].duration);
            _baseDur += _d;
            _i++;
        }
    }

    // Parse Options
    var _shouldBlock = true;
    var _speedVal    = 1.0;
    var _forceDur    = undefined;
    if (is_struct(_options)) {
        if (variable_struct_exists(_options, "block"))    _shouldBlock = _options.block;
        if (variable_struct_exists(_options, "speed"))    _speedVal    = _options.speed;
        if (variable_struct_exists(_options, "duration")) _forceDur    = _options.duration;
    }

    // Config Logic: Duration overrides Speed
    var _finalDur = _baseDur;
    if (_forceDur != undefined) {
        // Stretch/Squash
        _finalDur = _forceDur;
        if (_finalDur != 0) _speedVal = _baseDur / _finalDur;
    } 
    else {
        // Duration shrinks as speed grows
        if (_speedVal != 0) _finalDur = _baseDur / _speedVal;
    }

    // Parse Position 
    var _startTime = __headTime;
    if (_pos != undefined) {
        if (is_real(_pos)) {
            _startTime = _pos;
        } 
        else if (is_string(_pos)) {
            if (_pos == "<") {
                _startTime = __lastStart;
            } else {
                var _op = string_copy(_pos, 1, 2);
                var _val = real(string_delete(_pos, 1, 2));
                if (_op == "+=") _startTime = __headTime + _val;
                if (_op == "-=") _startTime = __headTime - _val;
            }
        }
    }
    
    // Add to timeline
    array_push(__items, {
        tape: _core,
        start: _startTime,
        finish: _startTime + _finalDur, 
        started: false,
        block: _shouldBlock,
        speed: _speedVal 
    });

    // Sort items by start time
    array_sort(__items, function(_a, _b) {
        return _a.start - _b.start;
    });

    // Update Builder State
    __lastStart = _startTime;
    __headTime  = max(__headTime, _startTime + _finalDur);
    __duration  = max(__duration, __headTime);
    
    return self;
}