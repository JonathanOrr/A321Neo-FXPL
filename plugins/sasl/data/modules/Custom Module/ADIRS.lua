----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local TIME_TO_ONBAT = 5 --five seconds before onbat light extinguishes if AC available
local TIME_TO_START_ADR = 2

local LIGHT_NORM       = 0
local LIGHT_OFF        = 1
local LIGHT_FAILED     = 10
local LIGHT_FAILED_OFF = 11

local BLINKING_DATAREFS_SEC = 9

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
local cmd_auto_board = sasl.findCommand("sim/operation/auto_board")  -- Prep electrical system for boarding
local cmd_auto_start = sasl.findCommand("sim/operation/auto_start")  -- Auto start aircraft
local cmd_quick_start = sasl.findCommand("sim/operation/quick_start") -- Auto start engines
local cmd_reset_flight = sasl.findCommand("sim/operation/reset_flight") -- Reset in flight
local cmd_reset_to_runway = sasl.findCommand("sim/operation/reset_to_runway") -- Reset on runway
local cmd_go_to_default = sasl.findCommand("sim/operation/go_to_default")
local startup_running = globalProperty("sim/operation/prefs/startup_running")

local adr_time_begin = {0,0,0}
local adr_switch_status = {true,true,true}

local is_irs_att = {false, false, false}
local ir_switch_status = {true,true,true}

local ias_3_offset = math.random() * 2 - 1   -- Max offset IAS between ADR1/2 and ADR3: +1/-1
local alt_3_offset = math.random() * 20 - 10 -- Max offset Altitude between ADR1/2 and ADR3: +10/-10

local blinkers_data = {
    {started_to_blink=0, dataref=Adirs_capt_has_ADR_blink, inactive_value=1, active_value=0,active=false},
    {started_to_blink=0, dataref=Adirs_capt_has_IR_blink,  inactive_value=2, active_value=0,active=false},
    {started_to_blink=0, dataref=Adirs_fo_has_ADR_blink,   inactive_value=1, active_value=0,active=false},
    {started_to_blink=0, dataref=Adirs_fo_has_IR_blink,    inactive_value=2, active_value=0,active=false}
}   -- Used for blinking datarefs, to know when a dataref started to blink


----------------------------------------------------------------------------------------------------
-- Custom commands (internal only, refers to cockpit_commands.lua for switch commands
----------------------------------------------------------------------------------------------------
ADIRS_cmd_instantaneous_align     = createCommand("a321neo/cockpit/ADIRS/instantaneous_align", "Move right the knob")

----------------------------------------------------------------------------------------------------
-- Registering commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ADIRS_cmd_ADR1, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_ADR2, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_ADR3, 0, function(phase) ADIRS_handler_toggle_ADR(phase, 3); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR1, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR2, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR3, 0,  function(phase) ADIRS_handler_toggle_IR(phase, 3); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_knob_1_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[1], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[2], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_up, 0,   function(phase)  Knob_handler_up_int(phase, ADIRS_rotary_btn[3], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_1_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[1], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[2], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_rotary_btn[3], 0, 2); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_up, 0,     function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_ATHDG, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_down, 0,   function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_ATHDG, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_up, 0,   function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1); return 1 end )

sasl.registerCommandHandler (cmd_auto_board, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )
sasl.registerCommandHandler (cmd_auto_start, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )
sasl.registerCommandHandler (cmd_quick_start, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )
sasl.registerCommandHandler (cmd_reset_flight, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )
sasl.registerCommandHandler (cmd_reset_to_runway, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )
sasl.registerCommandHandler (cmd_go_to_default, 0, function(phase) adirs_prep_elec_for_boarding(phase); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_instantaneous_align, 0, function(phase) adirst_inst_align(phase); return 1 end )

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function adirs_prep_elec_for_boarding(phase) 
    if phase == SASL_COMMAND_BEGIN then
	    adr_switch_status[1] = true
	    adr_switch_status[2] = true
	    adr_switch_status[3] = true
	    ir_switch_status[1] = true
	    ir_switch_status[2] = true
	    ir_switch_status[3] = true
       
	    set(ADIRS_rotary_btn[1],1)
	    set(ADIRS_rotary_btn[2],1)
	    set(ADIRS_rotary_btn[3],1)
	    
	    adr_time_begin[1] = get(TIME) - TIME_TO_START_ADR - 2
	    adr_time_begin[2] = get(TIME) - TIME_TO_START_ADR - 2
	    adr_time_begin[3] = get(TIME) - TIME_TO_START_ADR - 2

        set(Adirs_irs_begin_time[1], get(TIME) - 2)
        set(Adirs_irs_begin_time[2], get(TIME) - 2)
        set(Adirs_irs_begin_time[3], get(TIME) - 2)
        set(Adirs_total_time_to_align, 1)

    end	

