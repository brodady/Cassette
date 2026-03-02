// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_RemoveChild(_tape) Releases a tape from this mixtape, destroying/pooling it
/// @self __CassetteMixtape
function __CassetteMixtape_RemoveChild(_tape) {
    // Search and destroy in the items array
    for (var _i = 0; _i < array_length(__items); _i++) {
        if (__items[_i].tape == _tape) {
            array_delete(__items, _i, 1);

            if (variable_struct_exists(_tape, "reset") && __deck != undefined) {
                 array_push(__deck.__pool, _tape);
            }
            
            _tape.__active = false;
            return;
        }
    }
}
