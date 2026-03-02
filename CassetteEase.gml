// Playback Constants
#macro CASSETTE_DEFAULT_PLAYBACK_SPEED 1.0

// Bounce Constants
#macro CASSETTE_BOUNCE_N1 7.5625
#macro CASSETTE_BOUNCE_D1 2.75
#macro CASSETTE_BOUNCE_T1 (1 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_T2 (2 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_T3 (2.5 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_O1 (1.5 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_O2 (2.25 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_O3 (2.625 / CASSETTE_BOUNCE_D1)
#macro CASSETTE_BOUNCE_A1 0.75     
#macro CASSETTE_BOUNCE_A2 0.9375
#macro CASSETTE_BOUNCE_A3 0.984375

// Elastic Constants
#macro CASSETTE_ELASTIC_PERIOD1_DIV 3.0
#macro CASSETTE_ELASTIC_PERIOD2_DIV 4.5
#macro CASSETTE_ELASTIC_C4 ((2 * pi) / CASSETTE_ELASTIC_PERIOD1_DIV)
#macro CASSETTE_ELASTIC_C5 ((2 * pi) / CASSETTE_ELASTIC_PERIOD2_DIV)

// Back Constants
#macro CASSETTE_BACK_S1 1.70158
#macro CASSETTE_BACK_S2 (CASSETTE_BACK_S1 * 1.525)
#macro CASSETTE_BACK_C1 CASSETTE_BACK_S1
#macro CASSETTE_BACK_C2 CASSETTE_BACK_S2
#macro CASSETTE_BACK_C3 (CASSETTE_BACK_S1 + 1)

