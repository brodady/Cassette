// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_DetachChild Releases a tape from this mixtape without destroying/pooling it.
/// @self __CassetteMixtape
function __CassetteMixtape_DetachChild(_tape) {
    // Find the item wrapper for this tape and remove it
    for (var _i = 0; _i < array_length(__items); _i++) {
        if (__items[_i].tape == _tape) {
            array_delete(__items, _i, 1);
            return;
        }
    }
}
