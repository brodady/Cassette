/// @ignore  (Internal) __CassetteDeck_ResumeSystem()
/// @desc    Suspends the update loop entirely (time stops ticking)
///          Use this when a specific Deck is totally irrelevant to the current game state
///          (e.g., disabling the "Main Menu Deck" while in-game, or pausing the whole game when the window loses focus).
/// @self CassetteDeck
function __CassetteDeck_PauseSystem() {
    time_source_pause(__timeSource);
};
