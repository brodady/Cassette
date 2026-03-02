// Feather ignore all
/// @ignore  (Internal) __CassetteDeck_GetUniqueId Safe ID Generator
/// @self CassetteDeck
function __CassetteDeck_GetUniqueId() {

    if (array_length(__freeIds) > 0) {
        return array_pop(__freeIds);
    }

    __idCounter++;

    if (__idCounter >= __CASSETTE_ID_LIMIT) {
        __idCounter = 1;

        while (__idCounter < array_length(__tapesById) && __tapesById[__idCounter] != undefined) {
             __idCounter++;

             if (__idCounter >= __CASSETTE_ID_LIMIT) {
                var _event = "MAX NUMBER OF TAPES ";
                var _error = $"__CASSETTE_ID_LIMIT ({__CASSETTE_ID_LIMIT}) Exceeded! Increase the limit in 'Cassette/(system)/__CassetteMacros' OR create more decks.";
                __CassetteError(_event, _error);
             }
        }
    }

    return __idCounter;
};
