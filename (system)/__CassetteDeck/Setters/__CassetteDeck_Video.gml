// Feather ignore all
/// @ignore (Internal) __CassetteDeck_Video(sprite, [target_instance])
/// @desc   Creates a tape that drives a sprite animation with Cassette timing/easing.
/// @self CassetteDeck
function __CassetteDeck_Video(_sprite, _target = other) {
    var _id = __getUniqueId();
    var _core = new __CassetteVideoTape(_sprite, _target, self, _id);

    __tapesById[_id] = _core;
    array_push(__tapesList, _core);

    return new Cassette(_id, self);
}
