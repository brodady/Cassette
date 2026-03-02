/// @desc Prevents potential crashes/hangs caused by large seeks
#macro __CASSETTE_SEEK_LIMIT 1000

/// @desc Max number of tapes.
#macro __CASSETTE_ID_LIMIT 32000

/// @desc The default easing function to use if none are provided on chain.
#macro __CASSETTE_DEFAULT_EASE CassetteEase.Linear

/// @desc Shorthand for grabbing incoming value safely (Clone or Reference based on flag)
#macro __CASSETTE_CLONE_VAL  ((is_struct(_val) && __copyStructs) ? variable_clone(_val) : _val)

/// @desc Dynamic Threshold for rewind based on seconds/frame time
#macro __CASSETTE_REWIND_THRESHOLD ((__deck.__useSeconds) ? 0.1 : 5)

/// @desc Dynamic Epsilon for rewind/back based on seconds/frame time
#macro __CASSETTE_EPSILON ((__deck.__useSeconds) ? 0.001 : 1)

/// @desc Default channnel to use for all passed curve assets
#macro __CASSETTE_DEFAULT_CURVE_CHANNEL 0

/// @desc Shorthand, resets the local state (timer, loops, direction) when entering a new track index.
#macro __CASSETTE_RESET_TRACK  var _tMacro = __tracks[__trackIndex];\
                             __trackLoops = _tMacro.loops;\
                             __direction = 1;\
                             __timer = 0

/// @desc Shorthand, registers a Tape with a Deck
#macro __CASSETTE_REGISTER_TRACK if (_deck != undefined) {\
                                    array_push(_deck.__tapesList, self);\
                                    if (_key != undefined) {\
                                        var _existing = _deck.__tapesMap[$ _key];\
                                        if (_existing != undefined) _existing.eject();\
                                        _deck.__tapesMap[$ _key] = self;\
                                    }\
                                }

/// @desc Shorthand for the default track struct
#macro __CASSETTE_DEFAULT_TRACK {\
                                    fromVal: 0,\
                                    toVal: 0, \
                                    duration: 1.0,\
                                    ease: __CASSETTE_DEFAULT_EASE, \
                                    lerpFunc: _deck.__defaultLerp,\
                                    isCurve: false,\
                                    type: __CASSETTE_ANIM.ONCE,\
                                    loops: 0, \
                                    isWait: false,\
                                    onTrackEnd: undefined,\
                                    propNames: undefined \
                                }

/// @desc Shorthand for creating and starting a CassetteDeck time source (sets __timeSource)
///       (Creates an update function that executes once every frame, forever.)
#macro __CASSETTE_TIME_SOURCE_INIT var _stepMethod = method(self, __CassetteDeck_Step);\
                                                __timeSource = time_source_create(\
                                                    time_source_global,\ 
                                                    1,\
                                                    time_source_units_frames,\
                                                    _stepMethod,\ 
                                                    [],\ 
                                                    -1\ 
                                                );\
                                                time_source_start(__timeSource)

/// @desc Shorthand for checking if a Tape is registered to a Deck
#macro __CASSETTE_TAPE_CHECK_REGISTERED ((__deck != undefined) && variable_struct_exists(__deck.__tapesMap, __key) && (__deck.__tapesMap[$ __key] == self))

/// @desc Shorthand for clearing all possible callbacks on reset
#macro __CASSETTE_TAPE_CLEAR_CALLBACKS \
    __onUpdate      = undefined; \
    __onEnd         = undefined; \
    __onAnyTrackEnd = undefined; \
    __onPlay        = undefined; \
    __onPause       = undefined; \
    __onStop        = undefined; \
    __onRewind      = undefined; \
    __onFfwd        = undefined; \
    __onSeek        = undefined; \
    __onSkip        = undefined; \
    __onBack        = undefined


/// @enum __CASSETTE_ANIM
/// @desc Defines the playback behavior for a track (transition/tween).
enum __CASSETTE_ANIM { ONCE, LOOP, PING_PONG, HOLD }

