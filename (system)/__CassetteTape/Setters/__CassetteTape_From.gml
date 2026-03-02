// Feather ignore all
/// @ignore  (Internal) __CassetteTape_From(value)
/// @desc    Sets the start value
/// @param   {Real|Struct} value The start value.
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_From(_val) {
    var _t = array_last(__tracks);

    if (is_struct(_val)) {
        if (__copyStructs) {
            _t.fromVal = variable_clone(_val);
        } else {
            _t.fromVal = {};
            var _names = variable_struct_get_names(_val);
            var _i = 0; repeat(array_length(_names)) {
                _t.fromVal[$ _names[_i]] = _val[$ _names[_i]];
                _i++;
            }
        }
        _t.propNames = variable_struct_get_names(_val);
    } else {
        _t.fromVal = _val;
    }

    if (_t.toVal == undefined) {
         _t.toVal = is_struct(_t.fromVal) ? 
            (__copyStructs ? variable_clone(_t.fromVal) : _t.fromVal) : _t.fromVal;
    }

    if (array_length(__tracks) == 1) {
        var _shouldBind = (__target != undefined);

        if (_shouldBind && is_struct(_val)) {
            var _names = _t.propNames; 
            var _matchFound = false;
            var _len = array_length(_names);

            if (_len > 0) {
                var _isInst = !is_struct(__target);
                var _k = 0;
                repeat(_len) {
                    var _prop = _names[_k];
                    var _exists = _isInst ? variable_instance_exists(__target, _prop) : variable_struct_exists(__target, _prop);

                    if (_exists) {
                        _matchFound = true;
                        break;
                    }
                    _k++;
                }
                if (!_matchFound) _shouldBind = false;
            }
        }

        if (_shouldBind) {
             __val = __target;
        } else {
             __target = undefined;
             __targetRef = undefined;
             __val = is_struct(_val) ? (__copyStructs ? variable_clone(_val) : _val) : _val;
        }
    }
    return self;
}