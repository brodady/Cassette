// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Play([params])
/// @desc    Resumes the tape, optionally handling start time and delay.
/// @param   {Struct} [params] Optional config { start: 0, delay: 0 }
/// @return  {Struct.CassetteTape} Self
/// @self __CassetteTape
function __CassetteTape_Play(_params = undefined) { 

    if (_params != undefined) {
        if (variable_struct_exists(_params, "delay")) {
            __CassetteTape_SetStartDelay(_params.delay)
        }

        if (variable_struct_exists(_params, "start")) {
            __CassetteTape_Seek(_params.start);
        }
    }

    if (__paused && __deck != undefined) {
        __deck.__playingCount++;
    }

    __paused = false;
    __manualPause = false;
    __active = true;
    __finished = false;

    __CassetteTape_HandleCallback(__onPlay);

    if (__deck != undefined) {
        if (__key != undefined) {
            // Named tape: 
            if (!variable_struct_exists(__deck.__tapesMap, __key)) {
                array_push(__deck.__tapesList, self);
                __deck.__tapesMap[$ __key] = self;
            }
        } else {
            // Anonymous tape:
            if (array_get_index(__deck.__tapesList, self) == -1) {
                array_push(__deck.__tapesList, self);
            }
        }
    }
    return self;
}
