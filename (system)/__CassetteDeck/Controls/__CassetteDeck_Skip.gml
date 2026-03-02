// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Skip([target])
/// @desc    Executes .skip() on the target animation(s).
/// @param   {String|Array<String>|Undefined} [target] The ID(s) to control. If undefined, applies to ALL.
/// @return  {Undefined}
/// @self CassetteDeck
function __CassetteDeck_Skip(_target = undefined) {
    var _targets = __CassetteDeck_Resolve(_target);
    var _i = 0; repeat(array_length(_targets)) {
        _targets[_i].skip();
        _i++;
    }
}
