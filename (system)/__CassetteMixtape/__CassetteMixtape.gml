// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape(key, deck, _id)
/// @desc A Timeline sequence that behaves like a Tape but drives other Tapes.
/// @param {String} _key The Name of the Mixtape.
/// @param {Struct.CassetteDeck} _deck Deck manager instance that will control this Mixtape.
/// @param {Real} _id The Cassette handle (unique id)
function __CassetteMixtape(_key, _deck, _id) constructor {
    __key       = _key;
    __deck      = _deck;
    __id        = _id;
    __parent    = _deck;
    __active    = true;
    __paused    = true;
    __items     = [];
    __tags      = [];
    __timer     = 0;
    __duration  = 0;
    
    // Builder State
    __headTime  = 0;
    __lastStart = 0;
    __startDelay    = 0;
    __currentDelay  = 0;

    // Playback State
    __loops     = 0;
    __direction = 1;
    __type      = __CASSETTE_ANIM.ONCE; 

    // Methods
    static add              = __CassetteMixtape_Add;
    static startDelay       = __CassetteMixtape_SetStartDelay;
    static step             = __CassetteMixtape_Step;
    static play             = __CassetteMixtape_Play;
    static pause            = __CassetteMixtape_Pause;
    static stop             = __CassetteMixtape_Stop;
    static seek             = __CassetteMixtape_Seek;
    static jump             = __CassetteMixtape_Jump;
    static skip             = __CassetteMixtape_Skip;
    static back             = __CassetteMixtape_Back;
    static rewind           = __CassetteMixtape_Rewind;
    static ffwd             = __CassetteMixtape_Ffwd;
    static eject            = __CassetteMixtape_Eject;
    static loop             = __CassetteMixtape_Loop;
    static pingpong         = __CassetteMixtape_PingPong;
    static getName          = __CassetteMixtape_GetName;     
    static getDuration      = __CassetteMixtape_GetDuration; 
    static getTime          = __CassetteMixtape_GetTime;         
    static isInfinite       = __CassetteMixtape_IsInfinite;
    static addTag           = __CassetteTape_AddTag;
    static removeTag        = __CassetteTape_RemoveTag;
    static hasTag           = __CassetteTape_HasTag;
    // - (Internal)
    static __RemoveChild    = __CassetteMixtape_RemoveChild;
    static __DetachChild    = __CassetteMixtape_DetachChild;
    
}