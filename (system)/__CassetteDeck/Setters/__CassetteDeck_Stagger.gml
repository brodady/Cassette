// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_Stagger(_targets, _amount, _reverse = false, _ease = undefined)
/// @desc    Staggers animations.
///            - If _ease is undefined, _amount is the interval (delay steps/seconds) between each item.
///            - If _ease is defined, _amount is the total duration, distributed along the curve.
/// @param {Array<Struct|String>|String|Struct} _targets The Cassette references or String keys to stagger.
/// @param {Real} _amount Interval or Total Duration.
/// @param {Bool} [_reverse] Run in reverse order.
/// @param {Bool} [_autoStart] Play automatically or require being played after definition, defaults to false.
/// @param {Function|Asset.GMAnimCurve} [_ease] Optional distribution curve.
/// @self CassetteDeck
function __CassetteDeck_Stagger(_targets, _amount, _reverse = false, _autoStart = false, _ease = undefined) {

    var _resolvedList = __CassetteDeck_Resolve(_targets);
    var _len = array_length(_resolvedList);
    if (_len == 0) return;

    var _targetList = (_reverse) ? array_reverse(_resolvedList) : _resolvedList;

    // Calculate Delays
    var _delays = array_create(_len, 0);
    var _minDelay = 0;

    if (_ease != undefined) {
        var _curveChan = undefined;
        var _isCurve = false;

        if (is_struct(_ease) && variable_struct_exists(_ease, "channels")) {
             _curveChan = animcurve_get_channel(_ease, 0);
             _isCurve = true;
        }
        else if (!is_method(_ease) && animcurve_exists(_ease)) {
             _curveChan = animcurve_get_channel(animcurve_get(_ease), 0);
             _isCurve = true;
        }

        for (var _i = 0; _i < _len; _i++) {
            var _norm = (_len > 1) ? (_i / (_len - 1)) : 0;
            var _factor = 0;

            if (_isCurve) {
                _factor = animcurve_channel_evaluate(_curveChan, _norm);
            } else {
                _factor = _ease(_norm);
            }
            
            _delays[_i] = _factor * _amount;
            _minDelay = (_delays[_i] < _minDelay) ? _delays[_i] : 0;
        }
    }
    else {
        // Interval Mode
        for (var _i = 0; _i < _len; _i++) {
            _delays[_i] = _i * _amount;
        }
    }

    // Apply Delays
    var _offset = -_minDelay;

    for (var _i = 0; _i < _len; _i++) {
        var _t = _targetList[_i];

        if (variable_struct_exists(_t, "startDelay")) {
            _t.startDelay(_delays[_i] + _offset);
            _t.rewind();
            if (_autoStart) {
                _t.play();
            }
        }
    }
}