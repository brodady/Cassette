/// @ignore (Internal) Lookup Helper
/// @param {Real} _id The integer ID
/// @self CassetteDeck
function __CassetteDeck_GetCore(_id) {
    if (_id < array_length(__tapesById)) {
         return __tapesById[_id];
    }
    return undefined;
};
