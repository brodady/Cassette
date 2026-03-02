// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Play([target], [params])
/// @desc    Resumes animation(s).
/// @param   {String|Struct|Array} [target] The Cassette struct(s) or String Key(s). If undefined, plays ALL.
/// @param   {Struct} [params] Optional parameters (e.g. { start: 0, delay: 0 }) to pass to the tape.
/// @return  {Undefined}
/// @self CassetteDeck
function __CassetteDeck_Play(_target = undefined, _params = undefined) {
    var _targets = __CassetteDeck_Resolve(_target);
    var _i = 0; repeat(array_length(_targets)) {
        _targets[_i].play(_params);
        _targets[_i].__manualPause = true;
        _i++;
    }
}
