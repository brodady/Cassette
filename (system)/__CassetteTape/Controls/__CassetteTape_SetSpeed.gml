// Feather ignore all
/// @ignore  (Internal) __CassetteTape_SetSpeed(multiplier)
/// @desc    Sets the playback speed multiplier.
/// @param   {Real} multiplier 1.0 is normal speed.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_SetSpeed(_mult) { 
    __speed = _mult; 
    return self; 
}
