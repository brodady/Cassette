// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Jump(key)
/// @desc    Jumps the timeline to the start of a specific item identified by its key.
/// @param   {String} key The key of the tape/mixtape to jump to.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Jump(_key) {
    var _i = 0;
    repeat(array_length(__items)) {
        var _item = __items[_i];

        if (variable_struct_exists(_item.tape, "__key") && _item.tape.__key == _key) {
            var _targetTime = _item.start;
            var _seekAmount = _targetTime - __timer;

            __CassetteMixtape_Seek(_seekAmount);

            return self;
        }
        _i++;
    }
    
    show_debug_message("CASSETTE WARNING: Jump target '" + string(_key) + "' not found in Mixtape.");
    return self;
}
