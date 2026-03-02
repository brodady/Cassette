// Feather ignore all
/// @func    Cassette(id, deck)
/// @desc    The public handle for an animation (Tape/MixTape/VideoTape).
///          References internal data held by the Deck.
/// @param   {Real} id    The unique integer ID of the tape.
/// @param   {Struct.CassetteDeck} deck The manager instance holding the tape logic.
function Cassette(_id, _deck) constructor {
    __id   = _id;
    __deck = _deck;

    #region BUILDER METHODS (Chainable)

    /// @func    next()
    /// @desc    Starts a new track segment, inheriting the end value of the previous track.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static next = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "next")) _c.next();
        return self;
    }

    /// @func    wait(duration)
    /// @desc    Adds a pause to the sequence.
    /// @param   {Real} duration Time in frames or seconds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static wait = function(_dur) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "wait")) _c.wait(_dur);
        return self;
    }

    /// @func    hold()
    /// @desc    Sets the current track to hold indefinitely at the start/end bounds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static hold = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "hold")) _c.hold();
        return self;
    }

    /// @func    from(value)
    /// @desc    Sets the start value of the current track.
    /// @param   {Any} value The start value (Real or Struct).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static from = function(_val) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "from")) _c.from(_val);
        return self;
    }

    /// @func    to(value)
    /// @desc    Sets the end value of the current track.
    /// @param   {Any} value The target value (Real or Struct).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static to = function(_val) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "to")) _c.to(_val);
        return self;
    }

    /// @func    fromTo(value,  value)
    /// @desc    Sets the start AND end value of the current track (shorthand).
    /// @param   {Any} value The start value (Real or Struct).
    /// @param   {Any} value The target value (Real or Struct).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static fromTo = function(_start, _end) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "from")) {
            _c.from(_start).to(_end);
        }
        return self;
    }

    /// @func    by(amount)
    /// @desc    Sets the target value RELATIVE to the start value.
    /// @param   {Any} amount The relative change (Real or Struct).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static by = function(_amt) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "by")) _c.by(_amt);
        return self;
    }

    /// @func    duration(amount)
    /// @desc    Sets the duration of the current track.
    /// @param   {Real} amount Time in frames or seconds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static duration = function(_dur) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "duration")) _c.duration(_dur);
        return self;
    }

    /// @func    ease(function_or_curve)
    /// @desc    Sets the easing function or Animation Curve.
    /// @param   {Function|Struct.GMAnimCurve} function_or_curve Easing function or AnimCurve Asset.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static ease = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "ease")) _c.ease(_func);
        return self;
    }

    /// @func    loop([times])
    /// @desc    Repeats the current track.
    /// @param   {Real} [times] Number of loops. -1 is infinite (default).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static loop = function(_times = -1) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "loop")) _c.loop(_times);
        return self;
    }

    /// @func    loopTape([times])
    /// @desc    Repeats the ENTIRE sequence.
    /// @param   {Real} [times] Number of loops. -1 is infinite (default).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static loopTape = function(_times = -1) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "loopTape")) _c.loopTape(_times);
        return self;
    }

    /// @func    pingpong([times])
    /// @desc    Ping-pongs the current track (A->B->A).
    /// @param   {Real} [times] Number of full cycles. -1 is infinite (default).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static pingpong = function(_times = -1) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "pingpong")) _c.pingpong(_times);
        return self;
    }

    /// @func    pingpongTape([times])
    /// @desc    Ping-pongs the ENTIRE sequence (A->B->C->B->A).
    /// @param   {Real} [times] Number of full cycles. -1 is infinite (default).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static pingpongTape = function(_times = -1) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "pingpongTape")) _c.pingpongTape(_times);
        return self;
    }

    /// @func    lerpFunc(function)
    /// @desc    Sets a custom interpolation function (e.g. angle_lerp) for this track.
    /// @param   {Function} function The function to use. Must accept (from, to, t).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static lerpFunc = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "lerpFunc")) _c.lerpFunc(_func);
        return self;
    }

    /// @func    startDelay(duration)
    /// @desc    Sets a start delay before the tape fires via a special '.wait' at the beginning of the Tape.
    /// @param   {Real} duration Delay in frames or seconds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static startDelay = function(_dur) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "startDelay")) _c.startDelay(_dur);
        return self;
    }

    /// @func    add(tape, [position], [options])
    /// @desc    (Mixtape Only) Adds a Tape to the timeline.
    /// @param   {Struct} tape The tape to add.
    /// @param   {Any} [position] Insertion point (Time or Label).
    /// @param   {Struct} [options] Config struct (e.g. { block: false }).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteMixtape
    static add = function(_tape, _pos=undefined, _options=undefined) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "add")) {
            _c.add(_tape, _pos, _options);
        } else {
             __CassetteError("Handle", { message: "Cannot call .add() on a standard Tape." });
        }
        return self;
    }

    /// @func    jump(key)
    /// @desc    (Mixtape Only) Jumps the timeline to the start of a specific item.
    /// @param   {String} key The key of the item to jump to.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteMixtape
    static jump = function(_key) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "jump")) _c.jump(_key);
        return self;
    }

    /// @func    bind(target)
    /// @desc    Sets a specific instance to this animation for property binding.
    /// @param   {Struct|Asset.GMObject} target The instance to bind properties to.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static bind = function(_target) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "bind")) _c.bind(_target);
        return self;
    }

    /// @func    clone()
    /// @desc    Enables struct cloning (Safe Mode).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static clone = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "clone")) _c.clone();
        return self;
    }

    /// @func    addTag(tag)
    /// @desc    Adds a tag for group control.
    /// @param   {String} tag
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static addTag = function(_tag) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "addTag")) _c.addTag(_tag);
        return self;
    }

    /// @func    removeTag(tag)
    /// @desc    Removes a tag.
    /// @param   {String} tag
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static removeTag = function(_tag) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "removeTag")) _c.removeTag(_tag);
        return self;
    }
    #endregion

    #region CALLBACK SETTERS

    /// @func    onUpdate(callback, [interval])
    /// @desc    Sets a function to run every frame (or interval) this tape is active.
    /// @param   {Function} callback Receives current value as argument.
    /// @param   {Real} [interval] Optional. Run every N frames/seconds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onUpdate = function(_func, _interval=undefined) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onUpdate")) _c.onUpdate(_func, _interval);
        return self;
    }

    /// @func    onEnd(callback)
    /// @desc    Sets a function to run when the entire sequence finishes.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onEnd = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onEnd")) _c.onEnd(_func);
        return self;
    }

    /// @func    onTrackEnd(callback)
    /// @desc    Sets a function to run when the current track (segment) finishes.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onTrackEnd = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onTrackEnd")) _c.onTrackEnd(_func);
        return self;
    }

    /// @func    anyTrackEnd(callback)
    /// @desc    Sets a function to run whenever ANY track on this tape finishes.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onAnyTrackEnd = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onAnyTrackEnd")) _c.onAnyTrackEnd(_func);
        return self;
    }

    /// @func    onPlay(callback)
    /// @desc    Sets a function to run when .play() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onPlay = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onPlay")) _c.onPlay(_func);
        return self;
    }

    /// @func    onPause(callback)
    /// @desc    Sets a function to run when .pause() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onPause = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onPause")) _c.onPause(_func);
        return self;
    }

    /// @func    onStop(callback)
    /// @desc    Sets a function to run when .stop() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onStop = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onStop")) _c.onStop(_func);
        return self;
    }

    /// @func    onRewind(callback)
    /// @desc    Sets a function to run when .rewind() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onRewind = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onRewind")) _c.onRewind(_func);
        return self;
    }

    /// @func    onFfwd(callback)
    /// @desc    Sets a function to run when .ffwd() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onFfwd = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onFfwd")) _c.onFfwd(_func);
        return self;
    }

    /// @func    onSeek(callback)
    /// @desc    Sets a function to run when .seek() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onSeek = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onSeek")) _c.onSeek(_func);
        return self;
    }

    /// @func    onSkip(callback)
    /// @desc    Sets a function to run when .skip() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onSkip = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onSkip")) _c.onSkip(_func);
        return self;
    }

    /// @func    onBack(callback)
    /// @desc    Sets a function to run when .back() is called.
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onBack = function(_func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onBack")) _c.onBack(_func);
        return self;
    }

    /// @func    onFrame(index, callback)
    /// @desc    Sets a callback for a specific time index (frame/second, except for Video Tapes which are always frames).
    /// @param   {Real} index The time index (integer).
    /// @param   {Function} callback The function to execute.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static onFrame = function(_index, _func) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "onFrame")) _c.onFrame(_index, _func);
        return self;
    }
    #endregion

    #region CONTROL METHODS

    /// @func    play()
    /// @desc    Resumes the tape.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static play = function(_params = undefined) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "play")) _c.play(_params);
        return self;
    }

    /// @func    pause()
    /// @desc    Pauses the tape.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static pause = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "pause")) _c.pause();
        return self;
    }

    /// @func    stop()
    /// @desc    Stops playback and resets to start.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static stop = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "stop")) _c.stop();
        return self;
    }

    /// @func    eject()
    /// @desc    Removes the tape from the Deck (destroys the logic core).
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static eject = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "eject")) _c.eject();
        return self;
    }

    /// @func    setSpeed(multiplier)
    /// @desc    Sets the playback speed multiplier.
    /// @param   {Real} multiplier 1.0 is normal speed.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static setSpeed = function(_mult) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "setSpeed")) _c.setSpeed(_mult);
        return self;
    }

    // @func   scrub(input, [attack], [decay], [ease])
    /// @desc  Drives playback speed based on input (velocity impulse). Great for "Jog-Wheel" style control.
    /// @param {Real} input        The target speed/direction.
    /// @param {Real} [attack]     Optional lerp IN amount when accelerating.
    /// @param {Real} [decay]      Optional lerp OUT amount when decelerating.
    /// @param {Function} [ease]   Optional easing for the speed curve.
    /// @return {Struct.CassetteTape} Self
    /// @self __CassetteTape
    static scrub = function(_in, _att = 0, _dec = 0, _ease = undefined) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "scrub")) _c.scrub(_in, _att, _dec, _ease);
        return self;
    }

    /// @func    react(target, tension, damping, [snap])
    /// @desc    Spring physics (DHO) to pull the tape towards a target time.
    ///          Called in a Step event.
    /// @param   {Real} target Target Time (Playhead position).
    /// @param   {Real} tension Spring Stiffness.
    /// @param   {Real} damping Friction.
    /// @self __CassetteTape
    static react = function(_target, _tension, _damping, _snap=0.001) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "react")) _c.react(_target, _tension, _damping, _snap);
        return self;
    }

    /// @func    seek(amount)
    /// @desc    Moves playback head by amount (relative).
    /// @param   {Real} amount Time in frames or seconds.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static seek = function(_amt) {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "seek")) {
            __CassetteTape_HandleCallback(_c.__onSeek);
            _c.seek(_amt);
        }
        return self;
    }

    /// @func    rewind()
    /// @desc    Resets the sequence to the beginning.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static rewind = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "rewind")) _c.rewind();
        return self;
    }

    /// @func    ffwd()
    /// @desc    Jumps immediately to the end of the sequence.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static ffwd = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "ffwd")) _c.ffwd();
        return self;
    }

    /// @func    skip()
    /// @desc    Jumps to the start of the next track.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static skip = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "skip")) _c.skip();
        return self;
    }

    /// @func    back()
    /// @desc    Jumps to the start or the previous track.
    /// @return  {Struct.Cassette} Self
    /// @self __CassetteTape
    static back = function() {
        var _c = __deck.__getCore(__id);
        if (_c && variable_struct_exists(_c, "back")) _c.back();
        return self;
    }
    #endregion

    #region GETTERS

    /// @func    get()
    /// @desc    Returns the current interpolated value or struct.
    /// @return  {Any} The current value (or undefined if ejected).
    /// @self __CassetteTape
    static get = function() {
        var _c = __deck.__getCore(__id); 
        return (_c && variable_struct_exists(_c, "get")) ? _c.get() : undefined;
    }

    /// @func    getName()
    /// @desc    Returns the unique key of the animation.
    /// @return  {String} The key (or undefined if ejected).
    /// @self __CassetteTape
    static getName = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getName")) ? _c.getName() : "undefined";
    }

    /// @func    getDuration()
    /// @desc    Returns the total duration of all tracks.
    /// @return  {Real} Duration (or 0 if ejected).
    /// @self __CassetteTape
    static getDuration = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getDuration")) ? _c.getDuration() : 0;
    }

    /// @func    getTrackIndex()
    /// @desc    Returns the current track index.
    /// @return  {Real}
    /// @self __CassetteTape
    static getTrackIndex = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getTrackIndex")) ? _c.getTrackIndex() : 0;
    }

    /// @func    getTime()
    /// @desc    Returns the current playhead value of a Tape (frames/seconds).
    ///          NOTE: This resets with a new track ('.next()').
    /// @return  {Real}
    /// @self __CassetteTape
    static getTime = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getTime")) ? _c.getTime() : 0;
    }

     /// @func    getProgress()
    /// @desc    Returns the normalized progress (0.0 - 1.0).
    /// @return  {Real}
    /// @self __CassetteTape
    static getProgress = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getProgress")) ? _c.getProgress() : 0;
    }

    /// @func    getSpeed()
    /// @desc    Returns the current playback speed.
    /// @return  {Real}
    /// @self __CassetteTape
    static getSpeed = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getSpeed")) ? _c.getSpeed() : 0;
    }

    /// @func    getLoopsRemaining()
    /// @desc    Returns remaining loops.
    /// @return  {Real}
    /// @self __CassetteTape
    static getLoopsRemaining= function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getLoopsRemaining")) ? _c.getLoopsRemaining() : 0;
    }

    /// @func    getTarget()
    /// @desc    Returns the bound target instance/struct.
    /// @return  {Any}
    /// @self __CassetteTape
    static getTarget = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getTarget")) ? _c.getTarget() : undefined;
    }

    /// @func    getDirection()
    /// @desc    Returns playback direction (1 or -1).
    /// @return  {Real}
    /// @self __CassetteTape
    static getDirection = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "getDirection")) ? _c.getDirection() : 1;
    }

    /// @func    isPlaying()
    /// @desc    Checks if this specific tape is active and playing.
    /// @return  {Bool}
    /// @self __CassetteTape
    static isPlaying = function() {
        var _c = __deck.__getCore(__id);
        return (_c && _c.__active && !_c.__paused);
    }

    /// @func    isPaused()
    /// @desc    Returns true if paused.
    /// @return  {Bool}
    /// @self __CassetteTape
    static isPaused = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "isPaused")) ? _c.isPaused() : false;
    }

    /// @func    isInfinite()
    /// @desc    Checks if the tape loops indefinitely.
    /// @return  {Bool} True if infinite.
    /// @self __CassetteTape
    static isInfinite = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "isInfinite")) ? _c.isInfinite() : false;
    }

    /// @func    isFinished()
    /// @desc    Returns true if finished.
    /// @return  {Bool}
    /// @self __CassetteTape
    static isFinished = function() {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "isFinished")) ? _c.isFinished() : false;
    }

    /// @func    hasTag(tag)
    /// @desc    Checks if the tape has a specific tag.
    /// @return  {Bool}
    /// @self __CassetteTape
    static hasTag = function(_tag) {
        var _c = __deck.__getCore(__id);
        return (_c && variable_struct_exists(_c, "hasTag")) ? _c.hasTag(_tag) : false;
    }
    #endregion
}