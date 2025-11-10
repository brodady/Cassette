/// --- Cassette ---
// A simple yet powerful animation system singleton with chainable transitions.
// Featuring a portable collection of easing functions in a handy literal syntax. e.g. "ease.InOutExpo(_t)"
// -- by:   Mr. Giff
// -- ver:  1.3.0 (New playback controls and upgrades: play, skip, back, seek, pause, ffwd, rewind, get_speed, set_speed, is_paused)
// -- lic:  MIT

// --- Take time in Seconds if true (e.g 0.9) vs Frames (e.g 120)
#macro CASSETTE_USE_DELTA_TIME false

// --- Whether animations should start playing or be started manually with the '.play' method
#macro CASSETTE_AUTO_START false 

// --- Playback speed (Internal use, don't touch this. Use the '.set_speed' method)
#macro CASSETTE_DEFAULT_PLAYBACK_SPEED 1.0

// "Fast Math"
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
    Once,     // Plays the animation one time from start to finish (default).
    Loop,     // Restarts the animation from the beginning after it finishes.
    PingPong  // Reverses the animation direction when it reaches the end.
}

/// @function Cassette()
/// @description A centralized, self-contained class for chained, sequenced animations with advanced playback
function Cassette() constructor{
    
    static active_transitions = {};

    // --- Private Chain Builder ---
    // This is returned by 'transition()' to allow for method chaining.
    function ChainBuilder(_queue_ref) constructor {
        queue = _queue_ref;
        
        /// @function add(from, to, duration, func, [anim_state], [loop_for])
        /// @desc Adds a new transition to the sequence.
        add = function(_from, _to, _duration, _func, _anim_state = CASSETTE_ANIM.Once, _loop_for = -1) {
            var _next_definition = {
                from_val: _from, to_val: _to, duration: _duration, CASSETTE_func: _func,
                anim_state: _anim_state, loops_left: _loop_for
            };
            array_push(queue, _next_definition);
            return self;
        } 
        
        /// @function wait(duration)
        /// @desc Adds a pause to the sequence for a given duration.
        /// @param {real} _duration The time to wait (in frames or seconds, matching CASSETTE_USE_DELTA_TIME).
        wait = function(_duration) {
            var _wait_definition = {
                is_wait: true,
                duration: _duration,
                anim_state: CASSETTE_ANIM.Once,
                loops_left: 1                   
            };
            array_push(queue, _wait_definition);
            return self;
        }
    }
    
    // --- Public Methods ---
    
    /// @function transition(key, from, to, duration, func, [anim_state], [loop_for], [custom_lerp_func])
    /// @description Starts a new transition sequence and returns a chainable object.
    static transition = function(_key, _from, _to, _duration, _func, _anim_state = CASSETTE_ANIM.Once, _loop_for = -1, _lerp_func = lerp) {
        // This is the definition for the first transition in the sequence.
        var _first_definition = {
            from_val: _from, to_val: _to, duration: _duration, CASSETTE_func: _func,
            anim_state: _anim_state, loops_left: _loop_for
        };
        
        // The manager holds the queue and the live state of the currently running animation.
        var _manager = { 
            queue: [_first_definition],
            current_index: 0,
            lerp_func: _lerp_func,
            
            // State
            current_val: _from,
            timer: 0,
            direction: 1,
            loops_left: (_anim_state == CASSETTE_ANIM.Once) ? 1 : _loop_for,
            is_paused: !CASSETTE_AUTO_START,
            playback_speed: CASSETTE_DEFAULT_PLAYBACK_SPEED, 
        };
        
        active_transitions[$ _key] = _manager;
        
        // Return a new builder that operates on the manager's queue.
        return new ChainBuilder(_manager.queue);
    }
    
    /// @function update()
    /// @description Updates all active transitions.
    static update = function() {
        var _completed_keys = [];
        
        var _keys = variable_struct_get_names(active_transitions);
        for (var i = 0; i < array_length(_keys); i++) {
            var _key = _keys[i];
            
            if (!variable_struct_exists(active_transitions, _key)) {
                continue;
            }
            
            var _manager = active_transitions[$ _key];
        
            if (_manager.is_paused) {
                continue; 
            }
            
            var _current_def = _manager.queue[_manager.current_index];
            
            // --- 1. Handle time ---
            var _playback_speed = _manager.playback_speed;
            var _effective_direction = sign(_playback_speed) * _manager.direction; 
            
            var _time_step = 0;
            if (CASSETTE_USE_DELTA_TIME) { 
                _time_step = (delta_time / 1000000) * abs(_playback_speed); 
            } else { 
                _time_step = 1 * abs(_playback_speed); 
            }
            
            _manager.timer += _time_step * _effective_direction;

            // --- 2. Handle wait ---
            if (variable_struct_exists(_current_def, "is_wait")) {
                if (_manager.timer >= _current_def.duration) {
                    var _overflow = _manager.timer - _current_def.duration;
                    _manager.direction = 1; 
                    _move_to_next_track(_manager, _key, _completed_keys, _overflow);
                }
                else if (_manager.timer < 0) {
                    var _underflow = _manager.timer;
                    _manager.direction = 1; 
                    _handle_backward_completion(_manager, _key, _underflow);
                }
                continue;
            }

            // --- 3. Animation Logic ---
            var _raw_progress = 0;
            if (_current_def.duration <= 0) {
                _raw_progress = 1;
            } else {
                _raw_progress = clamp(_manager.timer / _current_def.duration, 0, 1);
            }
            
            var _eased_progress = 0;
            var _lerper = _manager.lerp_func;
            var _CASSETTE_source = _current_def.CASSETTE_func;
            
            if (is_struct(_CASSETTE_source) && variable_struct_exists(_CASSETTE_source, "__is_anim_curve")) {
                _eased_progress = animcurve_channel_evaluate(_CASSETTE_source.channel, _raw_progress);
            } else {
                _eased_progress = _CASSETTE_source(_raw_progress);
            }

            _manager.current_val = _lerper(_current_def.from_val, _current_def.to_val, _eased_progress);
            
            // --- 4. Handle Completion (Boundaries) ---
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            var _is_once = _current_def.anim_state == CASSETTE_ANIM.Once;
            
            // --- FORWARD BOUNDARY (timer >= duration) ---
            if (_manager.timer >= _current_def.duration) {
                var _overflow = _manager.timer - _current_def.duration;

                if (_is_looping) {
                    if (_manager.loops_left > 0) _manager.loops_left--;
                    if (_manager.loops_left != 0) {
                        _manager.timer = _overflow; 
                    } else {
                        _move_to_next_track(_manager, _key, _completed_keys, _overflow);
                    }
                }
                else if (_is_pingpong) {
                    if (_manager.loops_left != 0) {
                        _manager.timer = _current_def.duration - _overflow; 
                        _manager.direction *= -1; 
                    } else {
                        _move_to_next_track(_manager, _key, _completed_keys, _overflow);
                    }
                }
                else { // _is_once
                    _move_to_next_track(_manager, _key, _completed_keys, _overflow);
                }
            }
            // --- BACKWARD BOUNDARY (timer <= 0) ---
            else if (_manager.timer < 0) {
                var _underflow = _manager.timer;
                
                if (_is_looping) {
                    if (_manager.loops_left != 0) {
                        _manager.timer = _current_def.duration + _underflow;
                    } else {
                        _handle_backward_completion(_manager, _key, _underflow);
                    }
                }
                else if (_is_pingpong) {
                    if (_manager.loops_left > 0) _manager.loops_left--;
                    
                    if (_manager.loops_left != 0) {
                        _manager.timer = 0 - _underflow; 
                        _manager.direction *= -1; 
                    } else { 
                        _move_to_next_track(_manager, _key, _completed_keys, 0 - _underflow);
                    }
                }
                else { // _is_once
                     _handle_backward_completion(_manager, _key, _underflow);
                }
            }
        }
        
        for (var i = 0; i < array_length(_completed_keys); i++) {
            variable_struct_remove(active_transitions, _completed_keys[i]);
        }
    }

    // --- Player Controls ---

    /// @function play([keys])
    /// @desc Resumes one or all active transitions.
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static play = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            _manager.is_paused = false;
        });
    }

    /// @function pause([keys])
    /// @desc Pauses one or all active transitions.
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static pause = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            _manager.is_paused = true;
        });
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

    /// @function ffwd([keys])
    /// @desc Jumps to the very end of one or all transitions (last track, last frame).
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static ffwd = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            _manager.current_index = array_length(_manager.queue) - 1;
            var _last_def = _manager.queue[_manager.current_index];
            
            _manager.timer = _last_def.duration;
            _manager.direction = 1;
            _manager.loops_left = 0;
            
            if (!variable_struct_exists(_last_def, "is_wait")) {
                _manager.current_val = _last_def.to_val;
            }
            
            _manager.is_paused = true; 
        });
    }

    /// @function rewind([keys])
    /// @desc Reset one or all transitions to their very beginning (first track).
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static rewind = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            _init_track(_manager, 0); 
    
            if (!CASSETTE_AUTO_START) {
                _manager.is_paused = true;
            }
        });
    }

     /// @function seek(amount, [keys])
    /// @desc Seeks forward/backward by a duration (in frames/seconds).
    /// @param {Real} amount The duration to seek (can be negative).
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static seek = function(_amount, _keys = undefined) {
        _apply_to_managers(_keys, _seek_manager, _amount);
    }

    /// @function skip([keys])
    static skip = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            if (_manager.current_index + 1 < array_length(_manager.queue)) {
                _init_track(_manager, _manager.current_index + 1);
            } else {
                // At the end, go to the end and pause
                var _last_index = array_length(_manager.queue) - 1;
                var _last_def = _manager.queue[_last_index];
                _init_track(_manager, _last_index, _last_def.duration);
                _manager.is_paused = true; 
            }
        });
    }

    /// @function back([keys])
    static back = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            if (_manager.current_index > 0) {
                _init_track(_manager, _manager.current_index - 1);
            } else {
                _init_track(_manager, 0);
            }
        });
    }
	
	/// @function get_speed(key)
    /// @description Returns the playback speed of a specific transition.
    /// @param {String} _key The unique name of the transition sequence.
    /// @returns {Real|Undefined} Returns the speed (e.g., 1.0) if the transition exists, or undefined if it does not.
    static get_speed = function(_key) {
        if (variable_struct_exists(active_transitions, _key)) {
            return active_transitions[$ _key].playback_speed;
        }
        return undefined;
    }
	
    /// @function set_speed(speed, [keys])
    /// @desc Sets playback speed for one or all transitions (1 = normal, 2 = 2x, -1 = reverse).
    /// @param {Real} speed The new playback speed multiplier.
    /// @param {String|Array<String>} [keys] Optional: A key or array of keys. Affects all if omitted.
    static set_speed = function(_speed, _keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _speed_data, _key) { 
            _manager.playback_speed = _speed_data; 
        }, _speed);
    }

    /// @function clear_all()
    /// @description Immediately stops and removes all active transition sequences.
    static clear_all = function() {
        active_transitions = {};
    }

    /// @function get_value(key, default_val)
	/// @param {String} _key The unique name of the transition sequence.
	/// @param {Real} _default_val The default value to fallback to.
    /// @description Returns the current value of a named transition sequence.
    static get_value = function(_key, _default_val) {
        if (variable_struct_exists(active_transitions, _key)) {
            return active_transitions[$ _key].current_val;
        }
        return _default_val;
    }
    
    /// @function is_active(key)
	/// @param {String} _key The unique name of the transition sequence.
    /// @description Returns true if a specific transition sequence is in process (if it exists, not the same as paused).
    static is_active = function(_key) {
        return variable_struct_exists(active_transitions, _key);
    }
	
	/// @function is_paused(key)
    /// @description Returns true if a specific transition sequence is currently paused.
    /// @param {String} _key The unique name of the transition sequence.
    /// @returns {Bool|Undefined} Returns true/false if the transition exists, or undefined if it does not.
    static is_paused = function(_key) {
        if (variable_struct_exists(active_transitions, _key)) {
            return active_transitions[$ _key].is_paused;
        }
        return undefined;
    }

	/// @function custom(curve_asset_or_struct, [channel_index])
    /// @description Prepares a GameMaker Animation Curve asset for use in a transition.
    /// @param {Asset.GMAnimCurve|Struct} curve_asset_or_struct The Animation Curve asset (e.g. ac_MyCurve) or a pre-fetched struct from animcurve_get().
    /// @param {real} [channel_index] The channel index within the curve to use.
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
        
        return {
            __is_anim_curve: true,
            channel: _channel
        };
    }

    // --- Private Helpers ---

    /// @desc (Internal) Sets a manager's state to a specific track index and timer.
    /// @param {Struct} _manager The animation manager.
    /// @param {Real} _index The index in the queue to set.
    /// @param {Real} [_timer] The new timer value (e.g., overflow or underflow).
    /// @param {Real} [_start_dir] 1 = start at beginning, -1 = start at end.
    static _init_track = function(_manager, _index, _timer = 0, _start_dir = 1) {
        _manager.current_index = _index;
        var _def = _manager.queue[_index];
        
        _manager.loops_left = (_def.anim_state == CASSETTE_ANIM.Once) ? 1 : _def.loops_left;
        
        if (_def.anim_state == CASSETTE_ANIM.PingPong && _start_dir == -1) {
            _manager.direction = -1;
            _manager.timer = _def.duration + _timer; 
        } else {
            _manager.direction = 1; 
            _manager.timer = _timer;
        }

        _evaluate_and_set_value(_manager);
    }

    /// @desc (Internal) Advances a manager to its next track or marks it for completion.
    static _move_to_next_track = function(_manager, _key_for_completion, _completed_keys_ref, _overflow = 0) {
        if (_manager.current_index + 1 < array_length(_manager.queue)) {
            _init_track(_manager, _manager.current_index + 1, _overflow, 1);
        } 
        else {
            array_push(_completed_keys_ref, _key_for_completion);
        }
    };

    /// @desc (Internal) Moves a manager to the end of its previous track.
    static _handle_backward_completion = function(_manager, _key_for_completion, _underflow) {
        if (_manager.current_index > 0) {
            var _prev_index = _manager.current_index - 1;
            _init_track(_manager, _prev_index, _underflow, -1);
        } 
        else {
            _manager.timer = 0;
            _manager.direction = 1;
        }
    };
    /// @desc (Internal) Applies a callback to one, many, or all active transitions.
    static _apply_to_managers = function(_target_keys, _action_func, _data = undefined) {
        if (_target_keys == undefined) {
            // --- Affect All ---
            var _keys = variable_struct_get_names(active_transitions);
            for (var i = 0; i < array_length(_keys); i++) {
                var _key = _keys[i];
                if (variable_struct_exists(active_transitions, _key)) {
                    _action_func(active_transitions[$ _key], _data, _key); 
                }
            }
        } else if (is_array(_target_keys)) {
            // --- Affect Array ---
            for (var i = 0; i < array_length(_target_keys); i++) {
                var _key = _target_keys[i];
                if (variable_struct_exists(active_transitions, _key)) {
                    _action_func(active_transitions[$ _key], _data, _key); 
                }
            }
        } else if (is_string(_target_keys)) {
            // --- Affect Single ---
            if (variable_struct_exists(active_transitions, _target_keys)) {
                _action_func(active_transitions[$ _target_keys], _data, _target_keys); 
            }
        }
    }
    
    /// @desc (Internal) Re-evaluates and sets a manager's current_val based on its timer.
    static _evaluate_and_set_value = function(_manager) {
        // If the current spot is a wait, value is unchanged
        var _current_def = _manager.queue[_manager.current_index];
        if (variable_struct_exists(_current_def, "is_wait")) {
            return; 
        }

        // It's a regular animation track. Evaluate it.
        var _raw_progress = 0;
        if (_current_def.duration <= 0) {
            _raw_progress = 1;
        } else {
            _raw_progress = clamp(_manager.timer / _current_def.duration, 0, 1);
        }
        var _eased_progress = 0;
        var _lerper = _manager.lerp_func;
        var _CASSETTE_source = _current_def.CASSETTE_func;
        
        if (is_struct(_CASSETTE_source) && variable_struct_exists(_CASSETTE_source, "__is_anim_curve")) {
            _eased_progress = animcurve_channel_evaluate(_CASSETTE_source.channel, _raw_progress);
        } else {
            _eased_progress = _CASSETTE_source(_raw_progress);
        }
        
        // Seeking/initing doesn't support PingPong direction; it always resets to forward.
        _manager.current_val = _lerper(_current_def.from_val, _current_def.to_val, _eased_progress);
    }

    /// @desc (Internal) The core logic for seeking.
    static _seek_manager = function(_manager, _seek_amount, _key) { 
    
        _manager.timer += _seek_amount;
        
        var _chain_is_finished = false;
        var _current_def = _manager.queue[_manager.current_index];
        
        // --- 2. Handle Forward Overflow (timer > duration) ---
        while (_manager.timer > _current_def.duration) {
            
            var _overflow_time = _manager.timer - _current_def.duration;
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            var _duration = _current_def.duration;

            // --- Check for loop/pong on CURRENT track first ---
            if ((_is_looping || _is_pingpong) && _manager.loops_left != 0) {

                if (_duration <= 0) { 
                    _manager.timer = 0;
                    _manager.direction = 1;
                    break;
                }

                if (_is_looping) {
                    _manager.timer = _manager.timer % _duration;
                    _manager.direction = 1;
                }
                else { // _is_pingpong
                    var _total_loop_duration = _duration * 2;
                    var _wrapped_time = _manager.timer % _total_loop_duration;
                    
                    if (_wrapped_time > _duration) {
                        // "pong"
                        _manager.timer = _duration - (_wrapped_time - _duration);
                        _manager.direction = -1;
                    } else {
                        // "ping"
                        _manager.timer = _wrapped_time;
                        _manager.direction = 1;
                    }
                }
                break; 
            }
            
            // --- No loop. Try to move to NEXT track ---
            if (_manager.current_index + 1 < array_length(_manager.queue)) {
                _init_track(_manager, _manager.current_index + 1, _overflow_time, 1);
                _current_def = _manager.queue[_manager.current_index];
            } 
            // --- No next track. This is the end. ---
            else {
                _manager.timer = _current_def.duration; 
                _manager.direction = 1; 
                _chain_is_finished = true; 
                break; 
            }
        }

        // --- 3. Handle Backward Underflow (timer < 0) ---
        while (_manager.timer < 0) {
            
            var _underflow_time = _manager.timer;
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            var _duration = _current_def.duration;

            // --- Check for loop/pong on CURRENT track first ---
            if ((_is_looping || _is_pingpong) && _manager.loops_left != 0) {
                
                if (_duration <= 0) { // Avoid divide-by-zero
                    _manager.timer = 0;
                    _manager.direction = 1;
                    break;
                }

                if (_is_looping) {
                    _manager.timer = _manager.timer % _duration;
                    _manager.direction = 1;
                } 
                else { // _is_pingpong
                    var _total_loop_duration = _duration * 2;
                    var _wrapped_time = _manager.timer % _total_loop_duration;
                    
                    if (_wrapped_time > _duration) {
                        // "pong"
                        _manager.timer = _duration - (_wrapped_time - _duration);
                        _manager.direction = -1;
                    } else {
                        // "ping"
                        _manager.timer = _wrapped_time;
                        _manager.direction = 1;
                    }
                }
                break; 
            }
            
            // --- No loop. Try to move to PREVIOUS track ---
            if (_manager.current_index > 0) {
                _init_track(_manager, _manager.current_index - 1, _underflow_time, -1);
                _current_def = _manager.queue[_manager.current_index];
            } 
            // --- No previous track. This is the beginning. ---
            else {
                _manager.timer = 0; // Clamp to start
                _manager.direction = 1; // Reset direction
                break; // Exit while loop
            }
        }
        
        // --- 4. Finalize State ---
        if (_chain_is_finished) {
             _evaluate_and_set_value(_manager); 
             _manager.is_paused = true; 
             return; 
        }
        
        _evaluate_and_set_value(_manager);
    }

    // --- Easing Functions --

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
        var _inner = 1 - power(progress, 2);
        return 1 - ((sign(_inner) == -1)? 0 : sqrt(_inner));
    };

    /// @function OutCirc(progress)
    /// @description Circular easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutCirc = function(progress) {
        var _inner = 1 - power(progress - 1, 2);
        return (sign(_inner) == -1)? 0 : sqrt(_inner);
    };

    /// @function InOutCirc(progress)
    /// @description Circular easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutCirc = function(progress) {
        if (progress < 0.5) {
            var _inner = 1 - power(2 * progress, 2);
            var _sqrt = (sign(_inner) == -1)? 0 : sqrt(_inner);
            return (1 - _sqrt) / 2;
        } else {
            var _inner = 1 - power(-2 * progress + 2, 2);
            var _sqrt = (sign(_inner) == -1)? 0 : sqrt(_inner);
            return (_sqrt + 1) / 2;
        }
    };

    // --- Elastic ---
    /// @function InElastic(progress)
    /// @description Elastic easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 10.75 = (CASSETTE_ELASTIC_PERIOD1_DIV * 3 + 1.75) if needed, relates to phase shift
        return -power(2, 10 * progress - 10) * sin((progress * 10 - 10.75) * CASSETTE_ELASTIC_C4);
    };

    /// @function OutElastic(progress)
    /// @description Elastic easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 0.75 = related to phase shift
        return power(2, -10 * progress) * sin((progress * 10 - 0.75) * CASSETTE_ELASTIC_C4) + 1;
    };

    /// @function InOutElastic(progress)
    /// @description Elastic easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutElastic = function(progress) {
        if (progress == 0) return 0;
        if (progress == 1) return 1;
        // Note: 11.125 = (CASSETTE_ELASTIC_PERIOD2_DIV * 2 + 2.125) if needed, relates to phase shift
        return (progress < 0.5)
            ? -(power(2, 20 * progress - 10) * sin((20 * progress - 11.125) * CASSETTE_ELASTIC_C5)) / 2
            : (power(2, -20 * progress + 10) * sin((20 * progress - 11.125) * CASSETTE_ELASTIC_C5)) / 2 + 1;
    };

    // --- Back ---
    /// @function InBack(progress)
    /// @description Back easing in. Overshoots then settles.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InBack = function(progress) {
        return CASSETTE_BACK_C3 * progress * progress * progress - CASSETTE_BACK_C1 * progress * progress;
    };

    /// @function OutBack(progress)
    /// @description Back easing out. Overshoots then settles.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutBack = function(progress) {
        return 1 + CASSETTE_BACK_C3 * power(progress - 1, 3) + CASSETTE_BACK_C1 * power(progress - 1, 2);
    };

    /// @function InOutBack(progress)
    /// @description Back easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutBack = function(progress) {
        return (progress < 0.5)
            ? (power(2 * progress, 2) * ((CASSETTE_BACK_C2 + 1) * 2 * progress - CASSETTE_BACK_C2)) / 2
            : (power(2 * progress - 2, 2) * ((CASSETTE_BACK_C2 + 1) * (progress * 2 - 2) + CASSETTE_BACK_C2) + 2) / 2;
    };

    // --- Bounce ---
    /// @function OutBounce(progress)
    /// @description Bounce easing out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static OutBounce = function(progress) {
        if (progress < CASSETTE_BOUNCE_T1) { // < 1 / 2.75
            return CASSETTE_BOUNCE_N1 * progress * progress;
        } else if (progress < CASSETTE_BOUNCE_T2) { // < 2 / 2.75
            progress -= CASSETTE_BOUNCE_O1; // -= 1.5 / 2.75
            return CASSETTE_BOUNCE_N1 * progress * progress + CASSETTE_BOUNCE_A1; // + 0.75
        } else if (progress < CASSETTE_BOUNCE_T3) { // < 2.5 / 2.75
            progress -= CASSETTE_BOUNCE_O2; // -= 2.25 / 2.75
            return CASSETTE_BOUNCE_N1 * progress * progress + CASSETTE_BOUNCE_A2; // + 0.9375
        } else {
            progress -= CASSETTE_BOUNCE_O3; // -= 2.625 / 2.75
            return CASSETTE_BOUNCE_N1 * progress * progress + CASSETTE_BOUNCE_A3; // + 0.984375
        }
    };

    /// @function InBounce(progress)
    /// @description Bounce easing in.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InBounce = function(progress) {
        // Re-use OutBounce by inverting the progress
        // Need to call the OutBounce function associated *with this instance*
        return 1 - self.OutBounce(1 - progress);
    };

    /// @function InOutBounce(progress)
    /// @description Bounce easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutBounce = function(progress) {
        // Re-use OutBounce by inverting/scaling the progress
        // Need to call the OutBounce function associated *with this instance*
        return (progress < 0.5)
            ? (1 - self.OutBounce(1 - 2 * progress)) / 2
            : (1 + self.OutBounce(2 * progress - 1)) / 2;
    };
}

/// --- Experimental ---
/// @function derp(current, target, decay_rate)
/// @description A version of lerp that uses delta_time and pre-calculated decay rate.
/// @param {Real} current      The current value.
/// @param {Real} target       The target value.
/// @param {Real} decay_rate   The rate of decay (1 / half_life_seconds).
function derp(current, target, decay_rate) {
    var _delta_seconds = delta_time / 1000000;

    var _amount = 1 - power(0.5, _delta_seconds * decay_rate);

    return lerp(current, target, _amount);
}