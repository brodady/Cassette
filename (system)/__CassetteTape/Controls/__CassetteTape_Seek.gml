// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Seek(amount)
/// @desc    Moves playback (frames/seconds). Handles looping/pingpong math and boundary overflow iteratively.
/// @param   {Real} amount The amount to move the timer (frames or seconds).
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Seek(_amount) {

    var _amt = __Cassette_ResolveValue(_amount);

    var _processSeek = true;
    var _iterations = 0;

    while (_processSeek) {
        _iterations++;

        if (_iterations > __CASSETTE_SEEK_LIMIT) {
            show_debug_message("CASSETTE ERROR: Seek recursion limit reached.");
            break;
        }

        var _track = __tracks[__trackIndex];
        var _trackLoops = __Cassette_ResolveValue(__trackLoops);
        var _tapeLoops = __Cassette_ResolveValue(__loops);

        #region Most-common case (In-bounds)
        if (!__finished && _trackLoops == 0) {
            var _newTime = __timer + (_amt * __direction);

            if (_newTime >= 0 && _newTime <= _track.duration) {
                __timer = _newTime;
                __CassetteTape_Calculate(__timer);
                return self;
            }
        }
        #endregion

        #region Full boundary resolution
        if (__finished && _amt * __direction > 0) return self;

        if (__finished) {
            __finished = false;
            __active = true;
            __paused = false;
        }

        __timer += _amt * __direction;

        var _dur = _track.duration; // Duration is resolved in Calculate
        var _limit = -1;
        
        if (_trackLoops >= 0) {
            _limit = _dur * (1 + _trackLoops);
        }

        // Seek Forward (Overflow)
        if (_limit != -1 && __timer >= _limit) {
            var _idle = (__timer == _limit && __direction == -1);

            if (!_idle) {
                __CassetteTape_HandleCallback(_track.onTrackEnd);
                __CassetteTape_HandleCallback(__onAnyTrackEnd);

                var _overflow = __timer - _limit;

                if (__trackIndex < array_length(__tracks) - 1) {
                    __trackIndex++;
                    __CASSETTE_RESET_TRACK;
                    __timer = _overflow; 
                    __direction = 1;
                    _amt = 0; 
                    continue;
                } else {
                    if (_tapeLoops != 0) {
                        if (_tapeLoops > 0) {
                            _tapeLoops--;
                            __loops = _tapeLoops;
                        }

                        if (__type == __CASSETTE_ANIM.PING_PONG) {
                            __timer = _limit - _overflow;
                            __direction *= -1;
                            _amt = 0;
                            continue;
                        } else {
                            rewind();
                            return self;
                        }
                    }

                    __timer = _limit;
                    if (!__paused && __deck != undefined) __deck.__playingCount--;
                    __finished = true;
                    __paused = true;

                    var _endAtStart = (_track.type == __CASSETTE_ANIM.PING_PONG && (_tapeLoops % 2 != 0));
                    var _finalVal = _endAtStart ? _track.fromVal : _track.toVal;

                    if (!_track.isWait) __CassetteTape_UpdateValue(_finalVal);

                    __CassetteTape_HandleCallback(__onUpdate);
                    __CassetteTape_HandleCallback(__onEnd);

                    return self;
                }
            }
        }
        // Seek Backward (Underflow)
        else if (__timer < 0) {
            if (__trackIndex > 0) {
                var _oldDir = __direction;
                var _underflow = __timer;

                __trackIndex--;
                __CASSETTE_RESET_TRACK;

                var _prevDur = __tracks[__trackIndex].duration;
                var _prevLoopsRaw = __tracks[__trackIndex].loops;
                var _prevLoops = __Cassette_ResolveValue(_prevLoopsRaw);
                var _prevLimit = (_prevLoops >= 0) ? _prevDur * (1 + _prevLoops) : _prevDur;

                __timer = _prevLimit + _underflow;
                __direction = _oldDir;
                _amt = 0;

                continue;
            } else {
                if (_tapeLoops != 0) {
                    if (_tapeLoops > 0) _tapeLoops--;

                    if (__type == __CASSETTE_ANIM.PING_PONG) {
                        __timer = abs(__timer);
                        __direction *= -1;
                        _amt = 0;
                        continue;
                    }

                    __trackIndex = array_length(__tracks) - 1;
                    
                    var _t = __tracks[__trackIndex];
                    __trackLoops = __Cassette_ResolveValue(_t.loops);
                    __direction = 1;
                    
                    var _endLimit = (_t.loops >= 0) ? _t.duration * (1 + _t.loops) : _t.duration;

                    __timer = _endLimit + __timer;
                    _amt = 0;
                    continue;
                }

                __timer = 0;
                __direction = 1;
                __finished = false;
                __CassetteTape_Calculate(0);
            }
        }

        _processSeek = false;
        #endregion
    }

    var _finalTrack = __tracks[__trackIndex];
    var _finalDur = __Cassette_ResolveValue(_finalTrack.duration);

    if (!__finished) {
        var _visualTime = __timer;

        if (_finalTrack.type == __CASSETTE_ANIM.LOOP) {
            if (_finalDur > 0) _visualTime = __timer % _finalDur;
        }
        else if (_finalTrack.type == __CASSETTE_ANIM.PING_PONG) {
            if (_finalDur > 0) {
                var _cycle = _finalDur * 2;
                var _tInCycle = __timer % _cycle;

                if (_tInCycle > _finalDur) {
                    _visualTime = _finalDur - (_tInCycle - _finalDur);
                } else {
                    _visualTime = _tInCycle;
                }
            }
        }

        _visualTime = clamp(_visualTime, 0, _finalDur);
        __CassetteTape_Calculate(_visualTime);
    }

    return self;
}