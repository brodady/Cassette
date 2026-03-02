// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Seek(amount)
/// @desc Moves the timeline playhead and syncs all children to the new time.
/// @param {Real} _amount The time to seek by.
/// @self __CassetteMixtape
function __CassetteMixtape_Seek(_amount) {
    __timer += _amount;
    __timer = clamp(__timer, 0, __duration);

    var _i = 0; repeat(array_length(__items)) {
        var _item = __items[_i];
        var _targetTime = __timer - _item.start;
        var _itemDur    = _item.finish - _item.start;

        if (_targetTime <= 0) {
            if (_item.started || _item.tape.__timer > 0) {
                 _item.tape.rewind();
                 _item.tape.stop();
                 _item.started = false;
            }
        } 
        else if (_targetTime >= _itemDur) {
            if (!_item.tape.__finished) {
                 _item.tape.ffwd();
                 _item.started = false;
            }
        } 
        else {
            _item.tape.rewind();
            _item.tape.seek(_targetTime);
            
            _item.started = true;
            _item.tape.__paused = __paused;
            _item.tape.__active = true;
        }
        _i++;
    }

    return self;
}
