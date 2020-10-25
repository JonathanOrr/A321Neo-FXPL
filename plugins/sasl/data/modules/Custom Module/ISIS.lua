position= {2480,1443,500,500}
size = {500, 500}

include('constants.lua')

local TIME_TO_ALIGN_SEC = 90

-- Toggle LS
sasl.registerCommandHandler (ISIS_cmd_LS, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ISIS_landing_system_enabled, get(ISIS_landing_system_enabled) == 1 and 0 or 1) end end)
sasl.registerCommandHandler (ISIS_cmd_Knob_c, 0,  function(phase) Knob_handler_up_float(phase, Stby_Baro, 28, 31, 0.01) end) 
sasl.registerCommandHandler (ISIS_cmd_Knob_cc, 0,  function(phase) Knob_handler_down_float(phase, Stby_Baro, 28, 31, 0.01) end) 


local isis_start_time = 0

function draw()
    if get(ISIS_powered) == 0 then
        return
    end
    if get(ISIS_ready) == 0 then
        -- Not ready, draw the countdown
        local remaning_time = math.ceil(TIME_TO_ALIGN_SEC - get(TIME) + isis_start_time)
        if remaning_time > 0 then
            sasl.gl.drawText (Font_AirbusDUL, 272, 112, remaning_time, 25, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        end
    else
        -- Ready, draw the altitude in meters
        local meter_alt = math.floor(get(Stby_Alt) * 0.3048)
        sasl.gl.drawText (Font_AirbusDUL, 350, 456, meter_alt, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        local baro_mmhg = Round(get(Stby_Baro),2)
        if baro_mmhg ~= 29.92 then
            local baro_kpa  = Round(33.8639 * get(Stby_Baro),0)
            sasl.gl.drawText (Font_AirbusDUL, 222, 40, string.format("%.2f", tostring(baro_kpa)) .. "/" .. string.format("%.2f", tostring(baro_mmhg)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        else
            sasl.gl.drawText (Font_AirbusDUL, 222, 40, "STD", 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        end

        if get(Adirs_capt_has_ADR) == 1 then
            -- Mach number, this is available only if the ADR for the Capt is ok
            local good_mach = Round(get(Capt_Mach) * 100, 0)
            if good_mach < 100 then
                sasl.gl.drawText (Font_AirbusDUL, 60, 40, "." .. good_mach, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            else
                sasl.gl.drawText (Font_AirbusDUL, 60, 40, good_mach/100, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)            
            end
        end
    end
end

function update()

    if (get(IAS) > 50 and get(HOT_bus_1_pwrd) == 1) or get(DC_ess_bus_pwrd) == 1 then
        set(ISIS_powered, 1)
    else
        set(ISIS_powered, 0)
        set(ISIS_ready, 0)
        isis_start_time = 0
        return
    end
    
    if isis_start_time == 0 then
        isis_start_time = get(TIME)
    end

    if get(TIME) - isis_start_time > TIME_TO_ALIGN_SEC then
        set(ISIS_ready, 1)
    else
        set(ISIS_ready, 0)
    end

end
