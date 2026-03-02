// Feather ignore all
/// @ignore (Internal) Updates a tape
/// @param _dt Time
/// @self __CassetteTape
function __CassetteTape_Step(_dt) {
    var _spd = __Cassette_ResolveValue(__speed);
    __CassetteTape_Seek(_dt * _spd);
}
