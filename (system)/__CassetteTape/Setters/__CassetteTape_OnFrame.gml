// Feather ignore all
/// @ignore  (Internal) __CassetteTape_OnFrame(index, callback)
/// @desc    Sets a function to run at a specific time index (frame or second).
/// @param   {Real} index The time index (will be floored for lookup).
/// @param   {Function} callback The function to execute.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_OnFrame(_index, _func) {
    var _k = string(floor(_index));
    
    if (!variable_struct_exists(__frameEvents, _k)) {
        __frameEvents[$ _k] = [];
    }
    
    array_push(__frameEvents[$ _k], _func);
    
    return self;
}