// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_RemoveChild Releases ownership of a tape
/// @self CassetteDeck
function __CassetteDeck_RemoveChild(_tape) {
    // Remove from active update list
    var _idx = array_get_index(__tapesList, _tape);
    if (_idx != -1) {
        var _lastIdx = array_length(__tapesList) - 1;
        if (_idx != _lastIdx) {
            __tapesList[_idx] = __tapesList[_lastIdx];
        }
        array_pop(__tapesList);
    }

    if (_tape.__key != undefined && variable_struct_exists(__tapesMap, _tape.__key)) {
        variable_struct_remove(__tapesMap, _tape.__key);
    }

    // Remove from Array & Recycle
    if (_tape.__id < array_length(__tapesById)) {
        if (__tapesById[_tape.__id] != undefined) {
             __tapesById[_tape.__id] = undefined;
             array_push(__freeIds, _tape.__id); 
        }
    }

    if (variable_struct_exists(_tape, "reset")) array_push(__pool, _tape);
    
    _tape.__active = false;
}
