// Feather ignore all
/// @ignore  (Internal) destroy()
/// @desc Must run in a cleanup or game-end event to prevent memory leaks!
/// @self CassetteDeck
function __CassetteDeck_Destroy() { 
    time_source_destroy(__timeSource);
    __tapesList = [];
    __tapesMap = {};
    __tapesById = [];
    __pool = [];
    __freeIds = [];
};
