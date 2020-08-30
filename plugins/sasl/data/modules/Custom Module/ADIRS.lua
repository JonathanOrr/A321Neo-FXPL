----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local TIME_TO_ONBAT = 5 --five seconds before onbat light extinguishes if AC available
local TIME_TO_START_ADR = 2

local LIGHT_NORM       = 0
local LIGHT_OFF        = 1
local LIGHT_FAILED     = 10
local LIGHT_FAILED_OFF = 11

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local cmd_auto_board = sasl.findCommand("sim/operation/auto_board")  -- Prep electrical system for boarding
local cmd_auto_start = sasl.findCommand("sim/operation/auto_start")  -- Auto start aircraft
local cmd_quick_start = sasl.findCommand("sim/operation/quick_start") -- Auto start engines



local adr_time_begin = {0,0,0}
local adr_switch_status = {false,false,false}

local is_irs_att = {false, false, false}
local ir_switch_status = {false,false,false}

----------------------------------------------------------------------------------------------------
-- Registering commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ADIRS_cmd_ADR1, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_ADR2, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_ADR3, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 3) end )
sasl.registerCommandHandler (ADIRS_cmd_IR1, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_IR2, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_IR3, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 3) end )

sasl.registerCommandHandler (ADIRS_cmd_knob_1_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[1], 0, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[2], 0, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[3], 0, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_knob_1_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[1], 0, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[2], 0, 2) end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[3], 0, 2) end )

sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_up, 0,     function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_ATHDG, -1, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_down, 0,   function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_ATHDG, -1, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_up, 0,   function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1) end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1) end )

sasl.registerCommandHandler (cmd_auto_board, 0, function() adirs_prep_elec_for_boarding() end )
sasl.registerCommandHandler (cmd_auto_start, 0, function() adirs_prep_elec_for_boarding() end )
sasl.registerCommandHandler (cmd_quick_start, 0, function() adirs_prep_elec_for_boarding() end )

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function adirs_prep_elec_for_boarding()
	ADIRS_handler_toggle_ADR(SASL_COMMAND_BEGIN, 1)
	ADIRS_handler_toggle_ADR(SASL_COMMAND_BEGIN, 2)
	ADIRS_handler_toggle_ADR(SASL_COMMAND_BEGIN, 3)
	ADIRS_handler_toggle_IR(SASL_COMMAND_BEGIN, 1)
	ADIRS_handler_toggle_IR(SASL_COMMAND_BEGIN, 2)
	ADIRS_handler_toggle_IR(SASL_COMMAND_BEGIN, 3)
	
	set(ADIRS_rotary_btn[1],1)
	set(ADIRS_rotary_btn[2],1)
	set(ADIRS_rotary_btn[3],1)
	
end

