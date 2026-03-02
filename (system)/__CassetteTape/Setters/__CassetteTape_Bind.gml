// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Bind(_inst) Sets the target object to apply values to.
///          Overrides the default behavior of modifying the input struct directly.
/// @desc    Sets the target object and creates a weak reference for safe tracking.
/// @param   {Struct|Asset.GMObject} _inst instance to bind properties to.
/// @self __CassetteTape
function __CassetteTape_Bind(_inst) {
    var _resolvedTarget = _inst;
    var _isDynamic = false;

    if (is_struct(_inst)) {
        var _names = variable_struct_get_names(_inst);
        if (array_length(_names) == 1) {
            var _key = _names[0];

            if (variable_instance_exists(other, _key)) {
                var _candidate = variable_instance_get(other, _key);
                if (instance_exists(_candidate) || is_struct(_candidate)) {
                    _isDynamic = true;
                    _resolvedTarget = _candidate;
                    __bindScopeRef = weak_ref_create(other);
                    __bindKey = _key;
                }
            }
        }
    }

    if (!_isDynamic) {
        __bindScopeRef = undefined;
        __bindKey = undefined;
    }

    __target = _resolvedTarget;
    
    if (is_struct(_resolvedTarget) || instance_exists(_resolvedTarget)) {
        __targetRef = weak_ref_create(_resolvedTarget);
    } else {
        __targetRef = undefined;
    }

    __val = _resolvedTarget;
    return self;
}