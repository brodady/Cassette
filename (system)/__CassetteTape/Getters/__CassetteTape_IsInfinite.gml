// Feather ignore all
/// @ignore  (Internal) __CassetteTape_IsInfinite()
/// @desc    Checks if the tape or any of its tracks are set to loop indefinitely.
/// @return  {Bool}
/// @self __CassetteTape
function __CassetteTape_IsInfinite() {

    if (__loops < 0) return true;
    
    var _i = 0; repeat(array_length(__tracks)) {
        if (__tracks[_i].loops < 0) return true;
        _i++;
    }
    
    return false;
}
