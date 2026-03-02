// Feather ignore all
/// @ignore  (Internal) __CassetteTape_UpdateValue(_newVal) Updates '__val' but keeps structs/instances persistent.
function __CassetteTape_UpdateValue(_newVal) {

    if (__targetRef != undefined) {
        if (!weak_ref_alive(__targetRef)) {
            eject();
            return;
        }
    }

    var _isStruct = is_struct(__val);
    var _isInst   = !_isStruct && instance_exists(__val);

    if ((_isStruct || _isInst) && is_struct(_newVal)) {
        var _names = variable_struct_get_names(_newVal);
        var _i = 0; repeat(array_length(_names)) {
            var _k = _names[_i];
            var _v = _newVal[$ _k];

            if (_isInst) variable_instance_set(__val, _k, _v);
            else __val[$ _k] = _v;

            _i++;
        }
    } else {
        __val = is_struct(_newVal) ?
            (__copyStructs ? variable_clone(_newVal) : _newVal) : _newVal;
    }
}