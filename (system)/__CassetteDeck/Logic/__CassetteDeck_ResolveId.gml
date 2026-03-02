// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_ResolveId
/// @self CassetteDeck
function __CassetteDeck_ResolveId(_val) {
    return is_struct(_val) ? _val.__id : _val;
}
