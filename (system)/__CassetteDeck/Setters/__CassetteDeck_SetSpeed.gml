// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_SetSpeed(speed)
/// @desc    Sets the global time scale multiplier for this Deck.
/// @param   {Real} speed The new time scale (1.0 is normal).
/// @return  {Struct.CassetteDeck} Self
/// @self CassetteDeck
function __CassetteDeck_SetSpeed(_speed) {
    __timeScale = _speed;
    return self;
}
