// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Skip()
/// @desc    Jumps to the start of the next item in the timeline, escaping any active loops.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Skip() {
    var _nextTime = __duration;
    var _found = false;

    var _i = 0; repeat(array_length(__items)) {
        var _item = __items[_i];
        
        if (_item.started) {
            _item.tape.stop();
            _item.started = false; 
        }

        if (_item.start > __timer + __CASSETTE_EPSILON) { 
            _nextTime = _item.start;
            _found = true;
            break;
        }
        _i++;
    }
 
    if (!_found) _nextTime = __duration;

    __CassetteMixtape_Seek(_nextTime - __timer);
    return self;
}
