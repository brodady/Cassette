// Feather ignore all
/// @ignore  (Internal) __CassetteVideoTape(sprite, target_inst, deck_ref, id)
function __CassetteVideoTape(_sprite, _target, _deck, _id) : __CassetteTape("video_" + string(_id), _deck, _id) constructor {

    __target = _target;
    __spriteAsset = _sprite;
    __frameEvents = {};
    __lastFrame = -1;
    __lastTrackIndex = -1;

    var _dur = __calcDuration(_sprite, __deck.__useSeconds);

    self.from(0)
        .to(sprite_get_number(_sprite))
        .duration(_dur)
        .hold();

    __tracks[0].spriteAsset = __spriteAsset;

    self.onPlay(method({t: __target, s: __spriteAsset}, function() {
        if (instance_exists(t)) t.sprite_index = s;
    }));

    self.onUpdate(method(self, function(_val) {
        if (!instance_exists(__targetInst)) return;

        var _track = __tracks[__trackIndex];
        var _currentSprite = _track.spriteAsset;

        if (__trackIndex != __lastTrackIndex) {
             __lastFrame = -1;
             __lastTrackIndex = __trackIndex;

             if (__targetInst.sprite_index != _track.spriteAsset) {
                __targetInst.sprite_index = _track.spriteAsset;
             }
        }
        else if (variable_struct_exists(_track, "spriteAsset")) {
            if (__targetInst.sprite_index != _track.spriteAsset) {
                __targetInst.sprite_index = _track.spriteAsset;
            }
        }

        __targetInst.image_index = _val;

        var _currFrame = floor(_val);
        if (_currFrame > __lastFrame) {
            var _start = __lastFrame + 1;

            for (var _f = _start; _f <= _currFrame; _f++) {
                // Global Events
                var _k = string(_f);
                if (variable_struct_exists(__frameEvents, _k)) {
                    var _callbacks = __frameEvents[$ _k];
                    var _i = 0; 
                    repeat(array_length(_callbacks)) { 
                        _callbacks[_i](); 
                        _i++; 
                    }
                }

                // Sprite-Specific Events
                if (_currentSprite != undefined) {
                    var _kSpec = string(_currentSprite) + ":" + string(_f);
                    if (variable_struct_exists(__frameEvents, _kSpec)) {
                         var _cb = __frameEvents[$ _kSpec];
                         var _j = 0; 
                         repeat(array_length(_cb)) { 
                             _cb[_j](); 
                             _j++; 
                         }
                    }
                }
            }
            __lastFrame = _currFrame;
        }
    }));

    #region Methods
    static next = function(_nextSprite = undefined) {
        var _prevSprite = array_last(__tracks).spriteAsset;
        _nextSprite = (_nextSprite == undefined) ? _prevSprite : _nextSprite;
        
        var _d = __calcDuration(_nextSprite, __deck.__useSeconds);
   
        var _def = {
            fromVal: 0,
            toVal: sprite_get_number(_nextSprite),
            duration: _d,
            ease: __CASSETTE_DEFAULT_EASE,
            lerpFunc: __deck.__defaultLerp,
            isCurve: false,
            type: __CASSETTE_ANIM.ONCE,
            loops: 0,
            isWait: false,
            onTrackEnd: undefined,
            propNames: undefined,
            spriteAsset: _nextSprite
        };
        
        array_push(__tracks, _def);
        return self;
    }

    static onFrame = function(_index, _func, _sprite = undefined) {
        var _k = (_sprite == undefined) ? string(_index) : (string(_sprite) + ":" + string(_index));
        if (!variable_struct_exists(__frameEvents, _k)) __frameEvents[$ _k] = [];
        array_push(__frameEvents[$ _k], _func);
        return self;
    }

    static reset = function(_key, _deck, _id) {
        __CassetteTape_Reset(_key, _deck, _id);

        __frameEvents = {};
        __lastFrame = -1;
        __lastTrackIndex = -1; 

        var _dur = __calcDuration(__spriteAsset, __deck.__useSeconds);

        self.from(0)
            .to(sprite_get_number(__spriteAsset)) 
            .duration(_dur)
            .hold();
            
        __tracks[0].spriteAsset = __spriteAsset;

        self.onPlay(method({t: __target, s: __spriteAsset}, function() {
            if (instance_exists(t)) t.sprite_index = s;
        }));

        return self;
    }

    /// @ignore (Internal) Helper: Calculate Duration
    static __calcDuration = function(_spr, _useSec) {
        var _num = sprite_get_number(_spr);
        var _spd = sprite_get_speed(_spr);
        var _type = sprite_get_speed_type(_spr);

        var _fps = game_get_speed(gamespeed_fps);
        _fps = (_fps <= 0) ? 60 : _fps; 

        var _durationInFrames = 0;

        if (_type == spritespeed_framespergameframe) {
            _durationInFrames = _num / max(_spd, 0.001); 
        } else {
            _durationInFrames = _num / (max(_spd, 0.001) / _fps);
        }

        if (_useSec) {
            return _durationInFrames * (1 / _fps);
        }
        
        return _durationInFrames;
    }
    #endregion
}