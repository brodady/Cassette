// Feather ignore all
/// @ignore  (Internal) __CassetteMixtape_Play()
/// @desc    Resumes the Mixtape.
/// @return  {Struct.CassetteMixtape} Self
/// @self __CassetteMixtape
function __CassetteMixtape_Play() { 
    
    if (__paused && __deck != undefined) {
        __deck.__playingCount++;
    }

    __paused = false;
    __active = true;

    if (__deck != undefined) {
        if (!variable_struct_exists(__deck.__tapesMap, __key)) {
             array_push(__deck.__tapesList, self);
             __deck.__tapesMap[$ __key] = self;
        }
    }
    
    return self; 
}
