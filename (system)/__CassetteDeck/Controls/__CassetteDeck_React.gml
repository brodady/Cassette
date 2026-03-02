// Feather ignore all
/// @ignore   (Internal) __CassetteDeck_React(target, target_time, tension, damping, [snap])
/// @desc   Forwards spring physics control to specific tape(s).
/// @param  {String|Struct|Array} target The Cassette struct(s) or String Key(s).
/// @param  {Real} target_time    The target time (playhead position) to spring towards.
/// @param  {Real} tension        Stiffness of the spring (e.g., 0.1 to 1.0).
/// @param  {Real} damping        Friction of the spring (e.g., 0.1 to 1.0).
/// @param  {Real} [snap]         Distance threshold to snap to target (default 0.001).
/// @return {Undefined}
/// @self CassetteDeck
function __CassetteDeck_React(_target, _target_time, _tension, _damping, _snap=0.001) {
    var _targets = __CassetteDeck_Resolve(_target);
    var _i = 0; repeat(array_length(_targets)) {
        _targets[_i].react(_target_time, _tension, _damping, _snap);
        _i++;
    }
}