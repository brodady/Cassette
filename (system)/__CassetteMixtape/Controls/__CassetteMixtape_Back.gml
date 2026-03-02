// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Back()
/// @desc    Jumps to the start of the current or previous item.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Back() {
    var _prevTime = 0;
    var _targetTime = 0;
    var _found = false;

    var _i = 0; 
    repeat(array_length(__items)) {
        var _item = __items[_i];

        if (__timer >= _item.start && __timer <= _item.finish) {
            if (__timer > _item.start + __CASSETTE_REWIND_THRESHOLD) {
                _targetTime = _item.start;
            } else {
                _targetTime = _prevTime;
            }
            _found = true;
            break;
        }
        
        else if (__timer < _item.start) {
            _targetTime = _prevTime;
            _found = true;
            break;
        }
        
        _prevTime = _item.start;
        _i++;
    }
    
    if (!_found && array_length(__items) > 0) {
        _targetTime = array_last(__items).start;
    }

    __timer = 0; 
    __CassetteMixtape_Seek(_targetTime);
    
    return self;
}
