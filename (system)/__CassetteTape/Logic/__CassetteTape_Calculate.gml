// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Calculate(_time = undefined) 
/// Main update loop with validation for bindings, bounds, types, and track cleanup.
function __CassetteTape_Calculate(_time = undefined) {

    #region Binding & Reference Validation
    if (__bindScopeRef != undefined) {
        if (weak_ref_alive(__bindScopeRef)) {
            var _scope = __bindScopeRef.ref;
            var _currentRef = undefined;
            if (variable_instance_exists(_scope, __bindKey)) {
                _currentRef = variable_instance_get(_scope, __bindKey);
            }
            if (_currentRef != __target) {
                 __target = _currentRef;
                 if (is_struct(__target) || instance_exists(__target)) {
                     __targetRef = weak_ref_create(__target);
                 } else {
                     __targetRef = undefined;
                 }
                 if (!is_struct(__val)) __val = __target;
            }
        } else {
            stop();
            return;
        }
    }

    if (__targetRef != undefined) {
        if (!weak_ref_alive(__targetRef)) {
            eject();
            return;
        }
    }
    #endregion

    #region Track & Duration
    if (__trackIndex < 0 || __trackIndex >= array_length(__tracks)) return;
    var _track = __tracks[__trackIndex];
    
    if (_track.isWait) return; 

    var _rawDur = __Cassette_ResolveValue(_track.duration);
    var _safeDur = max(_rawDur, 0.001);
    var _tRaw = (_time != undefined) ? _time : __timer;
    var _t = clamp(_tRaw / _safeDur, 0, 1);
    #endregion

    #region Ease & Interpolation
    var _resolvedEase = _track.ease;
    var _safety = 0;

    // Unwrap bindings
    while (is_struct(_resolvedEase) && !is_method(_resolvedEase) && _safety++ < 16) {
        if (variable_struct_exists(_resolvedEase, "channels")) break; // Curve Asset
        if (variable_struct_exists(_resolvedEase, "points")) break;   // Curve Channel
        
        var _names = variable_struct_get_names(_resolvedEase);
        if (array_length(_names) == 0) break;
        
        var _key = _names[0];

        // Implicit binding
        if (__target != undefined && (instance_exists(__target) || is_struct(__target))) {
            var _hasVar = is_struct(__target) 
                          ? variable_struct_exists(__target, _key) 
                          : variable_instance_exists(__target, _key);
            
            if (_hasVar) {
                _resolvedEase = is_struct(__target)
                                ? __target[$ _key]
                                : variable_instance_get(__target, _key);
                break; 
            }
        }
        
        _resolvedEase = _resolvedEase[$ _key];
    }

    var _progress = _t;

    if (_resolvedEase != undefined) {
        // Method / Function
        if (is_method(_resolvedEase)) {
             _progress = _resolvedEase(_t);
        }
        // Animation Curve Channel (Direct Struct)
        else if (is_struct(_resolvedEase) && variable_struct_exists(_resolvedEase, "points")) {
             _progress = animcurve_channel_evaluate(_resolvedEase, _t);
        }
        // Animation Curve Asset (ID, String, or Root Struct)
        else if (animcurve_exists(_resolvedEase)) {
             var _chan = animcurve_get_channel(_resolvedEase, __CASSETTE_DEFAULT_CURVE_CHANNEL);
             if (is_struct(_chan) && variable_struct_exists(_chan, "points")) {
                 _progress = animcurve_channel_evaluate(_chan, _t);
             }
        }
    }

    // Determine Lerp Function
    var _lerp = (_track.lerpFunc != undefined)
                ? _track.lerpFunc 
                : ((__deck != undefined) ? __deck.__defaultLerp : lerp);
    #endregion

    #region Apply Values
    var _start, _end;

    if (_track.propNames != undefined) {
        // Struct
        _start = _track.fromVal;
        _end   = _track.toVal;

        var _isInst = !is_struct(__val) && instance_exists(__val);
        if (!_isInst && !is_struct(__val)) __val = {};
        
        __Cassette_LerpDeep(_start, _end, _progress, _lerp, __val, _isInst);
    } 
    else {
        // Scalar
        _start = __Cassette_ResolveValue(_track.fromVal);
        _end   = __Cassette_ResolveValue(_track.toVal);
        
        __val = _lerp(_start, _end, _progress);
    }
    #endregion

    #region Callbacks & Events
    var _prevTime = __lastTimer;
    var _prevFrame = floor(_prevTime);
    var _currFrame = floor(_tRaw);

    if (_currFrame > _prevFrame) {
        var _s = _prevFrame + 1;
        for (var _f = _s; _f <= _currFrame; _f++) {
            var _k = string(_f);
            if (variable_struct_exists(__frameEvents, _k)) {
                var _callbacks = __frameEvents[$ _k];
                var _i = 0; repeat(array_length(_callbacks)) { _callbacks[_i](); _i++; }
            }
        }
    }

    if (is_method(__onUpdate)) {
        var _shouldRun = true;
        if (__onUpdateInterval != undefined && __onUpdateInterval > 0) {
            var _stepPrev = floor(_prevTime / __onUpdateInterval);
            var _stepCurr = floor(_tRaw / __onUpdateInterval);
            if (_stepPrev == _stepCurr) _shouldRun = false;
        }

        if (_shouldRun) {
            if (CASSETTE_SAFE_MODE) {
                try { __onUpdate(__val); } catch(_e) { __CassetteError("onUpdate", _e); }
            } else {
                __onUpdate(__val);
            }
        }
    }

    __lastTimer = _tRaw;
    #endregion
}