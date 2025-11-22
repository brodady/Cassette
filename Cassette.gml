/// --- Cassette ---
/// @desc A lightweight, self-contained GML script for creating smooth animations.
/// @ver  2.3.0 (Added 'hold' as an animation state)

// --- Playback Constants ---
#macro CASSETTE_DEFAULT_PLAYBACK_SPEED 1.0

// --- Bounce Constants ---
#macro CASSETTE_BOUNCE_N1 7.5625
#macro CASSETTE_BOUNCE_D1 2.75
#macro CASSETTE_BOUNCE_T1 (1 / CASSETTE_BOUNCE_D1)   // Threshold 1: 1 / 2.75
#macro CASSETTE_BOUNCE_T2 (2 / CASSETTE_BOUNCE_D1)   // Threshold 2: 2 / 2.75
#macro CASSETTE_BOUNCE_T3 (2.5 / CASSETTE_BOUNCE_D1) // Threshold 3: 2.5 / 2.75
#macro CASSETTE_BOUNCE_O1 (1.5 / CASSETTE_BOUNCE_D1) // Offset 1: 1.5 / 2.75
#macro CASSETTE_BOUNCE_O2 (2.25 / CASSETTE_BOUNCE_D1) // Offset 2: 2.25 / 2.75
#macro CASSETTE_BOUNCE_O3 (2.625 / CASSETTE_BOUNCE_D1) // Offset 3: 2.625 / 2.75
#macro CASSETTE_BOUNCE_A1 0.75     // Addition 1
#macro CASSETTE_BOUNCE_A2 0.9375   // Addition 2
#macro CASSETTE_BOUNCE_A3 0.984375 // Addition 3

// --- Elastic Constants ---
#macro CASSETTE_ELASTIC_PERIOD1_DIV 3.0
#macro CASSETTE_ELASTIC_PERIOD2_DIV 4.5
#macro CASSETTE_ELASTIC_C4 ((2 * pi) / CASSETTE_ELASTIC_PERIOD1_DIV) // Constant for In/Out Elastic period
#macro CASSETTE_ELASTIC_C5 ((2 * pi) / CASSETTE_ELASTIC_PERIOD2_DIV) // Constant for InOut Elastic period

// --- Back Constants ---
#macro CASSETTE_BACK_S1 1.70158                    // Overshoot amount factor
#macro CASSETTE_BACK_S2 (CASSETTE_BACK_S1 * 1.525) // Overshoot amount factor for InOut
#macro CASSETTE_BACK_C1 CASSETTE_BACK_S1           // Keep c1 for consistency
#macro CASSETTE_BACK_C2 CASSETTE_BACK_S2           // Keep c2 for consistency
#macro CASSETTE_BACK_C3 (CASSETTE_BACK_S1 + 1)     // Derived constant for In/Out Back

/// @enum CASSETTE_ANIM
/// @desc Defines the playback behavior for a transition.
enum CASSETTE_ANIM {
    ONCE,
    LOOP, 
    PING_PONG,
    HOLD 
}
    
