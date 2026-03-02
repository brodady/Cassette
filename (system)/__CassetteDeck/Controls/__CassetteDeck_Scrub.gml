// Feather ignore all
/// @ignore   (Internal) __CassetteDeck_Scrub(target, input_value, attack, decay, [ease])
/// @desc   Forwards scrub/speed control to specific tape(s).
/// @param  {String|Struct|Array} target The Cassette struct(s) or String Key(s).
/// @param  {Real} input_value    The target input (e.g. axis value).
/// @param  {Real} attack         Lerp factor for acceleration.
/// @param  {Real} decay          Lerp factor for deceleration.
/// @param  {Function} [ease]     Optional easing function for the speed curve.
/// @return {Undefined}
/// @self CassetteDeck
function __CassetteDeck_Scrub(_target, _val, _att, _dec, _ease=undefined) {
    var _targets = __CassetteDeck_Resolve(_target);
    var _i = 0; repeat(array_length(_targets)) {
        _targets[_i].scrub(_val, _att, _dec, _ease);
        _i++;
    }
}