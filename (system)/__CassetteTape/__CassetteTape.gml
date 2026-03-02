// Feather ignore all
/// @ignore (Internal) __CassetteTape(key, deck_ref)
/// @desc A single animation sequence.
/// @param {String} _key The Name of the Tape
/// @param {Struct.CassetteDeck} _deck Deck manager instance that will control this Tape.
function __CassetteTape(_key = undefined, _deck, _id) constructor {
    // Initialize
    __key = _key;
    __deck = _deck;
    __id = _id
    __parent = _deck;
    __target = undefined;
    __targetRef = undefined;
    __bindScopeRef = undefined;
    __bindKey = undefined;

    // State
    __active = true;
    __type = __CASSETTE_ANIM.ONCE;
    __paused = !_deck.__autoStart;
    __manualPause = false; // For methods that manage pause themeselves, like .scrub
    __finished = false;
    __copyStructs = false;
    __tags = [];

    if (!__paused) {
        _deck.__playingCount++;
    }

    // Playback
    __tracks = [__CASSETTE_DEFAULT_TRACK];
    __trackIndex = 0;
    __timer = 0;
    __lastTimer = 0;
    __val = 0;
    __speed = 1.0;
    __reactVel = 0;
    __direction = 1;
    __loops = 0;
    __trackLoops = 0;
    __isSkipping = false;

    // Callbacks
    __onUpdate = undefined;
    __onUpdateInterval = undefined;
    __frameEvents = {};
    __onEnd = undefined;
    __onAnyTrackEnd = undefined
    __onPlay = undefined;
    __onPause = undefined;
    __onStop = undefined;
    __onRewind = undefined;
    __onFfwd = undefined;
    __onSeek = undefined;
    __onSkip = undefined;
    __onBack = undefined;

    // Builder Methods
    static bind             = __CassetteTape_Bind;
    static from			    = __CassetteTape_From;
    static to			    = __CassetteTape_To;
    static by               = __CassetteTape_By;
    static duration		    = __CassetteTape_Duration;
    static ease			    = __CassetteTape_Ease;
    static loop			    = __CassetteTape_Loop;
    static loopTape		    = __CassetteTape_LoopTape;
    static pingpong		    = __CassetteTape_PingPong;
    static pingpongTape	    = __CassetteTape_PingPongTape;
    static next		        = __CassetteTape_Next;
    static wait			    = __CassetteTape_Wait;
    static hold			    = __CassetteTape_Hold;
    static clone            = __CassetteTape_Clone;
    static lerpFunc         = __CassetteTape_LerpFunc;

    // Control Methods
    static play             = __CassetteTape_Play;
    static pause            = __CassetteTape_Pause;
    static stop             = __CassetteTape_Stop;
    static eject            = __CassetteTape_Eject;
    static setSpeed         = __CassetteTape_SetSpeed;
    static react            = __CassetteTape_React;
    static scrub            = __CassetteTape_Scrub;
    static step		        = __CassetteTape_Step;
    static seek		        = __CassetteTape_Seek;
    static rewind	        = __CassetteTape_Rewind;
    static skip		        = __CassetteTape_Skip;
    static back		        = __CassetteTape_Back;
    static ffwd		        = __CassetteTape_Ffwd;

    // Tagging
    static addTag           = __CassetteTape_AddTag;
    static removeTag        = __CassetteTape_RemoveTag;
    static hasTag           = __CassetteTape_HasTag;

    // Control State Callbacks
    static onPlay           = __CassetteTape_OnPlay;
    static onPause          = __CassetteTape_OnPause;
    static onStop           = __CassetteTape_OnStop;
    static onRewind         = __CassetteTape_OnRewind;
    static onFfwd           = __CassetteTape_OnFfwd;
    static onSeek           = __CassetteTape_OnSeek;
    static onSkip           = __CassetteTape_OnSkip;
    static onBack           = __CassetteTape_OnBack;

    // Per-Frame & Completion Callbacks
    static onUpdate         = __CassetteTape_OnUpdate;
    static onEnd            = __CassetteTape_OnEnd;
    static onFrame          = __CassetteTape_OnFrame;
    static onTrackEnd       = __CassetteTape_OnTrackEnd;
    static onAnyTrackEnd    = __CassetteTape_OnAnyTrackEnd;

    // Getters
    static get                  = __CassetteTape_Get;
    static getDirection         = __CassetteTape_GetDirection;
    static getDuration          = __CassetteTape_GetDuration;
    static getLoopsRemaining    = __CassetteTape_GetLoopsRemaining;
    static getName              = __CassetteTape_GetName;
    static getProgress          = __CassetteTape_GetProgress;
    static getTarget            = __CassetteTape_GetTarget;
    static getTime              = __CassetteTape_GetTime;
    static getTrackIndex        = __CassetteTape_GetTrackIndex;
    static getSpeed             = __CassetteTape_GetSpeed;
    static isFinished           = __CassetteTape_IsFinished;
    static isInfinite           = __CassetteTape_IsInfinite;
    static isPaused             = __CassetteTape_IsPaused;

    /// System Utilities
    static startDelay       = __CassetteTape_SetStartDelay;
    static reset            = __CassetteTape_Reset;
}