/// @function __CassetteTape(managerRef)
/// @desc Internal builder for constructing animation chains (returned by .transition).
function __CassetteTape(_managerRef) constructor {
    __manager = _managerRef;
    __queue = _managerRef.__queue;

    /// @function next([label])
    /// @desc Adds a new segment to the CURRENT sequence.
    ///       Inherits 'from' value from previous track to ensure continuity.
    /// @return {Struct.__CassetteTape}
    static next = function(_label = undefined) {
        
        // Auto-detect start value from previous track to prevent jumping
        var _autoVal = 0;
        var _i = array_length(__queue) - 1;
        
        while (_i >= 0) {
            var _prev = __queue[_i];
            if (!variable_struct_exists(_prev, "__isWait") || !_prev.__isWait) {
                _autoVal = _prev.__toVal;
                break;
            }
            _i--;
        }

        var _def = {
            label: _label, 
            __fromVal: _autoVal, 
            __toVal: _autoVal,   
            duration: 1.0,
            __easingFunc: Cassette.InQuad, 
            __isCurve: false, 
            __animState: CASSETTE_ANIM.ONCE,
            __loopsRemaining: -1,
            __onUpdate: undefined,
            __onTrackEnd: undefined,
            __isWait: false
        };
        array_push(__queue, _def);
        return self; 
    };
    
    /// @function wait(duration, [callback])
    /// @desc Adds a pause to the sequence.
    /// @param {Real} duration The duration to wait (in frames or seconds).
    /// @param {Function} [callback] Optional callback to fire when the wait ends.
    /// @return {Struct.__CassetteTape}
    static wait = function(_duration, _callback = undefined) {
        var _def = {
            __isWait: true,
            duration: _duration,
            __animState: CASSETTE_ANIM.ONCE,
            __loopsRemaining: 1,
            __onTrackEnd: _callback,
            __onUpdate: undefined 
        };
        array_push(__queue, _def);
        return self;
    };

    /// @function hold()
    /// @desc Clamps the animation at the start/end. It will not finish or loop.
    ///       Essential for react() or physics-like inputs.
    /// @return {Struct.__CassetteTape}
    static hold = function() {
        var _last = array_last(__queue);
        _last.__animState = CASSETTE_ANIM.HOLD;
        
        // We set loopsRemaining to -1 (infinite) so the system knows it persists
        if (array_length(__queue) == 1) __manager.__loopsRemaining = -1; 
        
        return self;
    };

    // --- Setters ---

    /// @function from(valueOrStruct)
    /// @desc Sets the start value. Can be a Real or a Struct.
    /// @return {Struct.__CassetteTape}
    static from = function(_val) {
        var _last = array_last(__queue);
        _last.__fromVal = _val;
        
        if (array_length(__queue) == 1) {
            __manager.__currentVal = _val;
        }
        return self;
    };

    /// @function to(valueOrStruct)
    /// @desc Sets the end value.
    /// @return {Struct.__CassetteTape}
    static to = function(_val) {
        var _last = array_last(__queue);
        _last.__toVal = _val;
        return self;
    };

    /// @function duration(secondsOrFrames)
    /// @return {Struct.__CassetteTape}
    static duration = function(_val) {
        var _last = array_last(__queue);
        _last.duration = _val;
        return self;
    };

    /// @function ease(functionOrCurve)
    /// @desc Sets the easing function or Animation Curve struct.
    /// @return {Struct.__CassetteTape}
    static ease = function(_func) {
        var _last = array_last(__queue);
        _last.__easingFunc = _func;
        if (is_struct(_func) && variable_struct_exists(_func, "__isAnimCurve")) {
            _last.__isCurve = true;
        } else {
            _last.__isCurve = false;
        }
        return self;
    };

    /// @function loop([times])
    /// @desc Repeats THIS track. -1 = Infinite.
    /// @return {Struct.__CassetteTape}
    static loop = function(_times = -1) {
        var _last = array_last(__queue);  
        _last.__animState = CASSETTE_ANIM.LOOP;
        if (_times != -1) _times += 1;
        _last.__loopsRemaining = _times;

        if (array_length(__queue) == 1) __manager.__loopsRemaining = _times;

        return self;
    };

    /// @function pingpong([times])
    /// @desc PingPongs THIS track. -1 = Infinite.
    /// @return {Struct.__CassetteTape}
    static pingpong = function(_times = -1) {
        var _last = array_last(__queue);
        
        _last.__animState = CASSETTE_ANIM.PING_PONG;
        _last.__loopsRemaining = _times;
        if (array_length(__queue) == 1) __manager.__loopsRemaining = _times;
        
        return self;
    };

    // --- Callbacks ---

    /// @function onPlay(callback)
    /// @desc Triggered when .play() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onPlay = function(_func) {
        __manager.__onPlayCb = _func;
        return self;
    };

    /// @function onPause(callback)
    /// @desc Triggered when .pause() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onPause = function(_func) {
        __manager.__onPauseCb = _func;
        return self;
    };

    /// @function onStop(callback)
    /// @desc Triggered when .stop() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onStop = function(_func) {
        __manager.__onStopCb = _func;
        return self;
    };

    /// @function onRewind(callback)
    /// @desc Triggered when .rewind() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onRewind = function(_func) {
        __manager.__onRewindCb = _func;
        return self;
    };

    /// @function onFfwd(callback)
    /// @desc Triggered when .ffwd() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onFfwd = function(_func) {
        __manager.__onFfwdCb = _func;
        return self;
    };

    /// @function onSeek(callback)
    /// @desc Triggered when .seek() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onSeek = function(_func) {
        __manager.__onSeekCb = _func;
        return self;
    };

    /// @function onSkip(callback)
    /// @desc Triggered when .skip() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onSkip = function(_func) {
        __manager.__onSkipCb = _func;
        return self;
    };

    /// @function onBack(callback)
    /// @desc Triggered when .back() is called.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onBack = function(_func) {
        __manager.__onBackCb = _func;
        return self;
    };

    /// @function onUpdate(callback)
    /// @desc Callback that runs every frame while this specific track is active.
    /// @param {Function} callback Receives the current value as an argument.
    /// @return {Struct.__CassetteTape}
    static onUpdate = function(_func) {
        var _last = array_last(__queue);
        _last.__onUpdate = _func;
        return self;
    };
    
    /// @function onEnd(callback)
    /// @desc Callback for when THIS specific track ends.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onEnd = function(_func) {
        var _last = array_last(__queue);
        _last.__onTrackEnd = _func;
        return self;
    };

    /// @function onSequenceEnd(callback)
    /// @desc Callback for when the ENTIRE chain finishes.
    /// @param {Function} callback
    /// @return {Struct.__CassetteTape}
    static onSequenceEnd = function(_func) {
        __manager.__onSequenceEnd = _func;
        return self;
    };
};


