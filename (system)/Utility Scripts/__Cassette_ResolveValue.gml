// Feather ignore all
/// @ignore (Internal) __Cassette_ResolveValue(value)
/// @desc Recursively resolves a value that might be wrapped in a struct or method (Dynamic Binding).
function __Cassette_ResolveValue(_val) {
    if (is_method(_val)) {
        return __Cassette_ResolveValue(_val());
    }

    if (is_struct(_val)) {
        var _names = variable_struct_get_names(_val);
        if (array_length(_names) > 0) {
            return __Cassette_ResolveValue(_val[$ _names[0]]);
        }
    }

    return _val;
}