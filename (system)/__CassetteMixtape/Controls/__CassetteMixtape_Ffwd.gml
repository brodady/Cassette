// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Ffwd()
/// @desc    Jumps the timeline to the end and forces all children to their end state.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Ffwd() { 
    
    __timer = __duration;

    var _i = 0; repeat(array_length(__items)) {
        var _item = __items[_i];
        _item.tape.ffwd();
        _item.started = false;
        _i++;
    }
    
    pause();
    
    return self;
}
