// Feather ignore all
/// @func CassetteDeck([use_seconds], [default_lerp])
/// @desc A manager for animations.
/// @param {Bool} [use_seconds] Use delta time if true (seconds), defaults to frames.
/// @param {Bool} [auto_start] Animations play automatically or require being played after definition, defaults to false.
/// @param {Bool} [time_scale] The global playback speed for this instance (defaults to 1.0)
/// @param {Function} [default_lerp] Pass an optional custom interpolation function to be used by the entire system, defaults to lerp().
function CassetteDeck(_useSeconds = false, _autoStart = false, _timeScale = 1.0, _defaultLerp = lerp) constructor {
    // Config
    __useSeconds    = _useSeconds;
    __autoStart     = _autoStart;
    __timeScale     = _timeScale;
    __defaultLerp   = _defaultLerp;
    __defaultEase   = CassetteEase.InOutSine;
    __CASSETTE_TIME_SOURCE_INIT;
    __playingCount = 0;
    __idCounter = 0;

    // Data
    __tapesList = [];
    __tapesById = [];   // Maps Integer ID -> Tape (PRIMARY)
    __tapesMap  = {};   // Maps String Key -> Tape (OPTIONAL)
    __pool = [];        // Cache of inactive tapes.
    __freeIds = [];     // Recycled IDs.

    #region Main Methods

    /// @method insert([key], [bindTo])
    /// @desc Creates (or recycles) a new animation tape and loads it into the deck.
    /// @param {String} [key] Optional unique identifier.
    /// @param {Struct|Asset.GMObject} [bindTo] Optional instance to bind properties to (otherwise defaults to self, or the scope of a struct passed).
    /// @return {Struct.Cassette} The newly created Cassette.
    /// @self CassetteDeck
    static insert = function(_key = undefined, _bindTo = undefined) {
        return __CassetteDeck_Insert(_key, _bindTo);
    };

    /// @method video(sprite, [target_instance])
    /// @desc Creates a tape that drives a sprite animation with Cassette timing/easing.
    /// @param {Asset.GMSprite} sprite The sprite to animate.
    /// @param {Instance} [target_instance] The instance to apply the sprite to.
    /// @return {Struct.Cassette} The newly created Cassette.
    /// @self CassetteDeck
    static video = function(_sprite, _target = other) {
        return __CassetteDeck_Video(_sprite, _target);
    };

    /// @method mixTape(key)
    /// @desc Retrieves or creates a Mixtape (timeline) managed by this Deck.
    /// @param {String} key The unique identifier for this sequence.
    /// @return {Struct.Cassette}
    /// @self CassetteDeck
    static mixTape = function(_key) {
        return __CassetteDeck_MixTape(_key);
    };

    #endregion

    #region Getters

    /// @method get(target, [default])
    /// @desc Directly retrieves the current interpolated value of an animation or an array of animations.
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} target The Key(s) or Handle(s).
    /// @param {Any} [default] Value to return if animation doesn't exist.
    /// @return {Any|Array<Any>} A single value or an array of values.
    /// @self CassetteDeck
    static get = function(_target, _default = undefined) {
        return __CassetteDeck_Get(_target, _default);
    };

    /// @method getTape(target)
    /// @desc Retrieves safe Cassette Handle(s) for the given target(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} target The Key(s) or Handle(s).
    /// @return {Struct.Cassette|Array<Struct.Cassette>|Undefined}
    /// @self CassetteDeck
    static getTape = function(_target) {
        return __CassetteDeck_GetTape(_target);
    };

    /// @method getPlaying([filter])
    /// @desc Returns an array of Cassettes for animations that are playing.
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [filter] If provided, limits the check to these targets.
    /// @return {Array<Struct.Cassette>} Array of Cassette Cassettes.
    /// @self CassetteDeck
    static getPlaying = function(_filter = undefined) {
        return __CassetteDeck_GetPlaying(_filter);
    };

    /// @method getPlayingCount()
    /// @desc Returns the number of Tapes currently playing.
    /// @returns {Real} _playingCount
    /// @self CassetteDeck
    static getPlayingCount = function() {
        return __CassetteDeck_GetPlayingCount();
    };

    /// @method getPaused([filter])
    /// @desc Returns an array of Cassettes for animations that are paused.
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [filter] If provided, limits the check to these targets.
    /// @return {Array<Struct.Cassette>} Array of Cassette Cassettes.
    /// @self CassetteDeck
    static getPaused = function(_filter = undefined) {
        return __CassetteDeck_GetPaused(_filter);
    };

    /// @method getActive([filter])
    /// @desc Returns an array of Cassettes for animations that are active (Playing OR Paused).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [filter] If provided, limits the check to these targets.
    /// @return {Array<Struct.Cassette>} Array of Cassette Cassettes.
    /// @self CassetteDeck
    static getActive = function(_filter = undefined) {
        return __CassetteDeck_GetActive(_filter);
    };

    /// @method getSpeed()
    /// @desc Returns the global time scale multiplier for this Deck.
    /// @return {Real}
    /// @self CassetteDeck
    static getSpeed = function() {
        return __CassetteDeck_GetSpeed();
    };

    /// @method isPlaying([target])
    /// @desc Checks if animation(s) are active and NOT paused.
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Cassette Handle(s) or String Key(s) to check.
    /// @return {Bool}
    /// @self CassetteDeck
    static isPlaying = function(_target = undefined) {
        return __CassetteDeck_IsPlaying(_target);
    };

    #endregion

    #region Controls

    /// @method play([target], [params])
    /// @desc Resumes animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Cassette Handle(s) or String Key(s).
    /// @param {Struct} [params] Optional parameters (e.g. { start: 0, delay: 0 }) to pass to the tape.
    /// @return {Undefined}
    /// @self CassetteDeck
    static play = function(_target = undefined, _params = undefined) {
        return __CassetteDeck_Play(_target, _params);
    };

    /// @method pause([target])
    /// @desc Executes .pause() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static pause = function(_target = undefined) {
        return __CassetteDeck_Pause(_target);
    };

    /// @method rewind([target])
    /// @desc Executes .rewind() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static rewind = function(_target = undefined) {
        return __CassetteDeck_Rewind(_target);
    };

    /// @method ffwd([target])
    /// @desc Executes .ffwd() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static ffwd = function(_target = undefined) {
        return __CassetteDeck_Ffwd(_target);
    };

    /// @method skip([target])
    /// @desc Executes .skip() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static skip = function(_target = undefined) {
        return __CassetteDeck_Skip(_target);
    };

    /// @method back([target])
    /// @desc Executes .back() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static back = function(_target = undefined) {
        return __CassetteDeck_Back(_target);
    };

    /// @method seek(amount, [target])
    /// @desc Moves the playback head by a specific amount for one or multiple animations.
    /// @param {Real} amount The amount to move the timer (frames or seconds).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s).
    /// @return {Undefined}
    /// @self CassetteDeck
    static seek = function(_amount, _key = undefined) {
        return __CassetteDeck_Seek(_amount, _key);
    };

    /// @method setSpeed(speed)
    /// @desc Sets the global time scale multiplier for this Deck.
    /// @param {Real} speed The new time scale (1.0 is normal).
    /// @return {Struct.CassetteDeck} Self
    /// @self CassetteDeck
    static setSpeed = function(_speed) {
        return __CassetteDeck_SetSpeed(_speed);
    };

    /// @method stop([target])
    /// @desc Executes .stop() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static stop = function(_target = undefined) {
        return __CassetteDeck_Stop(_target);
    };

    /// @method eject([target])
    /// @desc Executes .eject() on the target animation(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [target] The Key(s) or Handle(s) to control.
    /// @return {Undefined}
    /// @self CassetteDeck
    static eject = function(_target = undefined) {
        return __CassetteDeck_Eject(_target);
    };

    /// @method scrub(target, input_value, attack, decay, [ease])
    /// @desc Forwards scrub/speed control to specific tape(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} target The Key(s) or Handle(s).
    /// @param {Real} input_value The target input (e.g. axis value).
    /// @param {Real} attack Lerp factor for acceleration.
    /// @param {Real} decay Lerp factor for deceleration.
    /// @param {Function} [ease] Optional easing function for the speed curve.
    /// @return {Undefined}
    /// @self CassetteDeck
    static scrub = function(_target, _val, _att, _dec, _ease = undefined) {
        return __CassetteDeck_Scrub(_target, _val, _att, _dec, _ease);
    };

    /// @method react(target, target_time, tension, damping, [snap])
    /// @desc Forwards spring physics control to specific tape(s).
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} target The Key(s) or Handle(s).
    /// @param {Real} target_time The target time (playhead position) to spring towards.
    /// @param {Real} tension Stiffness of the spring (e.g., 0.1 to 1.0).
    /// @param {Real} damping Friction of the spring (e.g., 0.1 to 1.0).
    /// @param {Real} [snap] Distance threshold to snap to target (default 0.001).
    /// @return {Undefined}
    /// @self CassetteDeck
    static react = function(_target, _target_time, _tension, _damping, _snap = 0.001) {
        return __CassetteDeck_React(_target, _target_time, _tension, _damping, _snap);
    };

    /// @method stagger(targets, amount, [reverse], [autoStart], [ease])
    /// @desc Staggers animations.
    /// @param {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>} targets The Key(s) or Handle(s) to stagger.
    /// @param {Real} amount Interval or Total Duration.
    /// @param {Bool} [reverse] Run in reverse order.
    /// @param {Bool} [autoStart] Play automatically or require being played after definition, defaults to false.
    /// @param {Function|Asset.GMAnimCurve} [ease] Optional distribution curve.
    /// @self CassetteDeck
    static stagger = function(_targets, _amount, _reverse = false, _autoStart = false, _ease = undefined) {
        return __CassetteDeck_Stagger(_targets, _amount, _reverse, _autoStart, _ease);
    };

    #endregion

    #region System Utilities

    /// @method destroy()
    /// @desc Must run in a cleanup or game-end event to prevent memory leaks!
    /// @self CassetteDeck
    static destroy = function() {
        return __CassetteDeck_Destroy();
    };

    /// @method pauseSystem()
    /// @desc Suspends the update loop entirely (time stops ticking)
    /// @self CassetteDeck
    static pauseSystem = function() {
        return __CassetteDeck_PauseSystem();
    };

    /// @method resumeSystem()
    /// @desc Resumes updates/un-suspends system (time continues to tick)
    /// @self CassetteDeck
    static resumeSystem = function() {
        return __CassetteDeck_ResumeSystem();
    };
    
    /// @desc Library of easing functions
    /// @self CassetteEase
    static ease             = new CassetteEase();

    #endregion

    #region Internal
    static __DetachChild    = __CassetteDeck_DetachChild;
    static __RemoveChild    = __CassetteDeck_RemoveChild;
    static __getCore        = __CassetteDeck_GetCore;
    static __getUniqueId    = __CassetteDeck_GetUniqueId;
    #endregion
}