local function get_time_to_align()

    --add function for linear interpolation (source: https://codea.io/talk/discussion/7448/linear-interpolation)
    function lerp(pos1, pos2, perc)
        return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
    end
    
    --set hard values for latitudes between 60 and 70.2 and 70.2 and 78.25 and interpolate for the rest
    local lat = get(Aircraft_lat)
    if lat >= 60 and lat < 70.2 then
        return 600
    elseif lat >= 70.2 and get(Aircraft_lat) <= 78.25 then
        return 1020
    elseif lat >= 0 and lat < 60  then
        return lerp(300, 600, (lat / 60))
    elseif lat <= -60 and lat > -70.2 then
        return 60
    elseif lat <= -70.2 and lat >= -78.25 then
        return 1020
    elseif lat < 0 and lat > -60 then
        return lerp(300, 600, (get(Aircraft_lat) / -60))
    else
        return nil -- Latitude is greater than 78.25- too high for IRS alignment
    end
end

local function update_status_adrs(i)

    set(Adirs_adr_is_ok[i], 0)

    if adr_switch_status[i] then
        -- ADR is on
    
        if get(ADIRS_rotary_btn[i]) > 0 then
            -- Corresponding ADRIS rotary button is NAV or ATT (doesn't matter for ADRs)

            if get(FAILURE_ADR[i]) == 1 then
                -- Failed ADR, just switch on the button
                set(ADIRS_light_ADR[i], LIGHT_FAILED)
            elseif adr_time_begin[i] > 0 then
                if get(TIME) - adr_time_begin[i] > TIME_TO_START_ADR then
                   -- After TIME_TO_START_ADR, the ADR changes the status to ON
                   set(Adirs_adr_is_ok[i], LIGHT_OFF)
                   set(ADIRS_light_ADR[i], LIGHT_NORM)
                end
            else
                -- ADIRS rotary button just switched to ATT or NAV, let's update the time
                -- of the beginning of aligmnet
                set(Adirs_total_time_to_align, get_time_to_align())
                adr_time_begin[i] = get(TIME)
                set(ADIRS_light_ADR[i], LIGHT_FAILED)
            end
        else
            adr_time_begin[i] = 0

            -- ON but no aligned
            if get(FAILURE_ADR[i]) == 1 then
                set(ADIRS_light_ADR[i], LIGHT_FAILED)
            else
                set(ADIRS_light_ADR[i], LIGHT_NORM)
            end
        end
    elseif get(FAILURE_ADR[i]) == 1 then
        -- ADR failed and switched OFF
        set(ADIRS_light_ADR[i], LIGHT_FAILED_OFF)
    else
        -- ADR switched OFF (but working)
        set(ADIRS_light_ADR[i], LIGHT_OFF)
    end    
end

local function update_status_irs(i)

    is_irs_att[i] = false

    if ir_switch_status[i] then
        -- IRS is on
    
        if get(ADIRS_rotary_btn[i]) > 0 then
            -- Corresponding ADRIS rotary button is NAV (full mode)

            if get(FAILURE_IR[i]) > 0 then
                -- Failed IRS, just switch on the button
                set(ADIRS_light_IR[i], LIGHT_FAILED)
            elseif get(Adirs_irs_begin_time[i]) > 0 then
                if get(TIME) - get(Adirs_irs_begin_time[i]) > get(Adirs_total_time_to_align) then
                    -- Align finished
                   set(Adirs_ir_is_ok,1)
                end
                set(ADIRS_light_IR[i], LIGHT_NORM)
                
                if get(TIME) - get(Adirs_irs_begin_time[i]) < TIME_TO_ONBAT then    -- TODO ADD AC/DC SWITCH
                    set(ADIRS_light_onbat, 1)
                end
                
            else
                set(Adirs_total_time_to_align, get_time_to_align())
                -- ADIRS rotary button just switched to NAV
                set(Adirs_irs_begin_time[i], get(TIME))
            end

        else
            -- ON but no aligned
            set(Adirs_irs_begin_time[i], 0)
            if get(FAILURE_IR[i]) > 0 then
                set(ADIRS_light_IR[i], LIGHT_FAILED)
            else
                set(ADIRS_light_IR[i], LIGHT_NORM)
            end
        end
        
        if get(ADIRS_rotary_btn[i]) == 2 then
            if get(Adirs_ir_is_ok) == 0 then
                is_irs_att[i] = true    -- ATT mode
            end
        end
        
    elseif get(FAILURE_IR[i]) == 1 then
        -- ADR failed and switched OFF
        set(ADIRS_light_IR[i], LIGHT_FAILED_OFF)
    else
        -- ADR switched OFF (but working)
        set(ADIRS_light_IR[i], LIGHT_OFF)
    end    
end


local function update_adrs()
    -- ADRs are quite simple:
    -- The pilot turn the rotary switch to NAV, FAULT illuminates and after 1 second the ADR is available
    -- ATT position does not affect the ADRs

    update_status_adrs(1)
    update_status_adrs(2)
    update_status_adrs(3)
    
    set(ADIRS_light_onbat, 0)

    
    update_status_irs(1)
    update_status_irs(2)
    update_status_irs(3)

end

function ADIRS_handler_toggle_ADR(phase, n)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    adr_switch_status[n] = not adr_switch_status[n]
end

function ADIRS_handler_toggle_IR(phase, n)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    ir_switch_status[n] = not ir_switch_status[n]
end

----------------------------------------------------------------------------------------------------
-- update()
----------------------------------------------------------------------------------------------------

function update ()
    
    update_adrs()
    
    -- Check if Captain and FO ADRs is ok. It depends also on the pedestal switch
    local is_capt_adr_ok = 0
    local is_fo_adr_ok = 0
     
    if (get(Adirs_adr_is_ok[1]) == 1 and get(ADIRS_source_rotary_ATHDG) ~= -1) or (get(Adirs_adr_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) == -1) then
        is_capt_adr_ok = 1
    end
    
    if (get(Adirs_adr_is_ok[2]) == 1 and get(ADIRS_source_rotary_ATHDG) ~= 1) or (get(Adirs_adr_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) ==  1) then
        is_fo_adr_ok = 1
    end
    
    set(Adirs_capt_has_ADR, is_capt_adr_ok)
    set(Adirs_fo_has_ADR, is_fo_adr_ok)

    local is_capt_irs_ok = 0
    local is_fo_irs_ok = 0
     
    if (get(Adirs_ir_is_ok[1]) == 1 and get(ADIRS_source_rotary_AIRDATA) ~= -1) or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_AIRDATA) == -1) then
        is_capt_irs_ok = 1
    end
    
    if (get(Adirs_ir_is_ok[2]) == 1 and get(ADIRS_source_rotary_AIRDATA) ~=  1) or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_AIRDATA) ==  1) then
        is_fo_irs_ok = 1
    end
    
    set(Adirs_capt_has_IR, is_capt_irs_ok)
    set(Adirs_fo_has_IR, is_fo_irs_ok)

    
end
