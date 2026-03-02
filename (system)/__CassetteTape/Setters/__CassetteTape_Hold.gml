// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Hold()
/// @desc    Sets the current track to hold indefinitely at the start/end bounds.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Hold() { 
    array_last(__tracks).type = __CASSETTE_ANIM.HOLD; 
    return self; 
}
