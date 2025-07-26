/// --- Ease ---
// A portable collection of easing functions in a handy literal syntax e.g. "ease.InOutExpo(_t)"
// Features a simple yet powerful animation system with chainable transitions.
// -- by:    Mr. Giff
// -- ver:  1.0.0
// -- lic:    MIT

// --- Take time in Seconds if true (e.g 0.9) vs Frames (e.g 120)
#macro EASE_USE_DELTA_TIME false

// "Fast Math"
// --- Bounce Constants ---
#macro EASE_BOUNCE_N1 7.5625
#macro EASE_BOUNCE_D1 2.75
#macro EASE_BOUNCE_T1 (1 / EASE_BOUNCE_D1)   // Threshold 1: 1 / 2.75
#macro EASE_BOUNCE_T2 (2 / EASE_BOUNCE_D1)   // Threshold 2: 2 / 2.75
#macro EASE_BOUNCE_T3 (2.5 / EASE_BOUNCE_D1) // Threshold 3: 2.5 / 2.75
#macro EASE_BOUNCE_O1 (1.5 / EASE_BOUNCE_D1) // Offset 1: 1.5 / 2.75
#macro EASE_BOUNCE_O2 (2.25 / EASE_BOUNCE_D1) // Offset 2: 2.25 / 2.75
#macro EASE_BOUNCE_O3 (2.625 / EASE_BOUNCE_D1) // Offset 3: 2.625 / 2.75
#macro EASE_BOUNCE_A1 0.75     // Addition 1
#macro EASE_BOUNCE_A2 0.9375   // Addition 2
#macro EASE_BOUNCE_A3 0.984375 // Addition 3

// --- Elastic Constants ---
#macro EASE_ELASTIC_PERIOD1_DIV 3.0
#macro EASE_ELASTIC_PERIOD2_DIV 4.5
#macro EASE_ELASTIC_C4 ((2 * pi) / EASE_ELASTIC_PERIOD1_DIV) // Constant for In/Out Elastic period
#macro EASE_ELASTIC_C5 ((2 * pi) / EASE_ELASTIC_PERIOD2_DIV) // Constant for InOut Elastic period

// --- Back Constants ---
#macro EASE_BACK_S1 1.70158                 // Overshoot amount factor
#macro EASE_BACK_S2 (EASE_BACK_S1 * 1.525) // Overshoot amount factor for InOut
#macro EASE_BACK_C1 EASE_BACK_S1           // Keep c1 for consistency
#macro EASE_BACK_C2 EASE_BACK_S2           // Keep c2 for consistency
#macro EASE_BACK_C3 (EASE_BACK_S1 + 1)     // Derived constant for In/Out Back

/// @enum EASE_ANIM
/// @desc Defines the playback behavior for a transition.
enum EASE_ANIM {
    Once,     // Plays the animation one time from start to finish.
    Loop,     // Restarts the animation from the beginning after it finishes.
    PingPong  // Reverses the animation direction when it reaches the end.
}

