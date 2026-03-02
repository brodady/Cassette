// Feather ignore all
/// @ignore  (Internal) Update all tapes in this mix
/// @self __CassetteMixtape
function __CassetteMixtape_Step(_dt) {
    if (__paused) return;

    if (__direction == 1 && __currentDelay < __startDelay) {
        __currentDelay += _dt;
        return;
    }

    var _len = array_length(__items);
    var _targetTime = __timer + (_dt * __direction);
    var _blocked = false;

    #region Check Blocking Items
    var _k = 0;
    repeat(_len) {
        var _it = __items[_k];

        if (_it.started && _it.tape.isInfinite() && _it.block) {
            if (__direction == 1 && _targetTime >= _it.finish) {
                _targetTime = _it.finish;
                _blocked = true;
            }
        }
        _k++;
    }
    #endregion

    #region Handle Boundaries
    var _didLoop = false;
    
    if (!_blocked) {
        if (_targetTime >= __duration && __direction == 1) {
            if (__type == __CASSETTE_ANIM.LOOP && __loops != 0) {
                _targetTime = 0;
                if (__loops > 0) __loops--;
                _didLoop = true;
            } 
            else if (__type == __CASSETTE_ANIM.PING_PONG && __loops != 0) {
                _targetTime = __duration;
                __direction = -1;    
                if (__loops > 0) __loops--;
            } 
            else {
                _targetTime = __duration;
                ffwd(); 
                return;
            }
        }
        else if (_targetTime <= 0 && __direction == -1) {
            if (__type == __CASSETTE_ANIM.PING_PONG && __loops != 0) {
                _targetTime = 0;
                __direction = 1;  
                if (__loops > 0) __loops--;
            } else {
                 rewind();
                 return;
            }
        }
    }

    __timer = _targetTime;

    if (_didLoop) {
        _k = 0;
        repeat(_len) {
            var _it = __items[_k];
            _it.started = false;
            _it.tape.stop(); 
            _it.tape.rewind();
            _k++;
        }
    }
    #endregion

    #region Update Items
    var _i = 0;
    repeat(_len) {
        var _item = __items[_i];
        var _inRange = (__timer >= _item.start && __timer < _item.finish);

        if (_item.tape.isInfinite() && __timer == _item.finish && _blocked) {
            _inRange = true;
        }

        if (_inRange) {
            if (!_item.started) {
                _item.started = true;
                _item.tape.__active = true;
                _item.tape.__paused = false;
            }

            if (!_item.tape.__paused) {

                if (_item.tape.isInfinite()) {
                    var _stepDelta = (_dt * __direction) * _item.speed;
                    _item.tape.seek(_stepDelta);
                }
                else {
                    // If this was paused, _syncDelta might grow large.
                    // When unpaused, it will "Snap" to the timeline.
                    var _targetLocalTime = (__timer - _item.start) * _item.speed;
                    var _syncDelta = _targetLocalTime - _item.tape.__timer;

                    if (abs(_syncDelta) > 0.0001) {
                        _item.tape.seek(_syncDelta);
                    }
                }
            }
        } 
        else {
            if (_item.started) {
                _item.started = false;

                if (__timer >= _item.finish) {
                    _item.tape.ffwd();
                } 
                else if (__timer < _item.start) {
                    _item.tape.rewind();
                    _item.tape.stop();
                }
            }
        }
        _i++;
    }
    #endregion
}