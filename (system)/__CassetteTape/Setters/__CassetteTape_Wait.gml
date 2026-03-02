// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Wait(duration)
/// @desc    Adds a pause to the sequence.
/// @param   {Real|Struct} duration The duration to wait (frames or seconds).
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Wait(_dur) {
    self.next();
    var _t = array_last(__tracks);
    _t.isWait = true;

    if (__copyStructs && is_struct(_dur)) {
        _t.duration = variable_clone(_dur);
    }
    else {
        _t.duration = _dur;
    }
    
    return self;
}