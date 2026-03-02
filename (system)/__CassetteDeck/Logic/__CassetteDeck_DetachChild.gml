// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_DetachChild(_tape)
/// @desc Removes the tape from the Deck's update loop but keeps it alive (for transfer).
/// @self CassetteDeck
function __CassetteDeck_DetachChild(_tape) {
    
    var _idx = array_get_index(__tapesList, _tape);
    if (_idx != -1) {
        var _lastIdx = array_length(__tapesList) - 1;
        if (_idx != _lastIdx) {
            __tapesList[_idx] = __tapesList[_lastIdx];
        }
        array_pop(__tapesList);
        
        if (!_tape.__paused) __playingCount--;
    }

    if (_tape.__key != undefined && variable_struct_exists(__tapesMap, _tape.__key)) {
        variable_struct_remove(__tapesMap, _tape.__key);
    }
}