/// @function Cassette([useDeltaTime], [autoStart], [defaultLerp])
/// @description A centralized, self-contained class for chained, sequenced animations.
function Cassette(_useDeltaTime = false, _autoStart = false, _defaultLerp = lerp) constructor {
    
    // Private internal state
    __activeTransitions = {};
    __activeKeyList = [];
    __scheduler = []; 
    __useDeltaTime = _useDeltaTime;
    __defaultAutoStart = _autoStart;
    __defaultLerp = _defaultLerp;
    
    // --- Public Methods ---

    /// @function transition(key, [lerp_func])
    /// @desc Creates a new transition chain.
    /// @param {String} key Unique identifier for this transition.
    /// @param {Function} [lerp_func] Optional custom lerp function.
    /// @return {Struct.__CassetteTape} A ChainBuilder instance to configure the animation.
    transition = function(_key, _lerpFunc = __defaultLerp) {
        var _firstDef = {
            label: "Start",
            __fromVal: 0, __toVal: 0, duration: 1.0, 
            __easingFunc: Cassette.InQuad, 
            __isCurve: false, 
            __animState: CASSETTE_ANIM.ONCE, __loopsRemaining: -1,
            __onTrackEnd: undefined,
            __onUpdate: undefined,
            __isWait: false
        };
    
        var _manager = { 
            __queue: [_firstDef],
            __currentIndex: 0,
            __lerpFunc: _lerpFunc, 
            __onSequenceEnd: undefined,
            
            // Control Callbacks
            __onPlayCb: undefined,
            __onPauseCb: undefined,
            __onStopCb: undefined,
            __onRewindCb: undefined,
            __onFfwdCb: undefined,
            __onSeekCb: undefined,
            __onSkipCb: undefined,
            __onBackCb: undefined,
    
            // State
            __currentVal: 0,
            __reactVel: 0,
            __timer: 0,
            __direction: 1,
            __loopsRemaining: 1,
            __isPaused: !__defaultAutoStart,
            __playbackSpeed: CASSETTE_DEFAULT_PLAYBACK_SPEED,
            __isFinished: false 
        };

        if (!variable_struct_exists(__activeTransitions, _key)) {
            array_push(__activeKeyList, _key);
        }
        
        __activeTransitions[$ _key] = _manager;
        return new __CassetteTape(_manager); 
    };
    
    /// @function update()
    /// @description Updates all active transitions. Call in Step Event.
    update = function() {
        // -- Scheduler
        var _i = 0;
        var _dtMultiplier = (__useDeltaTime) ? (delta_time / 1000000) : 1;
        
        // Iterate backwards to allow deletion
        for(var _i = array_length(__scheduler) - 1; _i >= 0; _i--) {
            var _item = __scheduler[_i];
            _item.timer -= _dtMultiplier;
            
            if (_item.timer <= 0) {
                _item.func(_item.args);
                array_delete(__scheduler, _i, 1);
            }
        }

        // -- Update
        var _completedKeys = [];
        var _len = array_length(__activeKeyList);
        _i = 0;
        
        repeat(_len) {
            var _key = __activeKeyList[_i];
            var _manager = __activeTransitions[$ _key];
            
            // Safety check in case key was removed during iteration of a previous step
            if (_manager == undefined) { _i++; continue; }
            if (_manager.__isPaused) { _i++; continue; }
            
            var _currentDef = _manager.__queue[_manager.__currentIndex];

            // Handle Time
            var _dtMultiplier = (__useDeltaTime) ? (delta_time / 1000000) : 1;
            var _timeStep = _dtMultiplier * abs(_manager.__playbackSpeed);
            
            _manager.__timer += _timeStep * (sign(_manager.__playbackSpeed) * _manager.__direction);

            // Handle Animation Logic
            __evaluateAndSetValue(_manager);

            // Handle Boundaries (Completion/Looping)
            var _isLooping = _currentDef.__animState == CASSETTE_ANIM.LOOP;
            var _isPingPong = _currentDef.__animState == CASSETTE_ANIM.PING_PONG;
            
            // FORWARD BOUNDARY
            if (_manager.__timer >= _currentDef.duration) {
                var _overflow = _manager.__timer - _currentDef.duration;
                
                if (_currentDef.__animState == CASSETTE_ANIM.HOLD) {
                    // NEW: Clamp to end. Do not finish. Do not wrap.
                    _manager.__timer = _currentDef.duration;
                }
                else if (_isLooping) {
                    if (_manager.__loopsRemaining > 0) _manager.__loopsRemaining--;
                    if (_manager.__loopsRemaining != 0) {
                        _manager.__timer = _overflow;
                    } else {
                        __moveToNextTrack(_manager, _key, _completedKeys, _overflow);
                    }
                }
                else if (_isPingPong) {
                    if (_manager.__loopsRemaining != 0) {
                        _manager.__timer = _currentDef.duration - _overflow;
                        _manager.__direction *= -1; 
                    } else {
                        __moveToNextTrack(_manager, _key, _completedKeys, _overflow);
                    }
                }
                else { // Once
                    __moveToNextTrack(_manager, _key, _completedKeys, _overflow);
                }
            }
            // BACKWARD BOUNDARY
            else if (_manager.__timer < 0) {
                var _underflow = _manager.__timer;
                
                if (_currentDef.__animState == CASSETTE_ANIM.HOLD) {
                     // NEW: Clamp to start.
                    _manager.__timer = 0;
                }
                else if (_isLooping) {
                    if (_manager.__loopsRemaining != 0) {
                        _manager.__timer = _currentDef.duration + _underflow;
                    } else {
                        __handleBackwardCompletion(_manager, _key, _underflow);
                    }
                }
                else if (_isPingPong) {
                    if (_manager.__loopsRemaining > 0) _manager.__loopsRemaining--;
                    if (_manager.__loopsRemaining != 0) {
                        _manager.__timer = 0 - _underflow;
                        _manager.__direction *= -1; 
                    } else { 
                        __moveToNextTrack(_manager, _key, _completedKeys, 0 - _underflow);
                    }
                }
                else { // Once
                     __handleBackwardCompletion(_manager, _key, _underflow);
                }
            }
            _i++;
        }
        
        // Clean up completed transitions
        var _c = 0;
        var _cLen = array_length(_completedKeys);
        repeat(_cLen) {
            var _k = _completedKeys[_c];
            variable_struct_remove(__activeTransitions, _k);
            
            var _idx = array_get_index(__activeKeyList, _k);
            if (_idx != -1) array_delete(__activeKeyList, _idx, 1);
            
            _c++;
        }
    };

    // --- Player Controls ---

    /// @function play([keys])
    play = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager) { 
            if (is_method(_manager.__onPlayCb)) _manager.__onPlayCb();
            _manager.__isPaused = false; 
        });
    };

    /// @function stagger(keys, delay, [reverse])
    /// @desc Plays a list of animations with a time delay between each start.
    stagger = function(_keys, _delay, _reverse = false) {
        if (!is_array(_keys)) _keys = [_keys];
        
        // Create a copy so we don't modify the original array if reversing
        var _set = [];
        array_copy(_set, 0, _keys, 0, array_length(_keys));
        
        if (_reverse) _set = array_reverse(_set);
        
        var _len = array_length(_set);
        for (var _i = 0; _i < _len; _i++) {
            var _k = _set[_i];
            var _time = _delay * _i;
            
            if (_time <= 0.0001) {
                play(_k); // Play immediately if it's the first one
            } else {
                // Push to scheduler
                array_push(__scheduler, {
                    timer: _time,
                    func: play,
                    args: _k
                });
            }
        }
    };

    /// @function react(keys, control_val, [attack], [decay], [ease_func])
    /// @desc Drives playback speed based on a control value (+/-) with smoothing.
    ///       Call this every frame in the Step Event.
    react = function(_keys, _controlVal, _attack = 0.1, _decay = 0.1, _easeFunc = undefined) {
        __applyToManagers(_keys, function(_manager, _data) {
            var _input = _data.val;
            var _att = _data.att;
            var _dec = _data.dec;
            var _ease = _data.ease;
            
            // Compare absolute values to see if we are moving towards or away from 0
            var _isAccel = abs(_input) > abs(_manager.__reactVel);
            var _lerpAmt = _isAccel ? _att : _dec;
            
            // Smooth the velocity
            _manager.__reactVel = _manager.__defaultLerp(_manager.__reactVel, _input, _lerpAmt);

            // Apply optional easing to the magnitude
            var _finalSpeed = _manager.__reactVel;
            
            if (_ease != undefined) {
                var _sign = sign(_finalSpeed);
                var _mag = abs(_finalSpeed);
                _mag = clamp(_mag, 0, 1);
                _finalSpeed = _ease(_mag) * _sign;
            }
            
            // Apply to playback Speed
            _manager.__playbackSpeed = _finalSpeed;

            // If speed is negligible, we can pause to save CPU, otherwise play
            if (abs(_finalSpeed) < 0.001 && _input == 0) {
                _manager.__isPaused = true;
                _manager.__reactVel = 0; // Snap to 0
            } else {
                _manager.__isPaused = false;
            }
            
        }, { val: _controlVal, att: _attack, dec: _decay, ease: _easeFunc });
    };

    /// @function pause([keys])
    pause = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager) { 
            if (is_method(_manager.__onPauseCb)) _manager.__onPauseCb();
            _manager.__isPaused = true; 
        });
    };

    /// @function stop([keys], [triggerCallback])
    stop = function(_keys = undefined, _triggerEndCallback = true) {
        __applyToManagers(_keys, function(_manager, _doCallback, _key) {
            if (is_method(_manager.__onStopCb)) _manager.__onStopCb();

            if (_doCallback && is_method(_manager.__onSequenceEnd)) {
                _manager.__onSequenceEnd();
            }
            variable_struct_remove(__activeTransitions, _key);
        }, _triggerEndCallback);
    };

    /// @function ffwd([keys])
    ffwd = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager, _data, _key) {
            if (is_method(_manager.__onFfwdCb)) _manager.__onFfwdCb();

            _manager.__currentIndex = array_length(_manager.__queue) - 1;
            var _lastDef = _manager.__queue[_manager.__currentIndex];
            
            _manager.__timer = _lastDef.duration;
            _manager.__direction = 1;
            _manager.__loopsRemaining = 0;
            
            if (!_lastDef.__isWait) _manager.__currentVal = _lastDef.__toVal;
            
            if (is_method(_manager.__onSequenceEnd)) _manager.__onSequenceEnd();
            variable_struct_remove(__activeTransitions, _key);
        });
    };

    /// @function rewind([keys])
    rewind = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager) {
            if (is_method(_manager.__onRewindCb)) _manager.__onRewindCb();
            
            __initTrack(_manager, 0); 
            if (!__defaultAutoStart) _manager.__isPaused = true;
        });
    };

     /// @function seek(amount, [keys])
    seek = function(_amount, _keys = undefined) {
        // Wrap __seekManager to inject the callback trigger
        __applyToManagers(_keys, function(_manager, _amt, _k) {
            if (is_method(_manager.__onSeekCb)) _manager.__onSeekCb();
            other.__seekManager(_manager, _amt, _k);
        }, _amount);
    };

    /// @function skip([keys])
    skip = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager, _data, _key) {
            if (is_method(_manager.__onSkipCb)) _manager.__onSkipCb();

            if (_manager.__currentIndex + 1 < array_length(_manager.__queue)) {
                __initTrack(_manager, _manager.__currentIndex + 1);
            } else {
                var _lastIndex = array_length(_manager.__queue) - 1;
                var _lastDef = _manager.__queue[_lastIndex];
                __initTrack(_manager, _lastIndex, _lastDef.duration); 
                if (is_method(_manager.__onSequenceEnd)) _manager.__onSequenceEnd();
                variable_struct_remove(__activeTransitions, _key);
            }
        });
    };

    /// @function back([keys])
    back = function(_keys = undefined) {
        __applyToManagers(_keys, function(_manager) {
            if (is_method(_manager.__onBackCb)) _manager.__onBackCb();

            if (_manager.__currentIndex > 0) __initTrack(_manager, _manager.__currentIndex - 1);
            else __initTrack(_manager, 0);
        });
    };
    
    /// @function getSpeed(key)
    getSpeed = function(_key) {
        if (variable_struct_exists(__activeTransitions, _key)) {
            return __activeTransitions[$ _key].__playbackSpeed;
        }
        return undefined;
    };
    
    /// @function setSpeed(speed, [keys])
    setSpeed = function(_speed, _keys = undefined) {
        __applyToManagers(_keys, function(_manager, _speed) { _manager.__playbackSpeed = _speed; }, _speed);
    };

    /// @function clearAll()
    clearAll = function() {
        __activeTransitions = {};
    };

    /// @function getValue(key, defaultVal)
    getValue = function(_key, _defaultVal) {
        if (variable_struct_exists(__activeTransitions, _key)) {
            return __activeTransitions[$ _key].__currentVal;
        }
        return _defaultVal;
    };

    /// @function getActive
    /// @desc Returns an array of all active animation keys in this instance. 
    /// @returns {array}
    getActive = function () {
        return __activeKeyList;
    }
    
    /// @function isActive([key])
    isActive = function(_key = undefined) {
        if (_key != undefined) {
            return variable_struct_exists(__activeTransitions, _key);
        }
        var _names = variable_struct_get_names(__activeTransitions);
        return (array_length(_names) > 0);
    };
    
    /// @function isPaused([key])
    isPaused = function(_key = undefined) {
        if (_key != undefined) {
            if (variable_struct_exists(__activeTransitions, _key)) {
                return __activeTransitions[$ _key].__isPaused;
            }
            return undefined;
        }
        
        var _keys = variable_struct_get_names(__activeTransitions);
        if (array_length(_keys) == 0) return false; 
        
        var _i = 0;
        var _len = array_length(_keys);
        repeat(_len) {
            var _manager = __activeTransitions[$ _keys[_i]];
            if (!_manager.__isPaused) return false; 
            _i++;
        }
        return true;
    };

    /// @function custom(curveAssetOrStruct, [channelIndex])
    custom = function(_curveAssetOrStruct, _channelIndex = 0) {
        var _curveStruct = _curveAssetOrStruct;
        if (!is_struct(_curveStruct)) _curveStruct = animcurve_get(_curveAssetOrStruct);
        
        if (!is_struct(_curveStruct) || !variable_struct_exists(_curveStruct, "channels")) return undefined;
        if (_channelIndex >= array_length(_curveStruct.channels)) return undefined;
        
        return {
            __isAnimCurve: true,
            channel: _curveStruct.channels[_channelIndex]
        };
    };

    // --- Internal Helpers (Private) ---

    /// @desc (Internal) Interpolates Reals or Structs.
    __calculateCurrentValue = function(_from, _to, _progress, _lerpFunc) {
        if (is_struct(_from)) {
            var _result = {};
            var _keys = variable_struct_get_names(_to);
            var _len = array_length(_keys);
            var _i = 0;
            repeat(_len) {
                var _k = _keys[_i];
                // FIXED: Safety check to prevent crash if 'from' is missing the key
                var _fromVal = variable_struct_exists(_from, _k) ? _from[$ _k] : _to[$ _k];
                _result[$ _k] = _lerpFunc(_fromVal, _to[$ _k], _progress);
                _i++;
            }
            return _result;
        } else {
            return _lerpFunc(_from, _to, _progress);
        }
    };

    /// @desc (Internal) Calculates and sets the current value based on time/queue.
    __evaluateAndSetValue = function(_manager) {
        var _def = _manager.__queue[_manager.__currentIndex];
        if (_def.__isWait) return;
        
        var _progress = (_def.duration <= 0) ? 1 : clamp(_manager.__timer / _def.duration, 0, 1);
        var _eased = 0;
        
        if (_def.__isCurve) _eased = animcurve_channel_evaluate(_def.__easingFunc.channel, _progress);
        else _eased = _def.__easingFunc(_progress);

        _manager.__currentVal = __calculateCurrentValue(_def.__fromVal, _def.__toVal, _eased, _manager.__lerpFunc);
        
        if (is_method(_def.__onUpdate)) _def.__onUpdate(_manager.__currentVal);
    };

    /// @desc (Internal) Sets a manager's state to a specific track index.
    __initTrack = function(_manager, _index, _timer = 0, _startDir = 1) {
        _manager.__isFinished = false;
        _manager.__currentIndex = _index;
        var _def = _manager.__queue[_index];
        
        _manager.__loopsRemaining = (_def.__animState == CASSETTE_ANIM.ONCE) ? 1 : _def.__loopsRemaining;
        if (_def.__animState == CASSETTE_ANIM.PING_PONG && _startDir == -1) {
            _manager.__direction = -1;
            _manager.__timer = _def.duration + _timer; 
        } else {
            _manager.__direction = 1;
            _manager.__timer = _timer;
        }
        
        __evaluateAndSetValue(_manager);
    };

    /// @desc (Internal) Advances a manager to next track.
    __moveToNextTrack = function(_manager, _keyForCompletion, _completedKeysRef, _overflow = 0) {
        var _currentDef = _manager.__queue[_manager.__currentIndex];
        if (is_method(_currentDef.__onTrackEnd)) _currentDef.__onTrackEnd();

        if (_manager.__currentIndex + 1 < array_length(_manager.__queue)) {
            __initTrack(_manager, _manager.__currentIndex + 1, _overflow, 1);
        } else {
            _manager.__isFinished = true;

            if (is_method(_manager.__onSequenceEnd)) _manager.__onSequenceEnd();
            // Only kill if the user didn't rescue it (rewind/seek inside the callback sets __isFinished back to false)
            if (_manager.__isFinished) {
                array_push(_completedKeysRef, _keyForCompletion);
            }
        }
    };

    /// @desc (Internal) Moves a manager backward.
    __handleBackwardCompletion = function(_manager, _keyForCompletion, _underflow) {
        if (_manager.__currentIndex > 0) {
            __initTrack(_manager, _manager.__currentIndex - 1, _underflow, -1);
        } else {
            _manager.__timer = 0;
            _manager.__direction = 1;
        }
    };

    /// @desc (Internal) Apply function to managers. Handles Single Key, Array of Keys, or All Keys (undefined).
    __applyToManagers = function(_targetKeys, _actionFunc, _data = undefined) {
        if (_targetKeys == undefined) {
            // FIXED: Use cached list
            var _i = 0; 
            var _len = array_length(__activeKeyList);
            // Iterate backwards for safety when removing
            for (var _i = _len - 1; _i >= 0; _i--) {
                var _k = __activeKeyList[_i];
                if (variable_struct_exists(__activeTransitions, _k)) {
                    _actionFunc(__activeTransitions[$ _k], _data, _k);
                    // Check if action removed it (e.g. stop())
                    if (!variable_struct_exists(__activeTransitions, _k)) {
                        array_delete(__activeKeyList, _i, 1);
                    }
                }
            }
        } else if (is_array(_targetKeys)) {
            var _i = 0;
            var _len = array_length(_targetKeys);
            repeat(_len) {
                var _k = _targetKeys[_i];
                if (variable_struct_exists(__activeTransitions, _k)) {
                    _actionFunc(__activeTransitions[$ _k], _data, _k);
                    // Check removal
                    if (!variable_struct_exists(__activeTransitions, _k)) {
                        var _idx = array_get_index(__activeKeyList, _k);
                        if (_idx != -1) array_delete(__activeKeyList, _idx, 1);
                    }
                }
                _i++;
            }
        } else if (is_string(_targetKeys)) {
            if (variable_struct_exists(__activeTransitions, _targetKeys)) {
                _actionFunc(__activeTransitions[$ _targetKeys], _data, _targetKeys);
                // Check removal
                if (!variable_struct_exists(__activeTransitions, _targetKeys)) {
                    var _idx = array_get_index(__activeKeyList, _targetKeys);
                    if (_idx != -1) array_delete(__activeKeyList, _idx, 1);
                }
            }
        }
    };

    /// @desc (Internal) The core logic for seeking.
    __seekManager = function(_manager, _seekAmount, _key) { 
        _manager.__timer += _seekAmount;
        var _chainIsFinished = false;
        var _currentDef = _manager.__queue[_manager.__currentIndex];
        
        // --- Forward Overflow ---
        while (_manager.__timer > _currentDef.duration) {
            var _overflowTime = _manager.__timer - _currentDef.duration;
            var _isLooping = _currentDef.__animState == CASSETTE_ANIM.LOOP;
            var _isPingPong = _currentDef.__animState == CASSETTE_ANIM.PING_PONG;
            var _duration = _currentDef.duration;
            
            if ((_isLooping || _isPingPong) && _manager.__loopsRemaining != 0) {
                if (_duration <= 0) { 
                    _manager.__timer = 0;
                    _manager.__direction = 1; 
                    break; 
                }
                
                if (_isLooping) {
                    _manager.__timer = _manager.__timer % _duration;
                    _manager.__direction = 1;
                } else { 
                    var _totalLoopDuration = _duration * 2;
                    var _wrappedTime = _manager.__timer % _totalLoopDuration;
                    if (_wrappedTime > _duration) {
                        _manager.__timer = _duration - (_wrappedTime - _duration);
                        _manager.__direction = -1;
                    } else {
                        _manager.__timer = _wrappedTime;
                        _manager.__direction = 1;
                    }
                }
                break;
            }
            
            if (_manager.__currentIndex + 1 < array_length(_manager.__queue)) {
                __initTrack(_manager, _manager.__currentIndex + 1, _overflowTime, 1);
                _currentDef = _manager.__queue[_manager.__currentIndex];
            } else {
                _manager.__timer = _currentDef.duration;
                _manager.__direction = 1; 
                _chainIsFinished = true; 
                break; 
            }
        }

        // --- Backward Underflow ---
        while (_manager.__timer < 0) {
            var _underflowTime = _manager.__timer;
            var _isLooping = _currentDef.__animState == CASSETTE_ANIM.LOOP;
            var _isPingPong = _currentDef.__animState == CASSETTE_ANIM.PING_PONG;
            var _duration = _currentDef.duration;
            
            if ((_isLooping || _isPingPong) && _manager.__loopsRemaining != 0) {
                if (_duration <= 0) { 
                    _manager.__timer = 0;
                    _manager.__direction = 1; 
                    break; 
                }
                
                if (_isLooping) {
                    _manager.__timer = _manager.__timer % _duration;
                    _manager.__direction = 1;
                } else { 
                    var _totalLoopDuration = _duration * 2;
                    var _wrappedTime = _manager.__timer % _totalLoopDuration;
                    if (_wrappedTime > _duration) {
                        _manager.__timer = _duration - (_wrappedTime - _duration);
                        _manager.__direction = -1;
                    } else {
                        _manager.__timer = _wrappedTime;
                        _manager.__direction = 1;
                    }
                }
                break;
            }
            
            if (_manager.__currentIndex > 0) {
                __initTrack(_manager, _manager.__currentIndex - 1, _underflowTime, -1);
                _currentDef = _manager.__queue[_manager.__currentIndex];
            } else {
                _manager.__timer = 0;
                _manager.__direction = 1; 
                break;
            }
        }
        
        if (_chainIsFinished) {
             __evaluateAndSetValue(_manager);
             _manager.__isPaused = true; 
             return; 
        }
        __evaluateAndSetValue(_manager);
    };

    // --- Easing Library --

    // --- Sine ---
    /// @function InSine(progress)
    static InSine = function(_progress) {
        return 1 - cos((_progress * pi) / 2);
    };

    /// @function OutSine(progress)
    static OutSine = function(_progress) {
        return sin((_progress * pi) / 2);
    };

    /// @function InOutSine(progress)
    static InOutSine = function(_progress) {
        return -(cos(pi * _progress) - 1) / 2;
    };

    // --- Quad ---
    /// @function InQuad(progress)
    static InQuad = function(_progress) {
        return _progress * _progress;
    };

    /// @function OutQuad(progress)
    static OutQuad = function(_progress) {
        return 1 - power(1 - _progress, 2);
    };

    /// @function InOutQuad(progress)
    static InOutQuad = function(_progress) {
        return (_progress < 0.5) ?
            2 * _progress * _progress : 1 - power(-2 * _progress + 2, 2) / 2;
    };

    // --- Cubic ---
    /// @function InCubic(progress)
    static InCubic = function(_progress) {
        return _progress * _progress * _progress;
    };

    /// @function OutCubic(progress)
    static OutCubic = function(_progress) {
        return 1 - power(1 - _progress, 3);
    };

    /// @function InOutCubic(progress)
    static InOutCubic = function(_progress) {
        return (_progress < 0.5) ?
            4 * _progress * _progress * _progress : 1 - power(-2 * _progress + 2, 3) / 2;
    };

    // --- Quart ---
    /// @function InQuart(progress)
    static InQuart = function(_progress) {
        return _progress * _progress * _progress * _progress;
    };

    /// @function OutQuart(progress)
    static OutQuart = function(_progress) {
        return 1 - power(1 - _progress, 4);
    };

    /// @function InOutQuart(progress)
    static InOutQuart = function(_progress) {
        return (_progress < 0.5) ?
            8 * _progress * _progress * _progress * _progress : 1 - power(-2 * _progress + 2, 4) / 2;
    };

    // --- Quint ---
    /// @function InQuint(progress)
    static InQuint = function(_progress) {
        return _progress * _progress * _progress * _progress * _progress;
    };

    /// @function OutQuint(progress)
    static OutQuint = function(_progress) {
        return 1 - power(1 - _progress, 5);
    };

    /// @function InOutQuint(progress)
    static InOutQuint = function(_progress) {
        return (_progress < 0.5) ?
            16 * _progress * _progress * _progress * _progress * _progress : 1 - power(-2 * _progress + 2, 5) / 2;
    };

    // --- Expo ---
    /// @function InExpo(progress)
    static InExpo = function(_progress) {
        return (_progress == 0) ? 0 : power(2, 10 * _progress - 10);
    };

    /// @function OutExpo(progress)
    static OutExpo = function(_progress) {
        return (_progress == 1) ? 1 : 1 - power(2, -10 * _progress);
    };

    /// @function InOutExpo(progress)
    static InOutExpo = function(_progress) {
        if (_progress == 0) return 0;
        if (_progress == 1) return 1;
        return (_progress < 0.5) ?
            power(2, 20 * _progress - 10) / 2 : (2 - power(2, -20 * _progress + 10)) / 2;
    };

    // --- Circ ---
    /// @function InCirc(progress)
    static InCirc = function(_progress) {
        var _inner = 1 - power(_progress, 2);
        return 1 - ((sign(_inner) == -1) ? 0 : sqrt(_inner));
    };

    /// @function OutCirc(progress)
    static OutCirc = function(_progress) {
        var _inner = 1 - power(_progress - 1, 2);
        return (sign(_inner) == -1) ? 0 : sqrt(_inner);
    };

    /// @function InOutCirc(progress)
    static InOutCirc = function(_progress) {
        if (_progress < 0.5) {
            var _inner = 1 - power(2 * _progress, 2);
            var _sqrt = (sign(_inner) == -1) ? 0 : sqrt(_inner);
            return (1 - _sqrt) / 2;
        } else {
            var _inner = 1 - power(-2 * _progress + 2, 2);
            var _sqrt = (sign(_inner) == -1) ? 0 : sqrt(_inner);
            return (_sqrt + 1) / 2;
        }
    };

    // --- Elastic ---
    /// @function InElastic(progress)
    static InElastic = function(_progress) {
        if (_progress == 0) return 0;
        if (_progress == 1) return 1;
        return -power(2, 10 * _progress - 10) * sin((_progress * 10 - 10.75) * CASSETTE_ELASTIC_C4);
    };

    /// @function OutElastic(progress)
    static OutElastic = function(_progress) {
        if (_progress == 0) return 0;
        if (_progress == 1) return 1;
        return power(2, -10 * _progress) * sin((_progress * 10 - 0.75) * CASSETTE_ELASTIC_C4) + 1;
    };

    /// @function InOutElastic(progress)
    static InOutElastic = function(_progress) {
        if (_progress == 0) return 0;
        if (_progress == 1) return 1;
        return (_progress < 0.5)
            ? -(power(2, 20 * _progress - 10) * sin((20 * _progress - 11.125) * CASSETTE_ELASTIC_C5)) / 2
            : (power(2, -20 * _progress + 10) * sin((20 * _progress - 11.125) * CASSETTE_ELASTIC_C5)) / 2 + 1;
    };

    // --- Back ---
    /// @function InBack(progress)
    static InBack = function(_progress) {
        return CASSETTE_BACK_C3 * _progress * _progress * _progress - CASSETTE_BACK_C1 * _progress * _progress;
    };

    /// @function OutBack(progress)
    static OutBack = function(_progress) {
        return 1 + CASSETTE_BACK_C3 * power(_progress - 1, 3) + CASSETTE_BACK_C1 * power(_progress - 1, 2);
    };

    /// @function InOutBack(progress)
    static InOutBack = function(_progress) {
        return (_progress < 0.5)
            ? (power(2 * _progress, 2) * ((CASSETTE_BACK_C2 + 1) * 2 * _progress - CASSETTE_BACK_C2)) / 2
            : (power(2 * _progress - 2, 2) * ((CASSETTE_BACK_C2 + 1) * (_progress * 2 - 2) + CASSETTE_BACK_C2) + 2) / 2;
    };

    // --- Bounce ---
    /// @function OutBounce(progress)
    static OutBounce = function(_progress) {
        if (_progress < CASSETTE_BOUNCE_T1) { // < 1 / 2.75
            return CASSETTE_BOUNCE_N1 * _progress * _progress;
        } else if (_progress < CASSETTE_BOUNCE_T2) { // < 2 / 2.75
            _progress -= CASSETTE_BOUNCE_O1;
            return CASSETTE_BOUNCE_N1 * _progress * _progress + CASSETTE_BOUNCE_A1;
        } else if (_progress < CASSETTE_BOUNCE_T3) { // < 2.5 / 2.75
            _progress -= CASSETTE_BOUNCE_O2;
            return CASSETTE_BOUNCE_N1 * _progress * _progress + CASSETTE_BOUNCE_A2;
        } else {
            _progress -= CASSETTE_BOUNCE_O3;
            return CASSETTE_BOUNCE_N1 * _progress * _progress + CASSETTE_BOUNCE_A3;
        }
    };

    /// @function InBounce(progress)
    static InBounce = function(_progress) {
        return 1 - Cassette.OutBounce(1 - _progress);
    };

    /// @function InOutBounce(progress)
    static InOutBounce = function(_progress) {
        return (_progress < 0.5)
            ? (1 - Cassette.OutBounce(1 - 2 * _progress)) / 2
            : (1 + Cassette.OutBounce(2 * _progress - 1)) / 2;
    };
}