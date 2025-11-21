/// --- Cassette ---
// A simple yet powerful animation system with chainable transitions.
// Featuring a portable collection of easing functions in a handy literal syntax.
// -- by:   Mr. Giff
// -- ver:  2.0.0 -- Fluent Interface, Struct Tweening, Optimized Performance.
// -- lic:  MIT

// --- Playback speed (Internal use, don't touch this. Use the '.set_speed' method)
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
    Once,
    Loop, 
    PingPong
}

/// @function Cassette([use_delta_time], [auto_start], [default_lerp])
/// @description A centralized, self-contained class for chained, sequenced animations.
function Cassette(_use_delta_time = false, _auto_start = false, _default_lerp = lerp) constructor {
    
    active_transitions = {};
    use_delta_time = _use_delta_time;
    default_auto_start = _auto_start;
    default_lerp = _default_lerp;

    // --- Private Chain Builder ---
    function ChainBuilder(_manager_ref) constructor {
        manager = _manager_ref;
        queue = _manager_ref.queue;

        /// @function next([label])
        /// @desc Adds a new segment to the CURRENT sequence. 
        next = function(_label = undefined) {
            var _def = {
                label: _label, 
                from_val: 0, 
                to_val: 0, 
                duration: 1.0,
                CASSETTE_func: Cassette.InQuad, 
                is_curve: false, 
                anim_state: CASSETTE_ANIM.Once,
                loops_left: -1,
                on_track_end: undefined,
                is_wait: false
            };
            array_push(queue, _def);
            return self; 
        }
        
        /// @function wait(duration, [callback])
        /// @desc Adds a pause to the sequence.
        wait = function(_duration, _callback = undefined) {
            var _def = {
                is_wait: true,
                duration: _duration,
                anim_state: CASSETTE_ANIM.Once,
                loops_left: 1,
                on_track_end: _callback
            };
            array_push(queue, _def);
            return self;
        }

        // --- Setters ---

        /// @function from(value_or_struct)
        /// @desc Sets the start value. Can be a Real or a Struct (e.g. vector/style).
        from = function(_val) {
            var _last = array_last(queue);
            if (_last.is_wait) show_error("Cassette: Cannot set 'from' on a wait() command.", true);
            
            _last.from_val = _val;

            // Update manager immediately if this is the first track
            if (array_length(queue) == 1) {
                manager.current_val = _val;
            }
            return self;
        }

        /// @function to(value_or_struct)
        /// @desc Sets the end value. Must match the type of 'from' (Real or Struct).
        to = function(_val) {
            var _last = array_last(queue);
            if (_last.is_wait) show_error("Cassette: Cannot set 'to' on a wait() command.", true);
            _last.to_val = _val;
            return self;
        }

        /// @function duration(seconds_or_frames)
        /// @desc Sets the duration of the current track.
        duration = function(_val) {
            var _last = array_last(queue);
            _last.duration = _val;
            return self;
        }

        /// @function ease(function_or_curve)
        /// @desc Sets the easing function or Animation Curve struct.
        ease = function(_func) {
            var _last = array_last(queue);
            if (_last.is_wait) show_error("Cassette: Cannot set 'ease' on a wait() command.", true);

            _last.CASSETTE_func = _func;
            
            if (is_struct(_func) && variable_struct_exists(_func, "__is_anim_curve")) {
                _last.is_curve = true;
            } else {
                _last.is_curve = false;
            }
            return self;
        }

        /// @function loop([times])
        /// @desc Repeats THIS track. Empty or -1 = Infinite. 1 = Play + Repeat once.
        loop = function(_times = -1) {
            var _last = array_last(queue);
            if (_last.is_wait) show_error("Cassette: Cannot set 'loop' on a wait() command.", true);
            
            _last.anim_state = CASSETTE_ANIM.Loop;
            
            // Convert "Repeats" to "Total Plays"
            if (_times != -1) _times += 1; 
            
            _last.loops_left = _times;

            if (array_length(queue) == 1) manager.loops_left = _times;

            return self;
        }

        /// @function pingpong([times])
        /// @desc PingPongs THIS track. Empty or -1 = Infinite. 1 = There and Back (1 cycle).
        pingpong = function(_times = -1) {
            var _last = array_last(queue);
            if (_last.is_wait) show_error("Cassette: Cannot set 'pingpong' on a wait() command.", true);
            
            _last.anim_state = CASSETTE_ANIM.PingPong;
            _last.loops_left = _times;
            
            if (array_length(queue) == 1) manager.loops_left = _times;
            
            return self;
        }
        
        /// @function on_end(callback)
        /// @desc Callback for when THIS specific track ends.
        on_end = function(_func) {
            var _last = array_last(queue);
            _last.on_track_end = _func;
            return self;
        }

        /// @function on_sequence_end(callback)
        /// @desc Callback for when the ENTIRE chain finishes.
        on_sequence_end = function(_func) {
            manager.on_sequence_end = _func;
            return self;
        }
    }
    
    // --- Public Methods ---
    
    /// @function transition(key, [custom_lerp])
    /// @description Starts a new transition sequence and returns a ChainBuilder.
    transition = function(_key, _lerp_func = default_lerp) {
        
        // Create the first "Default" definition to initialize the queue
        var _first_def = {
            label: "Start",
            from_val: 0, to_val: 0, duration: 1.0, 
            CASSETTE_func: Cassette.InQuad, 
            is_curve: false,
            anim_state: CASSETTE_ANIM.Once, loops_left: -1,
            on_track_end: undefined,
            is_wait: false
        };
        
        var _manager = { 
            queue: [_first_def],
            current_index: 0,
            lerp_func: _lerp_func, 
            on_sequence_end: undefined,
            
            // State
            current_val: 0, // Overwritten by .from()
            timer: 0,
            direction: 1,
            loops_left: 1,
            is_paused: !default_auto_start,
            playback_speed: CASSETTE_DEFAULT_PLAYBACK_SPEED, 
        };
        
        active_transitions[$ _key] = _manager;
        
        return new ChainBuilder(_manager); 
    }
    
    /// @function update()
    /// @description Updates all active transitions. Call this in the Step Event.
    update = function() {
        var _completed_keys = [];
        var _keys = variable_struct_get_names(active_transitions);
        
        var i = 0; repeat(array_length(_keys)) {
            var _key = _keys[i];
            i++;
            
            var _manager = active_transitions[$ _key];
            if (_manager.is_paused) continue; 
            
            var _current_def = _manager.queue[_manager.current_index];
            
            // --- 1. Handle Time ---
            var _dt_multiplier = (use_delta_time) ? (delta_time / 1000000) : 1;
            var _time_step = _dt_multiplier * abs(_manager.playback_speed);
            
            _manager.timer += _time_step * (sign(_manager.playback_speed) * _manager.direction);

            // --- 2. Handle Wait ---
            if (_current_def.is_wait) {
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

            // --- 3. Handle Animation ---
            _evaluate_and_set_value(_manager);
            
            // --- 4. Handle Completion (Boundaries) ---
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            
            // FORWARD BOUNDARY
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
                else { // Once
                    _move_to_next_track(_manager, _key, _completed_keys, _overflow);
                }
            }
            // BACKWARD BOUNDARY
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
                else { // Once
                     _handle_backward_completion(_manager, _key, _underflow);
                }
            }
        }
        
        // Clean up completed
        var c = 0; repeat(array_length(_completed_keys)) {
            variable_struct_remove(active_transitions, _completed_keys[c]);
            c++;
        }
    }

    // --- Player Controls ---

    /// @function play([keys])
    /// @desc Resumes one or all active transitions.
    play = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_m) { _m.is_paused = false; });
    }

    /// @function pause([keys])
    /// @desc Pauses one or all active transitions.
    pause = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_m) { _m.is_paused = true; });
    }

    /// @function stop([keys], [trigger_callback])
    /// @desc Stops one or all active transitions and removes them.
    stop = function(_keys = undefined, _trigger_end_callback = true) {
        _apply_to_managers(_keys, function(_manager, _do_callback, _key) {
            if (_do_callback && is_method(_manager.on_sequence_end)) {
                _manager.on_sequence_end();
            }
            variable_struct_remove(active_transitions, _key);
        }, _trigger_end_callback);
    }

    /// @function ffwd([keys])
    ffwd = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            _manager.current_index = array_length(_manager.queue) - 1;
            var _last_def = _manager.queue[_manager.current_index];
            
            _manager.timer = _last_def.duration;
            _manager.direction = 1;
            _manager.loops_left = 0;
            
            if (!_last_def.is_wait) _manager.current_val = _last_def.to_val;
            
            if (is_method(_manager.on_sequence_end)) _manager.on_sequence_end();
            variable_struct_remove(active_transitions, _key);
        });
    }

    /// @function rewind([keys])
    rewind = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager) {
            _init_track(_manager, 0); 
            if (!default_auto_start) _manager.is_paused = true;
        });
    }

     /// @function seek(amount, [keys])
    seek = function(_amount, _keys = undefined) {
        _apply_to_managers(_keys, _seek_manager, _amount);
    }

    /// @function skip([keys])
    skip = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager, _data, _key) {
            if (_manager.current_index + 1 < array_length(_manager.queue)) {
                _init_track(_manager, _manager.current_index + 1);
            } else {
                var _last_index = array_length(_manager.queue) - 1;
                var _last_def = _manager.queue[_last_index];
                _init_track(_manager, _last_index, _last_def.duration); 
                if (is_method(_manager.on_sequence_end)) _manager.on_sequence_end();
                variable_struct_remove(active_transitions, _key);
            }
        });
    }

    /// @function back([keys])
    back = function(_keys = undefined) {
        _apply_to_managers(_keys, function(_manager) {
            if (_manager.current_index > 0) _init_track(_manager, _manager.current_index - 1);
            else _init_track(_manager, 0);
        });
    }
    
    /// @function get_speed(key)
    get_speed = function(_key) {
        if (variable_struct_exists(active_transitions, _key)) return active_transitions[$ _key].playback_speed;
        return undefined;
    }
    
    /// @function set_speed(speed, [keys])
    set_speed = function(_speed, _keys = undefined) {
        _apply_to_managers(_keys, function(_m, _s) { _m.playback_speed = _s; }, _speed);
    }

    /// @function clear_all()
    clear_all = function() {
        active_transitions = {};
    }

    /// @function get_value(key, default_val)
    get_value = function(_key, _default_val) {
        if (variable_struct_exists(active_transitions, _key)) return active_transitions[$ _key].current_val;
        return _default_val;
    }
    
    /// @function is_active([key])
    is_active = function(_key = undefined) {
        if (_key != undefined) {
            return variable_struct_exists(active_transitions, _key);
        }
        var _names = variable_struct_get_names(active_transitions);
        return (array_length(_names) > 0);
    }
    
    /// @function is_paused([key])
    is_paused = function(_key = undefined) {
        if (_key != undefined) {
            if (variable_struct_exists(active_transitions, _key)) {
                return active_transitions[$ _key].is_paused;
            }
            return undefined;
        }
        
        var _keys = variable_struct_get_names(active_transitions);
        if (array_length(_keys) == 0) return false; 
        
        var i = 0; repeat(array_length(_keys)) {
            var _m = active_transitions[$ _keys[i]];
            if (!_m.is_paused) return false; 
            i++;
        }
        return true;
    }

    /// @function custom(curve_asset_or_struct, [channel_index])
    custom = function(_curve_asset_or_struct, _channel_index = 0) {
        var _curve_struct = _curve_asset_or_struct;
        if (!is_struct(_curve_struct)) _curve_struct = animcurve_get(_curve_asset_or_struct);
        if (!is_struct(_curve_struct) || !variable_struct_exists(_curve_struct, "channels")) return undefined;
        if (_channel_index >= array_length(_curve_struct.channels)) return undefined;
        
        return {
            __is_anim_curve: true,
            channel: _curve_struct.channels[_channel_index]
        };
    }

    // --- Private Helpers ---

    /// @desc (Internal) Interpolates Reals or Structs.
    _calculate_current_value = function(_from, _to, _progress, _lerp_func) {
        if (is_struct(_from)) {
            var _result = {};
            var _keys = variable_struct_get_names(_to);
            var i = 0; repeat(array_length(_keys)) {
                var _k = _keys[i];
                _result[$ _k] = _lerp_func(_from[$ _k], _to[$ _k], _progress);
                i++;
            }
            return _result;
        } else {
            return _lerp_func(_from, _to, _progress);
        }
    }

    /// @desc (Internal) Calculates and sets the current value based on time/queue.
    _evaluate_and_set_value = function(_manager) {
        var _def = _manager.queue[_manager.current_index];
        if (_def.is_wait) return;

        var _progress = (_def.duration <= 0) ? 1 : clamp(_manager.timer / _def.duration, 0, 1);
        var _eased = 0;
        
        if (_def.is_curve) _eased = animcurve_channel_evaluate(_def.CASSETTE_func.channel, _progress);
        else _eased = _def.CASSETTE_func(_progress);

        _manager.current_val = _calculate_current_value(_def.from_val, _def.to_val, _eased, _manager.lerp_func);
    }

    /// @desc (Internal) Sets a manager's state to a specific track index.
    _init_track = function(_manager, _index, _timer = 0, _start_dir = 1) {
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

    /// @desc (Internal) Advances a manager to next track.
    _move_to_next_track = function(_manager, _key_for_completion, _completed_keys_ref, _overflow = 0) {
        var _current_def = _manager.queue[_manager.current_index];
        if (is_method(_current_def.on_track_end)) _current_def.on_track_end();

        if (_manager.current_index + 1 < array_length(_manager.queue)) {
            _init_track(_manager, _manager.current_index + 1, _overflow, 1);
        } else {
            if (is_method(_manager.on_sequence_end)) _manager.on_sequence_end();
            array_push(_completed_keys_ref, _key_for_completion);
        }
    };

    /// @desc (Internal) Moves a manager backward.
    _handle_backward_completion = function(_manager, _key_for_completion, _underflow) {
        if (_manager.current_index > 0) {
            _init_track(_manager, _manager.current_index - 1, _underflow, -1);
        } else {
            _manager.timer = 0;
            _manager.direction = 1;
        }
    };

    /// @desc (Internal) Apply function to managers.
    _apply_to_managers = function(_target_keys, _action_func, _data = undefined) {
        if (_target_keys == undefined) {
            var _keys = variable_struct_get_names(active_transitions);
            var i = 0; repeat(array_length(_keys)) {
                var _k = _keys[i];
                if (variable_struct_exists(active_transitions, _k)) _action_func(active_transitions[$ _k], _data, _k); 
                i++;
            }
        } else if (is_array(_target_keys)) {
            var i = 0; repeat(array_length(_target_keys)) {
                var _k = _target_keys[i];
                if (variable_struct_exists(active_transitions, _k)) _action_func(active_transitions[$ _k], _data, _k);
                i++;
            }
        } else if (is_string(_target_keys)) {
            if (variable_struct_exists(active_transitions, _target_keys)) _action_func(active_transitions[$ _target_keys], _data, _target_keys); 
        }
    }

    /// @desc (Internal) The core logic for seeking.
    _seek_manager = function(_manager, _seek_amount, _key) { 
        _manager.timer += _seek_amount;
        
        var _chain_is_finished = false;
        var _current_def = _manager.queue[_manager.current_index];
        
        // --- Forward Overflow ---
        while (_manager.timer > _current_def.duration) {
            var _overflow_time = _manager.timer - _current_def.duration;
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            var _duration = _current_def.duration;

            if ((_is_looping || _is_pingpong) && _manager.loops_left != 0) {
                if (_duration <= 0) { _manager.timer = 0; _manager.direction = 1; break; }
                if (_is_looping) {
                    _manager.timer = _manager.timer % _duration;
                    _manager.direction = 1;
                } else { 
                    var _total_loop_duration = _duration * 2;
                    var _wrapped_time = _manager.timer % _total_loop_duration;
                    if (_wrapped_time > _duration) {
                        _manager.timer = _duration - (_wrapped_time - _duration);
                        _manager.direction = -1;
                    } else {
                        _manager.timer = _wrapped_time;
                        _manager.direction = 1;
                    }
                }
                break; 
            }
            
            if (_manager.current_index + 1 < array_length(_manager.queue)) {
                _init_track(_manager, _manager.current_index + 1, _overflow_time, 1);
                _current_def = _manager.queue[_manager.current_index];
            } else {
                _manager.timer = _current_def.duration; 
                _manager.direction = 1; 
                _chain_is_finished = true; 
                break; 
            }
        }

        // --- Backward Underflow ---
        while (_manager.timer < 0) {
            var _underflow_time = _manager.timer;
            var _is_looping = _current_def.anim_state == CASSETTE_ANIM.Loop;
            var _is_pingpong = _current_def.anim_state == CASSETTE_ANIM.PingPong;
            var _duration = _current_def.duration;

            if ((_is_looping || _is_pingpong) && _manager.loops_left != 0) {
                if (_duration <= 0) { _manager.timer = 0; _manager.direction = 1; break; }
                if (_is_looping) {
                    _manager.timer = _manager.timer % _duration;
                    _manager.direction = 1;
                } else { 
                    var _total_loop_duration = _duration * 2;
                    var _wrapped_time = _manager.timer % _total_loop_duration;
                    if (_wrapped_time > _duration) {
                        _manager.timer = _duration - (_wrapped_time - _duration);
                        _manager.direction = -1;
                    } else {
                        _manager.timer = _wrapped_time;
                        _manager.direction = 1;
                    }
                }
                break; 
            }
            
            if (_manager.current_index > 0) {
                _init_track(_manager, _manager.current_index - 1, _underflow_time, -1);
                _current_def = _manager.queue[_manager.current_index];
            } else {
                _manager.timer = 0; 
                _manager.direction = 1; 
                break;
            }
        }
        
        if (_chain_is_finished) {
             _evaluate_and_set_value(_manager); 
             _manager.is_paused = true; 
             return; 
        }
        _evaluate_and_set_value(_manager);
    }

    // --- Easing Library --

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
        return 1 - Cassette.OutBounce(1 - progress);
    };

    /// @function InOutBounce(progress)
    /// @description Bounce easing in and out.
    /// @param {real} progress The normalized progress of the tween (0 to 1).
    static InOutBounce = function(progress) {
        // Re-use OutBounce by inverting/scaling the progress
        // Need to call the OutBounce function associated *with this instance*
        return (progress < 0.5)
            ? (1 - Cassette.OutBounce(1 - 2 * progress)) / 2
            : (1 + Cassette.OutBounce(2 * progress - 1)) / 2;
    };
}

/// --- Experimental ---
/// @function derp(current, target, decay_rate)
/// @description A version of lerp that uses delta_time and pre-calculated decay rate.
/// @param {Real} current The current value.
/// @param {Real} target The target value.
/// @param {Real} decay_rate The rate of decay (1 / half_life_seconds).
function derp(current, target, decay_rate) {
    var _delta_seconds = delta_time / 1000000;
    var _amount = 1 - power(0.5, _delta_seconds * decay_rate);
    return lerp(current, target, _amount);
}