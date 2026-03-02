// Feather ignore all
/// @ignore  (Internal) __CassetteTape_SetStartDelay(_dur) Sets a delay via '.wait' at the beginning of a Tape (Used for Mixtape & Stagger logic)
/// @desc    Inserts a 'Wait' track at the start. Inherits start state to ensure proper Rewind/Reset behavior.
/// @param   {Real|Struct} duration The delay duration (frames/seconds or dynamic struct).
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_SetStartDelay(_dur) {

    var _isValid = false;
    if (is_numeric(_dur) && _dur > 0) _isValid = true;
    else if (is_struct(_dur) || is_method(_dur)) _isValid = true;

    if (_isValid) {
        var _wait = {
            fromVal: undefined,
            toVal: undefined,
            propNames: undefined,
            duration: 0,
            ease: (__deck != undefined) ? __deck.__defaultEase : 0,
            lerpFunc: undefined,
            isCurve: false,
            isWait: true,
            loops: 0,
            type: __CASSETTE_ANIM.ONCE,
            onTrackEnd: undefined
        };

        if (__copyStructs && is_struct(_dur) && !is_method(_dur)) {
            _wait.duration = variable_clone(_dur);
        } else {
            _wait.duration = _dur;
        }

        if (array_length(__tracks) > 0) {
            var _first = __tracks[0];

            if (is_struct(_first.fromVal)) {
                if (__copyStructs) {
                    _wait.fromVal = variable_clone(_first.fromVal);
                } else {
                    _wait.fromVal = _first.fromVal;
                }

                if (is_array(_first.propNames)) {
                    _wait.propNames = variable_clone(_first.propNames); 
                }
            } else {
                _wait.fromVal = _first.fromVal;
            }
        }

        array_insert(__tracks, 0, _wait);
    }
    return self;
}