/// @func CassetteEase()
/// @desc A collection of static easing equations.
function CassetteEase() constructor {

    // --- Linear ---
    /// @func Linear(t)
    static Linear = function(_t) { return _t; };

    // --- Sine ---
    /// @func InSine(t)
    static InSine = function(_t) {
        return 1 - cos((_t * pi) / 2);
    };

    /// @func OutSine(t)
    static OutSine = function(_t) {
        return sin((_t * pi) / 2);
    };

    /// @func InOutSine(t)
    static InOutSine = function(_t) {
        return -(cos(pi * _t) - 1) / 2;
    };

    // --- Quad ---
    /// @func InQuad(t)
    static InQuad = function(_t) {
        return _t * _t;
    };

    /// @func OutQuad(t)
    static OutQuad = function(_t) {
        return 1 - (1 - _t) * (1 - _t);
    };

    /// @func InOutQuad(t)
    static InOutQuad = function(_t) {
        return (_t < 0.5) ? 2 * _t * _t : 1 - power(-2 * _t + 2, 2) / 2;
    };

    // --- Cubic ---
    /// @func InCubic(t)
    static InCubic = function(_t) {
        return _t * _t * _t;
    };

    /// @func OutCubic(t)
    static OutCubic = function(_t) {
        return 1 - power(1 - _t, 3);
    };

    /// @func InOutCubic(t)
    static InOutCubic = function(_t) {
        return (_t < 0.5) ? 4 * _t * _t * _t : 1 - power(-2 * _t + 2, 3) / 2;
    };

    // --- Quart ---
    /// @func InQuart(t)
    static InQuart = function(_t) {
        return _t * _t * _t * _t;
    };

    /// @func OutQuart(t)
    static OutQuart = function(_t) {
        return 1 - power(1 - _t, 4);
    };

    /// @func InOutQuart(t)
    static InOutQuart = function(_t) {
        return (_t < 0.5) ? 8 * _t * _t * _t * _t : 1 - power(-2 * _t + 2, 4) / 2;
    };

    // --- Quint ---
    /// @func InQuint(t)
    static InQuint = function(_t) {
        return _t * _t * _t * _t * _t;
    };

    /// @func OutQuint(t)
    static OutQuint = function(_t) {
        return 1 - power(1 - _t, 5);
    };

    /// @func InOutQuint(t)
    static InOutQuint = function(_t) {
        return (_t < 0.5) ? 16 * _t * _t * _t * _t * _t : 1 - power(-2 * _t + 2, 5) / 2;
    };

    // --- Expo ---
    /// @func InExpo(t)
    static InExpo = function(_t) {
        return (_t == 0) ? 0 : power(2, 10 * _t - 10);
    };

    /// @func OutExpo(t)
    static OutExpo = function(_t) {
        return (_t == 1) ? 1 : 1 - power(2, -10 * _t);
    };

    /// @func InOutExpo(t)
    static InOutExpo = function(_t) {
        if (_t == 0) return 0;
        if (_t == 1) return 1;
        return (_t < 0.5) ? power(2, 20 * _t - 10) / 2 : (2 - power(2, -20 * _t + 10)) / 2;
    };

    // --- Circ ---
    /// @func InCirc(t)
    static InCirc = function(_t) {
        var _inner = 1 - power(_t, 2);
        return 1 - ((sign(_inner) == -1) ? 0 : sqrt(_inner));
    };

    /// @func OutCirc(t)
    static OutCirc = function(_t) {
        var _inner = 1 - power(_t - 1, 2);
        return (sign(_inner) == -1) ? 0 : sqrt(_inner);
    };

    /// @func InOutCirc(t)
    static InOutCirc = function(_t) {
        if (_t < 0.5) {
            var _inner = 1 - power(2 * _t, 2);
            var _sqrt = (sign(_inner) == -1) ? 0 : sqrt(_inner);
            return (1 - _sqrt) / 2;
        } else {
            var _inner = 1 - power(-2 * _t + 2, 2);
            var _sqrt = (sign(_inner) == -1) ? 0 : sqrt(_inner);
            return (_sqrt + 1) / 2;
        }
    };

    // --- Elastic ---
    /// @func InElastic(t)
    static InElastic = function(_t) {
        if (_t == 0) return 0;
        if (_t == 1) return 1;
        return -power(2, 10 * _t - 10) * sin((_t * 10 - 10.75) * CASSETTE_ELASTIC_C4);
    };

    /// @func OutElastic(t)
    static OutElastic = function(_t) {
        if (_t == 0) return 0;
        if (_t == 1) return 1;
        return power(2, -10 * _t) * sin((_t * 10 - 0.75) * CASSETTE_ELASTIC_C4) + 1;
    };

    /// @func InOutElastic(t)
    static InOutElastic = function(_t) {
        if (_t == 0) return 0;
        if (_t == 1) return 1;
        return (_t < 0.5)
            ? -(power(2, 20 * _t - 10) * sin((20 * _t - 11.125) * CASSETTE_ELASTIC_C5)) / 2
            : (power(2, -20 * _t + 10) * sin((20 * _t - 11.125) * CASSETTE_ELASTIC_C5)) / 2 + 1;
    };

    // --- Back ---
    /// @func InBack(t)
    static InBack = function(_t) {
        return CASSETTE_BACK_C3 * _t * _t * _t - CASSETTE_BACK_C1 * _t * _t;
    };

    /// @func OutBack(t)
    static OutBack = function(_t) {
        return 1 + CASSETTE_BACK_C3 * power(_t - 1, 3) + CASSETTE_BACK_C1 * power(_t - 1, 2);
    };

    /// @func InOutBack(t)
    static InOutBack = function(_t) {
        return (_t < 0.5)
            ? (power(2 * _t, 2) * ((CASSETTE_BACK_C2 + 1) * 2 * _t - CASSETTE_BACK_C2)) / 2
            : (power(2 * _t - 2, 2) * ((CASSETTE_BACK_C2 + 1) * (_t * 2 - 2) + CASSETTE_BACK_C2) + 2) / 2;
    };

    // --- Bounce ---
    /// @func OutBounce(t)
    static OutBounce = function(_t) {
        if (_t < CASSETTE_BOUNCE_T1) {
            return CASSETTE_BOUNCE_N1 * _t * _t;
        } else if (_t < CASSETTE_BOUNCE_T2) {
            _t -= CASSETTE_BOUNCE_O1;
            return CASSETTE_BOUNCE_N1 * _t * _t + CASSETTE_BOUNCE_A1;
        } else if (_t < CASSETTE_BOUNCE_T3) {
            _t -= CASSETTE_BOUNCE_O2;
            return CASSETTE_BOUNCE_N1 * _t * _t + CASSETTE_BOUNCE_A2;
        } else {
            _t -= CASSETTE_BOUNCE_O3;
            return CASSETTE_BOUNCE_N1 * _t * _t + CASSETTE_BOUNCE_A3;
        }
    };

    /// @func InBounce(t)
    static InBounce = function(_t) {
        return 1 - CassetteEase.OutBounce(1 - _t);
    };

    /// @func InOutBounce(t)
    static InOutBounce = function(_t) {
        return (_t < 0.5)
            ? (1 - CassetteEase.OutBounce(1 - 2 * _t)) / 2
            : (1 + CassetteEase.OutBounce(2 * _t - 1)) / 2;
    };
}