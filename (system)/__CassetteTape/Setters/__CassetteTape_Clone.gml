/// @ignore  (Internal) __CassetteTape_Clone()
/// @desc    Enables struct cloning (Safe Mode).
///          Use this if you want the animation to return a NEW struct 
///          instead of modifying the original (Must be called FIRST after insert() before '.from').
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Clone() {
    __copyStructs = true;
    return self;
}
