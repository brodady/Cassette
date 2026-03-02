// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Insert([key])
/// @desc    Creates (or recycles) a new animation tape and loads it into the deck.
/// @param   {String} [key] Optional unique identifier.
/// @param   {Struct|Asset.GMObject} [bindTo] Optional instance to bind properties to (otherwise defaults to self, or the scope of a struct passed).
/// @return  {Struct.Cassette} The newly created Cassette.
function __CassetteDeck_Insert(_key = undefined, _bindTo = undefined) {

    if (_key != undefined) {
        var _existing = __tapesMap[$ _key];
        if (_existing != undefined) {
            _existing.eject();
        }
    }

    var _id = __getUniqueId();
    var _core;

    if (array_length(__pool) > 0) {
        _core = array_pop(__pool);
        _core.reset(_key, self, _id);
    } 
    else {
        _core = new __CassetteTape(_key, self, _id);
        array_push(__tapesList, _core);

        if (_key != undefined) {
            __tapesMap[$ _key] = _core;
        }
    }
    
    var _target = (_bindTo != undefined) ? _bindTo : other;
    _core.bind(_target);

    __tapesById[_id] = _core;

    return new Cassette(_id, self);
}
