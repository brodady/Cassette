/// @desc If true, errors in callbacks will crash the game with a popup.
///       If false, errors are logged to the output window, but the game continues.
#macro CASSETTE_STRICT_MODE false

/// @desc Wether to "try/catch" callbacks. Disable for maximum performance.
#macro CASSETTE_SAFE_MODE debug_mode