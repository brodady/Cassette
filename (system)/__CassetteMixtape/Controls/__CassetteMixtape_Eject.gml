// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Eject()
/// @desc    Marks the Mixtape for removal and cleans up all children.
/// @return  {Undefined}
/// @self __CassetteMixtape
function __CassetteMixtape_Eject() { 
    __active = false;
    if (__parent != undefined && variable_struct_exists(__parent, "__RemoveChild")) {
        __parent.__RemoveChild(self);
    }

    var _i = 0;
    repeat(array_length(__items)) {
        var _t = __items[_i].tape;
        _t.__active = false; 

        if (variable_struct_exists(_t, "__deck") && _t.__deck != undefined) {
            var _d = _t.__deck;
            if (!_t.__paused) _d.__playingCount--;

            if (_t.__key != undefined && variable_struct_exists(_d.__tapesMap, _t.__key)) {
                variable_struct_remove(_d.__tapesMap, _t.__key);
            }

            if (variable_struct_exists(_d, "__tapesById") && _t.__id < array_length(_d.__tapesById)) {
                _d.__tapesById[_t.__id] = undefined;
            }
            
            if (variable_struct_exists(_t, "reset")) {
                array_push(_d.__pool, _t);
            }
        }
        _i++;
    }
    
    __items = [];
}
