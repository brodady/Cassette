// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_IsInfinite()
/// @desc    Checks if the mixtape or any of its items are set to loop indefinitely.
/// @return  {Bool}
/// @self __CassetteMixtape
function __CassetteMixtape_IsInfinite() {

    if (__loops < 0) return true;

    var _i = 0;
    repeat(array_length(__items)) {
        if (__items[_i].tape.isInfinite()) return true;
        _i++;
    }

    return false;
}
