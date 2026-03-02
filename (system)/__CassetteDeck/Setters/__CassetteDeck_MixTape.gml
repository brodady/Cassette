// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_MixTape(key)
/// @desc    Retrieves or creates a Mixtape (timeline) managed by this Deck.
/// @param   {String} key The unique identifier for this sequence.
/// @return  {Struct.Cassette}
/// @self CassetteDeck
function __CassetteDeck_MixTape(_key) {

    var _existingCore = __tapesMap[$ _key];
    
    if (_existingCore != undefined) {
        if (_existingCore.__active) {
            return new Cassette(_existingCore.__id, self);
        } else {
            _existingCore.eject();
        }
    }

    var _id = __getUniqueId();
    var _core = new __CassetteMixtape(_key, self, _id);

    array_push(__tapesList, _core);
    __tapesMap[$ _key] = _core;         
    __tapesById[_id] = _core;

    return new Cassette(_id, self);
}