/// @function ease()
/// @description A centralized, self-contained class for chained, sequenced animations with advanced playback
function ease() constructor{
    
    static active_transitions = {};

    // --- Private Chain Builder ---
    // This is returned by 'transition()' to allow for method chaining.
    function EaseChainBuilder(_queue_ref) constructor {
        queue = _queue_ref;
        
        /// @function add(from, to, duration, func, [anim_state], [loop_for])
        /// @desc Adds a new transition to the sequence.
        add = function(_from, _to, _duration, _func, _anim_state = EASE_ANIM.Once, _loop_for = -1) {
            var _next_definition = {
                from_val: _from, to_val: _to, duration: _duration, ease_func: _func,
                anim_state: _anim_state, loops_left: _loop_for
            };
            array_push(queue, _next_definition);
            return self;
        }
    }
    
    // --- Public Methods ---
    
    /// @function transition(key, from, to, duration, func, [anim_state], [loop_for])
    /// @description Starts a new transition sequence and returns a chainable object.
    static transition = function(_key, _from, _to, _duration, _func, _anim_state = EASE_ANIM.Once, _loop_for = -1) {
        // This is the definition for the FIRST transition in the sequence.
        var _first_definition = {
            from_val: _from, to_val: _to, duration: _duration, ease_func: _func,
            anim_state: _anim_state, loops_left: _loop_for
        };
        
        // The manager holds the queue and the LIVE state of the currently running animation.
        var _manager = {
            queue: [_first_definition],
            current_index: 0,
            
            // Live state for the current animation
            current_val: _from,
            timer: 0,
            direction: 1,
            loops_left: (_anim_state == EASE_ANIM.Once) ? 1 : _loop_for
        };
        
        active_transitions[$ _key] = _manager;
        
        // Return a new builder that operates on the manager's queue.
        return new EaseChainBuilder(_manager.queue);
    }
    
    /// @function update()
    /// @description Updates all active transitions.
    static update = function() {
        var _completed_keys = [];

        var _update_callback = function(_key, _manager) {
            var _current_def = _manager.queue[_manager.current_index];

            // 1. Update Timer
            if (EASE_USE_DELTA_TIME) { _manager.timer += (delta_time / 1000000); } 
            else { _manager.timer++; }

            var _raw_progress = min(1, _manager.timer / _current_def.duration);
            var _eased_progress = 0;
            var _ease_source = _current_def.ease_func;
            
            // --- Handle both regular functions and custom curves ---
            if (is_struct(_ease_source) && variable_struct_exists(_ease_source, "__is_anim_curve")) {
                // It's a custom curve object, so evaluate it
                _eased_progress = animcurve_channel_evaluate(_ease_source.channel, _raw_progress);
            } else {
                // It's a regular easing method, so call it
                _eased_progress = _ease_source(_raw_progress);
            }

            // 2. Set Value
            if (_manager.direction == 1) { _manager.current_val = lerp(_current_def.from_val, _current_def.to_val, _eased_progress); } 
            else { _manager.current_val = lerp(_current_def.to_val, _current_def.from_val, _eased_progress); }
            
            // 3. Handle Completion or Next in Chain
            if (_raw_progress >= 1) {
                var _is_looping = _current_def.anim_state == EASE_ANIM.Loop;
                var _is_pingpong = _current_def.anim_state == EASE_ANIM.PingPong;

                // Check loop counter
                if (_manager.loops_left > 0 && (_is_looping || (_is_pingpong && _manager.direction == -1))) {
                    _manager.loops_left--;
                }

                // If loops remain, repeat the current animation segment
                if (_manager.loops_left != 0) {
                    if (_is_looping) { _manager.timer = 0; } 
                    else if (_is_pingpong) { _manager.timer = 0; _manager.direction *= -1; }
                } 
                // Otherwise, move to the next transition in the chain
                else {
                    _manager.current_index++;
                    // If there's another transition in the queue...
                    if (_manager.current_index < array_length(_manager.queue)) {
                        var _next_def = _manager.queue[_manager.current_index];
                        // ...initialize the manager's state for it.
                        _manager.current_val = _next_def.from_val;
                        _manager.timer = 0;
                        _manager.direction = 1;
                        _manager.loops_left = (_next_def.anim_state == EASE_ANIM.Once) ? 1 : _next_def.loops_left;
                    } 
                    // Otherwise, the entire chain is done.
                    else {
                        array_push(_completed_keys, _key);
                    }
                }
            }
        };

        struct_foreach(active_transitions, _update_callback);
        
        for (var i = 0; i < array_length(_completed_keys); i++) {
            variable_struct_remove(active_transitions, _completed_keys[i]);
        }
    }
    
    /// @function stop(key)
    /// @description Immediately stops and removes a specific transition sequence.
    /// @param {string} key The unique name of the transition sequence to stop.
    /// @returns {bool} Returns true if a transition was found and stopped, otherwise false.
    static stop = function(_key) {
        if (variable_struct_exists(active_transitions, _key)) {
            variable_struct_remove(active_transitions, _key);
            return true;
        }
        return false;
    }
    
    /// @function clear_all()
    /// @description Immediately stops and removes all active transition sequences.
    static clear_all = function() {
        active_transitions = {};
    }

    /// @function get_value(key, default_val)
    /// @description Returns the current value of a named transition sequence.
    static get_value = function(_key, _default_val) {
        if (variable_struct_exists(active_transitions, _key)) {
            return active_transitions[$ _key].current_val;
        }
        return _default_val;
    }
    
    /// @function is_active(key)
    /// @description Returns true if a specific transition sequence is currently running.
    static is_active = function(_key) {
        return variable_struct_exists(active_transitions, _key);
    }
	
	/// @function custom(curve_asset_or_struct, [channel_index])
    /// @description Prepares a GameMaker Animation Curve asset for use in a transition.
    /// @param {Asset.GMAnimCurve|Struct} curve_asset_or_struct The Animation Curve asset (e.g. ac_MyCurve) or a pre-fetched struct from animcurve_get().
    /// @param {real} [channel_index=0] The channel index within the curve to use.
    /// @returns {Struct|undefined} A special struct for the update method to recognize, or undefined on failure.
    static custom = function(_curve_asset_or_struct, _channel_index = 0) {
        var _curve_struct = _curve_asset_or_struct;
        
        // If not a struct, assume it's an asset ID and try to get the struct
        if (!is_struct(_curve_struct)) {
            _curve_struct = animcurve_get(_curve_asset_or_struct);
        }
        
        // Validate the curve and channel
        if (!is_struct(_curve_struct) || !variable_struct_exists(_curve_struct, "channels")) return undefined;
        if (_channel_index >= array_length(_curve_struct.channels)) return undefined;
        
        var _channel = _curve_struct.channels[_channel_index];
        
        // Return a special struct that identifies this as a custom curve channel
        return {
            __is_anim_curve: true,
            channel: _channel
        };
    }

    // --- Sine ---
    /// @function InSine(progress)
    /// @description Sine easing in. Accelerates from zero.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InSine = function(progress) {
        return 1 - cos((progress * pi) / 2);
    };

    /// @function OutSine(progress)
    /// @description Sine easing out. Decelerates to zero.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutSine = function(progress) {
        return sin((progress * pi) / 2);
    };

    /// @function InOutSine(progress)
    /// @description Sine easing in and out. Accelerates and decelerates.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutSine = function(progress) {
        return -(cos(pi * progress) - 1) / 2;
    };

    // --- Quad ---
    /// @function InQuad(progress)
    /// @description Quadratic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InQuad = function(progress) {
        return progress * progress;
    };

    /// @function OutQuad(progress)
    /// @description Quadratic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutQuad = function(progress) { // Renamed from easeOutQuad for consistency
        return 1 - power(1 - progress, 2);
    };

    /// @function InOutQuad(progress)
    /// @description Quadratic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutQuad = function(progress) {
        return (progress < 0.5) ? 2 * progress * progress : 1 - power(-2 * progress + 2, 2) / 2;
    };

    // --- Cubic ---
    /// @function InCubic(progress)
    /// @description Cubic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InCubic = function(progress) {
        return progress * progress * progress;
    };

    /// @function OutCubic(progress)
    /// @description Cubic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutCubic = function(progress) {
        return 1 - power(1 - progress, 3);
    };

    /// @function InOutCubic(progress)
    /// @description Cubic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutCubic = function(progress) {
        return (progress < 0.5) ? 4 * progress * progress * progress : 1 - power(-2 * progress + 2, 3) / 2;
    };

    // --- Quart ---
    /// @function InQuart(progress)
    /// @description Quartic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InQuart = function(progress) {
        return progress * progress * progress * progress;
    };

    /// @function OutQuart(progress)
    /// @description Quartic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutQuart = function(progress) {
        return 1 - power(1 - progress, 4);
    };

    /// @function InOutQuart(progress)
    /// @description Quartic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutQuart = function(progress) {
        return (progress < 0.5) ? 8 * progress * progress * progress * progress : 1 - power(-2 * progress + 2, 4) / 2;
    };

    // --- Quint ---
    /// @function InQuint(progress)
    /// @description Quintic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InQuint = function(progress) {
        return progress * progress * progress * progress * progress;
    };

    /// @function OutQuint(progress)
    /// @description Quintic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutQuint = function(progress) {
        return 1 - power(1 - progress, 5);
    };

    /// @function InOutQuint(progress)
    /// @description Quintic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutQuint = function(progress) {
        return (progress < 0.5) ? 16 * progress * progress * progress * progress * progress : 1 - power(-2 * progress + 2, 5) / 2;
    };

    // --- Expo ---
    /// @function InExpo(progress)
    /// @description Exponential easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InExpo = function(progress) {
        return (progress == 0) ? 0 : power(2, 10 * progress - 10);
    };

    /// @function OutExpo(progress)
    /// @description Exponential easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutExpo = function(progress) {
        return (progress == 1) ? 1 : 1 - power(2, -10 * progress);
    };

    /// @function InOutExpo(progress)
    /// @description Exponential easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutExpo = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        return (progress < 0.5) ? power(2, 20 * progress - 10) / 2 : (2 - power(2, -20 * progress + 10)) / 2;
    };

    // --- Circ ---
    /// @function InCirc(progress)
    /// @description Circular easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InCirc = function(progress) {
        return 1 - sqrt(1 - power(progress, 2));
    };

    /// @function OutCirc(progress)
    /// @description Circular easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutCirc = function(progress) {
        return sqrt(1 - power(progress - 1, 2));
    };

    /// @function InOutCirc(progress)
    /// @description Circular easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutCirc = function(progress) {
        return (progress < 0.5)
            ? (1 - sqrt(1 - power(2 * progress, 2))) / 2
            : (sqrt(1 - power(-2 * progress + 2, 2)) + 1) / 2;
    };

    // --- Elastic ---
    /// @function InElastic(progress)
    /// @description Elastic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 10.75 = (EASE_ELASTIC_PERIOD1_DIV * 3 + 1.75) if needed, relates to phase shift
        return -power(2, 10 * progress - 10) * sin((progress * 10 - 10.75) * EASE_ELASTIC_C4);
    };

    /// @function OutElastic(progress)
    /// @description Elastic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 0.75 = related to phase shift
        return power(2, -10 * progress) * sin((progress * 10 - 0.75) * EASE_ELASTIC_C4) + 1;
    };

    /// @function InOutElastic(progress)
    /// @description Elastic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 11.125 = (EASE_ELASTIC_PERIOD2_DIV * 2 + 2.125) if needed, relates to phase shift
        return (progress < 0.5)
            ? -(power(2, 20 * progress - 10) * sin((20 * progress - 11.125) * EASE_ELASTIC_C5)) / 2
            : (power(2, -20 * progress + 10) * sin((20 * progress - 11.125) * EASE_ELASTIC_C5)) / 2 + 1;
    };

    // --- Back ---
    /// @function InBack(progress)
    /// @description Back easing in. Overshoots then settles.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InBack = function(progress) {
        return EASE_BACK_C3 * progress * progress * progress - EASE_BACK_C1 * progress * progress;
    };

    /// @function OutBack(progress)
    /// @description Back easing out. Overshoots then settles.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutBack = function(progress) {
        return 1 + EASE_BACK_C3 * power(progress - 1, 3) + EASE_BACK_C1 * power(progress - 1, 2);
    };

    /// @function InOutBack(progress)
    /// @description Back easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutBack = function(progress) {
        return (progress < 0.5)
            ? (power(2 * progress, 2) * ((EASE_BACK_C2 + 1) * 2 * progress - EASE_BACK_C2)) / 2
            : (power(2 * progress - 2, 2) * ((EASE_BACK_C2 + 1) * (progress * 2 - 2) + EASE_BACK_C2) + 2) / 2;
    };

    // --- Bounce ---
    /// @function OutBounce(progress)
    /// @description Bounce easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutBounce = function(progress) {
        if (progress < EASE_BOUNCE_T1) { // < 1 / 2.75
            return EASE_BOUNCE_N1 * progress * progress;
        } else if (progress < EASE_BOUNCE_T2) { // < 2 / 2.75
            progress -= EASE_BOUNCE_O1; // -= 1.5 / 2.75
            return EASE_BOUNCE_N1 * progress * progress + EASE_BOUNCE_A1; // + 0.75
        } else if (progress < EASE_BOUNCE_T3) { // < 2.5 / 2.75
            progress -= EASE_BOUNCE_O2; // -= 2.25 / 2.75
            return EASE_BOUNCE_N1 * progress * progress + EASE_BOUNCE_A2; // + 0.9375
        } else {
            progress -= EASE_BOUNCE_O3; // -= 2.625 / 2.75
            return EASE_BOUNCE_N1 * progress * progress + EASE_BOUNCE_A3; // + 0.984375
        }
    };

    /// @function InBounce(progress)
    /// @description Bounce easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InBounce = function(progress) {
        // Re-use OutBounce by inverting the progress
        // Need to call the OutBounce function associated *with this instance*
        return 1 - ease.OutBounce(1 - progress);
    };

    /// @function InOutBounce(progress)
    /// @description Bounce easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutBounce = function(progress) {
        // Re-use OutBounce by inverting/scaling the progress
        // Need to call the OutBounce function associated *with this instance*
        return (progress < 0.5)
            ? (1 - ease.OutBounce(1 - 2 * progress)) / 2
            : (1 + ease.OutBounce(2 * progress - 1)) / 2;
    };
}

/// @function derp(current, target, decay_rate)
/// @description A (*faster?) version of lerp that uses delta_time and pre-calculated decay rate.
/// @param {Real} current      The current value.
/// @param {Real} target       The target value.
/// @param {Real} decay_rate   The rate of decay (1 / half_life_seconds).
function derp(current, target, decay_rate) {
    var _delta_seconds = delta_time / 1000000;

    var _amount = 1 - power(0.5, _delta_seconds * decay_rate);

    return lerp(current, target, _amount);
}