end

function adirst_inst_align(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
   set(Adirs_total_time_to_align, 1)
   set(Adirs_irs_begin_time[1], get(TIME) - 2)
   set(Adirs_irs_begin_time[2], get(TIME) - 2)
   set(Adirs_irs_begin_time[3], get(TIME) - 2)
    
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
                set(ADIRS_light_ADR[i], LIGHT_NORM)
                if get(TIME) - adr_time_begin[i] > TIME_TO_START_ADR then
                   -- After TIME_TO_START_ADR, the ADR changes the status to ON
                   set(Adirs_adr_is_ok[i], 1)
                end
            else
                -- ADIRS rotary button just switched to ATT or NAV, let's update the time
                -- of the beginning of aligmnet
                set(Adirs_total_time_to_align, get_time_to_align())
                adr_time_begin[i] = get(TIME)
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
    set(Adirs_ir_is_ok[i],0)

    if ir_switch_status[i] then
        -- IRS is on
    
        if get(ADIRS_rotary_btn[i]) > 0 then
            -- Corresponding ADRIS rotary button is NAV (full mode)

            if get(FAILURE_IR[i]) > 0 then
                -- Failed IRS, just switch on the button
                set(ADIRS_light_IR[i], LIGHT_FAILED)
            elseif get(Adirs_irs_begin_time[i]) ~= 0 then
                if get(TIME) - get(Adirs_irs_begin_time[i]) > get(Adirs_total_time_to_align) then
                    -- Align finished
                   set(Adirs_ir_is_ok[i],1)
                end
                
                if get(TIME) - get(Adirs_irs_begin_time[i]) > 0.3 then
                    set(ADIRS_light_IR[i], LIGHT_NORM)
                else
                    set(ADIRS_light_IR[i], LIGHT_FAILED)                
                end
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
            if get(Adirs_ir_is_ok[i]) == 0 then
                is_irs_att[i] = true    -- ATT mode
            end
        end
        
    elseif get(FAILURE_IR[i]) == 1 then
        -- ADR failed and switched OFF
        set(ADIRS_light_IR[i], LIGHT_FAILED_OFF)
        set(Adirs_irs_begin_time[i], 0)
    else
        -- ADR switched OFF (but working)
        set(ADIRS_light_IR[i], LIGHT_OFF)
        set(Adirs_irs_begin_time[i], 0)
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

local function blink_dataref(blink_data)

    -- Blinking the datarefs for the PFD follows this procedure:
    -- - Every time an ADIRS error occurs, the corresponding datareg starts to blink
    -- - It blinks for 9 seconds, then it stops

    if not blink_data.active then   -- Just set inactive value and exit
        blink_data.started_to_blink = 0
        set(blink_data.dataref, blink_data.active_value)
        return
    end
    
    if blink_data.started_to_blink == 0 then    -- First time it starts to blink
        blink_data.started_to_blink = get(TIME)
    end
    
    if get(TIME) - blink_data.started_to_blink < BLINKING_DATAREFS_SEC then
        -- Ok let's blink
        if math.floor(get(TIME)*2) % 2 == 0 then
            -- Blink every 1 second (500ms off, 500ms on
            set(blink_data.dataref, blink_data.active_value)
        else
            set(blink_data.dataref, blink_data.inactive_value)
        end
    else
        -- Time elapsed -> steady state
        set(blink_data.dataref, blink_data.active_value)
    end

end

local function update_status_datarefs(is_capt_adr_ok, is_fo_adr_ok, is_capt_irs_ok, is_fo_irs_ok)

    -- Update the status
    -- - ADR has 1 status: OFF (0) or ON (1)
    -- - IR has 2 statuses: OFF (0) or ATT/HDG only (1) or OK (2)
    set(Adirs_capt_has_ADR, is_capt_adr_ok)
    set(Adirs_fo_has_ADR, is_fo_adr_ok)
    set(Adirs_capt_has_IR, is_capt_irs_ok)
    set(Adirs_fo_has_IR, is_fo_irs_ok)

    -- Let's update the blinking datarefs: they are needed for the PFD in order to blink the
    -- static parts not coded in LUA
    blinkers_data[1].active       = is_capt_adr_ok ~= 1
    blinkers_data[1].active_value = is_capt_adr_ok
    blinkers_data[2].active       = is_capt_irs_ok ~= 2
    blinkers_data[2].active_value = is_capt_irs_ok
    blinkers_data[3].active       = is_fo_adr_ok ~= 1
    blinkers_data[3].active_value = is_fo_adr_ok
    blinkers_data[4].active       = is_fo_irs_ok ~= 2
    blinkers_data[4].active_value = is_fo_irs_ok
    
    blink_dataref(blinkers_data[1]) -- Adirs_capt_has_ADR_blink
    blink_dataref(blinkers_data[2]) -- Adirs_capt_has_IR_blink
    blink_dataref(blinkers_data[3]) -- Adirs_fo_has_ADR_blink
    blink_dataref(blinkers_data[4]) -- Adirs_fo_has_IR_blink

end

local function update_output_datarefs()

    local orig_capt_ias = get(Capt_IAS)
    local orig_fo_ias   = get(Fo_IAS)
    local orig_capt_alt = get(Capt_Baro_Alt)
    local orig_fo_alt  = get(Fo_Baro_Alt)
    local orig_capt_vs  = get(Capt_VVI)
    local orig_fo_vs    = get(Fo_VVI)
    
    
    if get(ADIRS_source_rotary_AIRDATA) ~= -1 then
        -- IR1 used for capt
        set(PFD_Capt_IAS, orig_capt_ias)
        set(PFD_Capt_Baro_Altitude, orig_capt_alt)
    else
        -- IR3 used for capt
        set(PFD_Capt_IAS, orig_capt_ias + ias_3_offset)
        set(PFD_Capt_Baro_Altitude, orig_capt_alt + alt_3_offset)
    end
    set(PFD_Capt_VS, math.floor(orig_capt_vs+0.5))

    if get(ADIRS_source_rotary_AIRDATA) ~= 1 then
        -- IR1 used for capt
        set(PFD_Fo_IAS, orig_fo_ias)
        set(PFD_Fo_Baro_Altitude, orig_fo_alt)
    else
        -- IR3 used for Fo
        set(PFD_Fo_IAS, orig_fo_ias + ias_3_offset)
        set(PFD_Fo_Baro_Altitude, orig_fo_alt + alt_3_offset)
    end
    set(PFD_Fo_VS, math.floor(orig_fo_vs+0.5))


end

----------------------------------------------------------------------------------------------------
-- update()
----------------------------------------------------------------------------------------------------

function update ()
    
    update_adrs()
    
    -- Check if Captain and FO ADRs are ok. It depends also on the pedestal switch
    local is_capt_adr_ok = 0
    local is_fo_adr_ok = 0
     
    if (get(Adirs_adr_is_ok[1]) == 1 and get(ADIRS_source_rotary_AIRDATA) ~= -1) or (get(Adirs_adr_is_ok[3]) == 1 and get(ADIRS_source_rotary_AIRDATA) == -1) then
        is_capt_adr_ok = 1
    end
    
    if (get(Adirs_adr_is_ok[2]) == 1 and get(ADIRS_source_rotary_AIRDATA) ~= 1) or (get(Adirs_adr_is_ok[3]) == 1 and get(ADIRS_source_rotary_AIRDATA) ==  1) then
        is_fo_adr_ok = 1
    end

    -- Check if Captain and FO IRs are ok. It depends also on the pedestal switch
    local is_capt_irs_ok = 0
    local is_fo_irs_ok = 0
     
    if (get(Adirs_ir_is_ok[1]) == 1 and get(ADIRS_source_rotary_ATHDG) ~= -1) or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) == -1) then
        is_capt_irs_ok = 2
    end
    
    if (get(Adirs_ir_is_ok[2]) == 1 and get(ADIRS_source_rotary_ATHDG) ~=  1) or (get(Adirs_ir_is_ok[3]) == 1 and get(ADIRS_source_rotary_ATHDG) ==  1) then
        is_fo_irs_ok = 2
    end
    
    if (is_irs_att[1] and get(ADIRS_source_rotary_ATHDG) ~= -1) or (is_irs_att[3] and get(ADIRS_source_rotary_ATHDG) == -1) then
        is_capt_irs_ok = 1
    end
    if (is_irs_att[2] and get(ADIRS_source_rotary_ATHDG) ~= -1) or (is_irs_att[3] and get(ADIRS_source_rotary_ATHDG) == 1) then
        is_fo_irs_ok = 1
    end

    update_status_datarefs(is_capt_adr_ok, is_fo_adr_ok, is_capt_irs_ok, is_fo_irs_ok)

    update_output_datarefs()
    
end
