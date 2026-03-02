// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Seek(amount, [key_or_array])
/// @desc    Moves the playback head by a specific amount for one or multiple animations.
/// @param   {Real} amount The amount to move the timer (frames or seconds).
/// @param   {String|Struct.Cassette|Array<String>|Array<Struct.Cassette>|Undefined} [key] The ID(s) to seek. If undefined, seeks ALL.
/// @return  {Undefined}
/// @self CassetteDeck
function __CassetteDeck_Seek(_amount, _key = undefined) {
    var _targets = __CassetteDeck_Resolve(_key);

    var _i = 0; repeat(array_length(_targets)) {
        __CassetteTape_HandleCallback(_targets[_i].__onSeek);
        _targets[_i].seek(_amount);
        _i++;
    }
}
