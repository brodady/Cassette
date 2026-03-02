// Feather ignore all
/// @ignore  (Internal) Main update loop for CassetteDeck.
// Handles Delta Time, updates data, counters, and pools unused tapes.
function __CassetteDeck_Step() {
    // Time
    var _dt;
    if (__useSeconds) {
        var _usPerFrame = game_get_speed(gamespeed_microseconds);
        if (delta_time > 10 * _usPerFrame) {
            _dt = (_usPerFrame / 1000000) * __timeScale;
        } else {
            _dt = (clamp(delta_time, _usPerFrame / 3, 3 * _usPerFrame) / 1000000) * __timeScale;
        }
    } else {
        _dt = 1 * __timeScale;
    }
    
    // Clean up
    for (var _i = array_length(__tapesList) - 1; _i >= 0; _i--) {
        var _tape = __tapesList[_i];
        // If the tape is owned by a Mixtape, skip the update
        // but keep it in the list for Garbage Collection and Resolve/Tag access.
        if (_tape.__active && !_tape.__paused) {
            if (_tape.__parent == self) {
                _tape.step(_dt);
            }
        }
        
        if (!_tape.__active) {

            if (!_tape.__paused) __playingCount--;
            if (_tape.__key != undefined && variable_struct_exists(__tapesMap, _tape.__key) && __tapesMap[$ _tape.__key] == _tape) {
                variable_struct_remove(__tapesMap, _tape.__key);
            }

            if (_tape.__id < array_length(__tapesById)) {
                if (__tapesById[_tape.__id] != undefined) {
                    __tapesById[_tape.__id] = undefined;
                    array_push(__freeIds, _tape.__id);
                }
            }

            if (variable_struct_exists(_tape, "reset")) {
                array_push(__pool, _tape);
            }

            var _lastIdx = array_length(__tapesList) - 1;
            if (_i != _lastIdx) {
                __tapesList[_i] = __tapesList[_lastIdx];
            }
            array_pop(__tapesList);
        }
    }
}