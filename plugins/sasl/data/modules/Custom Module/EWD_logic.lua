include('ECAM_status.lua')
include('EWD_flight_phases.lua')
include('EWD_msgs/adirs.lua')
include('EWD_msgs/bleed.lua')
include('EWD_msgs/brakes_and_antiskid.lua')
include('EWD_msgs/doors.lua')
include('EWD_msgs/electrical.lua')
include('EWD_msgs/engines_and_apu.lua')
include('EWD_msgs/FBW.lua')
include('EWD_msgs/flight_controls.lua')
include('EWD_msgs/fuel.lua')
include('EWD_msgs/gears_and_doors.lua')
include('EWD_msgs/hydraulic.lua')
include('EWD_msgs/misc.lua')
include('EWD_msgs/nav.lua')
include('EWD_msgs/to_ldg_memos.lua')

sasl.registerCommandHandler (Ecam_btn_cmd_CLR,   0 , function(phase) ewd_clear_button_handler(phase) end )
sasl.registerCommandHandler (Ecam_btn_cmd_RCL,   0 , function(phase) ewd_recall_button_handler(phase) end )
sasl.registerCommandHandler (Ecam_btn_cmd_EMERC, 0 , function(phase) ewd_emercanc_button_handler(phase) end )
sasl.registerCommandHandler (Ecam_btn_cmd_TOCFG, 0 , function(phase) ewd_tocfg_button_handler(phase) end )

local STARTUP_WAIT_SECS = 10 -- Startup delay
local MIN_TIME_FOR_DISPLAY = 1 -- Min time a failure must be active to be displayed in seconds

--colors
local COL_INVISIBLE = 0    
local COL_WARNING = 1       -- RED
local COL_SPECIAL = 2       -- MAGENTA
local COL_CAUTION = 3       -- AMBER
local COL_INDICATION = 4    -- GREEN
local COL_REMARKS = 5       -- WHITE
local COL_ACTIONS = 6       -- BLUE
local COL_INDICATION_BLINKING = 7    -- GREEN (blinking) - right part only

--initialisation--
for i=0,6 do
    set(EWD_left_memo[i], "LINE " .. i)
    set(EWD_left_memo_colors[i], COL_INVISIBLE)
end
for i=0,6 do
    set(EWD_right_memo[i], "LINE " .. i)
    set(EWD_right_memo_colors[i], COL_INVISIBLE)
end

-- Variables
local sim_loaded_at = 0 -- Time the sim it was re-loaded, see onAirportLoaded()

-- This is the list of triggerable messages for the left. When a message is cleared with CLR, the
-- message is removed from the list and moved to the next list "left_messages_list_cleared"
local left_messages_list = {
    -- Normal messages
    MessageGroup_GND_SPEEDBRAKES,
    MessageGroup_SEAT_BELTS,
    MessageGroup_NO_SMOKING,
    MessageGroup_IRS_ALIGN,
    MessageGroup_REFUELG,
    MessageGroup_NORMAL,

    -- Cautions
    MessageGroup_FBW_ALTN_DIRECT_LAW,
    MessageGroup_BRAKES_HOT,
    MessageGroup_ADKIS_NWS,
    MessageGroup_APU_SHUTDOWN,
    MessageGroup_GEAR_NOT_UPLOCKED,
    MessageGroup_BLEED_OFF,
    MessageGroup_TCAS_FAULT,
    MessageGroup_ADR_FAULT_SINGLE,
    MessageGroup_ADR_FAULT_DOUBLE,
    MessageGroup_IR_FAULT_SINGLE,
    MessageGroup_IR_FAULT_DOUBLE,
    MessageGroup_HYD_G_RSVR_LO_LVL,
    MessageGroup_HYD_B_RSVR_LO_LVL,
    MessageGroup_HYD_Y_RSVR_LO_LVL,
    MessageGroup_HYD_G_ENG1_PUMP_LO_PR,
    MessageGroup_HYD_B_ELEC_PUMP_LO_PR,
    MessageGroup_HYD_Y_ENG2_PUMP_LO_PR,
    MessageGroup_HYD_ELEC_PUMP_Y_FAIL,
    MessageGroup_HYD_ELEC_PUMP_B_OVHT,
    MessageGroup_HYD_ELEC_PUMP_Y_OVHT,
    MessageGroup_HYD_G_RSVR_OVHT,
    MessageGroup_HYD_B_RSVR_OVHT,
    MessageGroup_HYD_Y_RSVR_OVHT,
    MessageGroup_HYD_B_RSVR_LO_AIR_PRESS,
    MessageGroup_HYD_G_RSVR_LO_AIR_PRESS,
    MessageGroup_HYD_Y_RSVR_LO_AIR_PRESS,
    MessageGroup_HYD_B_SYS_LO_PR,
    MessageGroup_HYD_G_SYS_LO_PR,
    MessageGroup_HYD_Y_SYS_LO_PR,
    MessageGroup_HYD_RAT_FAULT,
    MessageGroup_HYD_PTU_FAULT,
    MessageGroup_ELEC_AC_BUS_1_FAULT,
    MessageGroup_ELEC_AC_BUS_2_FAULT,
    MessageGroup_ELEC_AC_BUS_ESS_FAULT,
    MessageGroup_ELEC_AC_BUS_ESS_SHED_FAULT,
    MessageGroup_ELEC_DC_EMER_CONFIG,
    MessageGroup_ELEC_DC_ESS_BUS_FAULT,
    MessageGroup_ELEC_DC_ESS_BUS_SHED,
    MessageGroup_ELEC_DC_BUS_1_FAULT,
    MessageGroup_ELEC_DC_BUS_2_FAULT,
    MessageGroup_ELEC_DC_BUS_1_2_FAULT,
    MessageGroup_ELEC_DC_BAT_BUS_FAULT,
    MessageGroup_ELEC_IDG_LO_PR,
    MessageGroup_ELEC_IDG_OVHT,
    MessageGroup_ELEC_GEN_FAULT,
    MessageGroup_ELEC_GEN_OFF,
    MessageGroup_ELEC_APU_GEN_FAULT,
    MessageGroup_ELEC_BAT_OFF,
    MessageGroup_ELEC_BAT_FAULT,
    MessageGroup_ELEC_EMER_GEN_1_LINE_OFF,
    MessageGroup_ELEC_STATIC_INV_FAULT,
    MessageGroup_ELEC_TR_1_2_FAULT,
    MessageGroup_ELEC_TR_ESS_FAULT,
    MessageGroup_ENG_FF_CLOG,
    MessageGroup_ENG_OIL_CLOG,
    MessageGroup_FUEL_WING_LO_LVL_DOUBLE,
    MessageGroup_FUEL_WING_LO_LVL_SINGLE,
    MessageGroup_FUEL_FUSED_FOB_DISAGREE,
    MessageGroup_FUEL_LR_OVERFLOW,
    MessageGroup_FUEL_L_TK_1_OR_2_PUMP_FAULT,
    MessageGroup_FUEL_R_TK_1_OR_2_PUMP_FAULT,
    MessageGroup_FUEL_L_TK_1_AND_2_PUMP_FAULT,
    MessageGroup_FUEL_R_TK_1_AND_2_PUMP_FAULT,
    MessageGroup_FUEL_C_TK_XFR_LO_PR_DOUBLE,
    MessageGroup_FUEL_C_TK_XFR_LO_PR_SINGLE,
    MessageGroup_FUEL_ACT_LO_PR_XFR_FAULT,
    MessageGroup_FUEL_RCT_LO_PR_XFR_FAULT,
    MessageGroup_FUEL_LR_HI_TEMP,
    MessageGroup_FUEL_LR_LO_TEMP,
    MessageGroup_FUEL_AUTO_FEED_FAULT,
    MessageGroup_FUEL_ACT_AUTO_XFR_FAULT,
    MessageGroup_FUEL_RCT_AUTO_XFR_FAULT,
    MessageGroup_FUEL_C_TK_XFR_OFF,
    MessageGroup_FUEL_L_TK_PUMP_OFF,
    MessageGroup_FUEL_R_TK_PUMP_OFF,
    MessageGroup_FUEL_ENG_1_2_VALVE_FAULT,
    MessageGroup_FUEL_X_FEED_VALVE_FAULT,
    MessageGroup_FUEL_APU_VALVE_FAULT,
    MessageGroup_FUEL_FQI_1_2_FAULT,
    MessageGroup_DOORS_CABIN,
    MessageGroup_DOORS_CARGO,
    MessageGroup_DOORS_EMER_EXIT,
    
    -- Warnings
    MessageGroup_CONFIG_TAKEOFF,
    MessageGroup_APU_FIRE,
    MessageGroup_GEAR_NOT_DOWNLOCKED,
    MessageGroup_GEAR_NOT_DOWN,
    MessageGroup_HYD_B_AND_Y_LO_PR,
    MessageGroup_HYD_G_AND_B_LO_PR,
    MessageGroup_HYD_G_AND_Y_LO_PR,
    MessageGroup_ADR_FAULT_TRIPLE,
    MessageGroup_IR_FAULT_TRIPLE,
    MessageGroup_ELEC_EMER_CONFIG,
    MessageGroup_ELEC_ESS_BUSES_ON_BAT,
    
    -- Misc
    MessageGroup_MEMO_TAKEOFF,
    MessageGroup_MEMO_LANDING,
    MessageGroup_TOCONFIG_NORMAL -- This must be the last message
}

local left_messages_list_cleared = {    -- List of message cleared with CLR

}


_G.ewd_left_messages_list_cancelled = {  -- List of message cancelled with EMER CANC 
                                         -- (this is in the global table because we need to access from other files)
                                         -- Not the cleanest way, but it is an effective small solution

}


local left_current_message = nil;   -- It contains (if exists) the first message group *clearable*
local left_was_clearing = false     -- True when a warning/caution message exists and status page not yet displayed
local land_asap = false;            -- If true, the LAND ASAP message appears (according to flight phase)

local rcl_start_press_time = 0;     -- The time the user started to press RCL button (this is needed to compute how many seconds elapsed for a long-press)
local flight_phase_not_one = false; -- See function check_reset() 

-- PriorityQueue external implementation (modified)
-- Source: https://rosettacode.org/wiki/Priority_queue#Lua
-- License: GNU Free Documentation License 1.2
-- This is basically a normal priority queue. You can use object:put(priority, content) and
-- then you can pop to get the data sorted by priority and insertion order. 
PriorityQueue = {
    __index = {
        put = function(self, p, v)
            local q = self[p]
            if not q then
                q = {first = 1, last = 0}
                self[p] = q
            end
            q.last = q.last + 1
            q[q.last] = v
        end,
        pop = function(self)
          continue = true
          while continue do
            continue = false
            for p, q in pairs(self) do
                if q.first <= q.last then
                    local v = q[q.first]
                    q[q.first] = nil
                    q.first = q.first + 1
                    if v then
                        return p, v
                    else
                      continue = true
                      break
                    end
                else
                    self[p] = nil
                end
            end
          end
        end,
        setmax = function(self, n)
            for i=1,n do
                self:put(i, nil)
            end 
        end
    },
    __call = function(cls)
        return setmetatable({}, cls)
    end
}

setmetatable(PriorityQueue, PriorityQueue)

function onAirportLoaded()  -- We need to wait some seconds before processing EWD messages from the sim
                            -- start, especially when the flight is started in flight and not on ground.
    sim_loaded_at = get(TIME)
end

-- 

local list_right = PriorityQueue()
local list_left  = PriorityQueue()

--
-- RIGHT side of the EWD messages
--
-- This works as a simple priority queue, color is the priority
local function update_right_list()

    -- Let's clear the priority queue
    list_right = PriorityQueue()
    list_right:setmax(PRIORITY_LEVEL_MEMO)

    -- Land ASAP    
    if land_asap and get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_TOUCHDOWN then
        list_right:put(COL_WARNING, "LAND ASAP")
    end

    -- Initbition messages, these are always triggered when the related modes are actives
    if get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS or get(EWD_flight_phase) == PHASE_LIFTOFF then
        list_right:put(COL_SPECIAL, "T.O INHIBIT")
    end
    if get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_TOUCHDOWN then
        list_right:put(COL_SPECIAL, "LDG INHIBIT")
    end

    -- APU
    if get(Apu_bleed_switch) == 1 then
        list_right:put(COL_INDICATION, "APU BLEED")
    elseif get(Apu_avail) == 1 then
        list_right:put(COL_INDICATION, "APU AVAIL")
    end 

    -- Brakes
    if get(Brakes_fan) == 1 then
        list_right:put(COL_INDICATION, "BRK FAN")
    end

    if get(Actual_brake_ratio) > 0 then
        if get(EWD_flight_phase) < PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) > PHASE_TOUCHDOWN
        then
            list_right:put(COL_INDICATION, "PARK BRK")
        end
        if get(EWD_flight_phase) >= PHASE_ABOVE_80_KTS and get(EWD_flight_phase) <= PHASE_TOUCHDOWN
        then
            list_right:put(COL_CAUTION, "PARK BRK")
        end
    end

    -- Speedbrakes
    if get(Speedbrake_handle_ratio) > 0 then
    
        if get(EWD_flight_phase) >= PHASE_LIFTOFF and get(EWD_flight_phase) <= PHASE_TOUCHDOWN then
            if get(Eng_1_N1) > 50 or get(Eng_2_N1) > 50 then
                list_right:put(COL_CAUTION, "SPEED BRK")
            else
                list_right:put(COL_INDICATION, "SPEED BRK")        
            end
        end
    end

    if get(Eng_Continuous_Ignition) == 1 then
        list_right:put(COL_INDICATION, "IGNITION")
    end
    

    if get(Autobrakes_sim) == 2 then
        list_right:put(COL_INDICATION, "AUTO BRK LO")
    elseif get(Autobrakes_sim) == 4 then
        list_right:put(COL_INDICATION, "AUTO BRK MED")
    elseif get(Autobrakes_sim) == 0 then
        list_right:put(COL_INDICATION, "AUTO BRK MAX")
    end

    -- HYD & ELEC
    if get(Hydraulic_RAT_status) > 0 then
        list_right:put(COL_INDICATION, "RAT OUT")
    end
    if get(Hydraulic_PTU_status) > 1 then
        list_right:put(COL_INDICATION, "HYD PTU")
    end
    if get(Gen_EMER_pwr) == 1 then
        list_right:put(COL_INDICATION, "EMERG GEN")
    end

    -- TCAS
    if get(DRAIMS_Sqwk_mode) < 2 then
        list_right:put(COL_INDICATION, "TCAS STBY")
    elseif get(DRAIMS_Sqwk_mode) == 2 then
        list_right:put(COL_INDICATION, "TCAS TA ONLY")
    end
    
    -- ACARS
    if get(Acars_status) == 0 then
        list_right:put(COL_INDICATION, "ACARS STBY")
    end
    
    if get(DCDU_new_msgs) ~= 0 then
        list_right:put(COL_INDICATION_BLINKING, "ACARS MSG")    
    end
    
    if get(VHF_3_monitor_selected) == 1 then
        list_right:put(COL_INDICATION_BLINKING, "VHF 3 VOICE")    
    end
    
    if get(Ecam_fuel_valve_X_BLEED) < 2 or get(Ecam_fuel_valve_X_BLEED) == 4 then
        local is_amber = get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR 
                      or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS 
                      or get(EWD_flight_phase) == PHASE_LIFTOFF 
        
        list_right:put(is_amber and COL_CAUTION or COL_INDICATION, "FUEL X FEED")
    end
    
    if Fuel_sys.tank_pump_and_xfr[5].pressure_ok or Fuel_sys.tank_pump_and_xfr[6].pressure_ok then
        list_right:put(COL_INDICATION, "CTR TK XFRD")
    end
    if Fuel_sys.tank_pump_and_xfr[7].pressure_ok then
        list_right:put(COL_INDICATION, "ACT TK XFRD")
    end
    if Fuel_sys.tank_pump_and_xfr[8].pressure_ok then
        list_right:put(COL_INDICATION, "RCT TK XFRD")
    end
    
    if get(Eng_Dual_Cooling) == 1 then
        list_right:put(COL_INDICATION, "DUAL COOLING")
    end
    
    -- ANTI-ICE (it is correct that they use the button status and not the actual anti-ice status)
    if get(AI_Eng_1_button_light) % 2 == 1 or get(AI_Eng_2_button_light) % 2 == 1 then
        list_right:put(COL_INDICATION, "ENG A. ICE")
    end

    if get(AI_Wing_button_light) % 2 == 1 then
        list_right:put(COL_INDICATION, "WING A. ICE")
    end
    
    if get(No_ice_detected) == 1 then
        list_right:put(COL_INDICATION, "ICE NOT DET")
    end
    
    -- TODO Audio: AUDIO 3 XFRD displayed green if audio switching selector not in NORM
    -- TODO Acars: ACARS CALL (pulsing green) if received an ACARS message requesting voice conversation

    -- TODO Autobrake fail: AUTO BRK OFF (any flight phase, amber)

    -- TODO RAM Air: RAM AIR ON green if related pushbutton switch is ON
    -- TODO Pressurization: MAN LDG ELEV green if LDG ELEV switch is not in AUTO

    -- TODO Steer: NW STRG DISC when the nose wheel steering selector is in the towing position
    --             GREEN: if no engine is running, AMBER: is at least one engine is running
       
    -- TODO windshear: PRED W/S OFF if windshear (weather panel) is selected OFF
    --                  green in phases 1,2,6,10
    --                  amber in phases 3,4,5,7,8,9
    --                  not present in 6

    -- TODO GPWS: GPWS FLAP 3 in green if related pushbutton is ON
    -- TODO GPWS: GPWS FLAP MODE OFF in green if related pushbutton is OFF
    -- TODO GPWS: TERR STBY in green if position is too inaccurate to show terrain on ND

    -- TODO Lights: LDG LT
    -- TODO Lights: STROBE LT OFF (green) - in flight only
    

end

local function publish_right_list()
    local limit = false
    tot_messages = 0

    for prio,msg in list_right.pop, list_right do
        -- We extract all the messages in order of priority and insertion order
        -- and we set the corresponding messages until the memo is full

        if limit then
            set(EWD_arrow_overflow, 1)  -- Let's display the overflow arrow
            break
        end
        
        set(EWD_right_memo[tot_messages], msg)
        set(EWD_right_memo_colors[tot_messages], prio)
        
        
        tot_messages = tot_messages + 1
        if tot_messages >= 7 then
            limit = true
        end 
    end

    for i=tot_messages, 7 do    -- Let's print some blank spaces if few lines are showed
        set(EWD_right_memo[i], "")
        set(EWD_right_memo_colors[i], COL_INVISIBLE)
    end

end

--
-- LEFT side of the EWD messages
--
-- In this case we cannot use a simple priority queue, because sub-messages are present and
-- may be of different colors. According to airbus specification, there are 3 levels of warning
-- messages (1,2,3) that establish the priority


local function update_left_list()

    if get(EWD_flight_phase) == 0 then  -- Don't update EWD is the flight phase is unknown. This should not happen.
        return
    end

    list_left  = PriorityQueue()
    list_left:setmax(PRIORITY_LEVEL_MEMO)

    for i, m in ipairs(left_messages_list) do
        if (m.is_active() and (not m.is_inhibited())) then
            if not m.shown then
            
                if m.begin_time == nil then
                    m.begin_time = get(TIME)
                elseif get(TIME) - m.begin_time > MIN_TIME_FOR_DISPLAY then
            
                    m.shown = true
                    if m.color() == COL_WARNING then
                        set(ReqMasterWarning, 1)
                    end
                    if m.color() == COL_CAUTION then
                        set(ReqMasterCaution, 1)
                    end 
                end
            end
        end    
        if not m.is_active() then
            m.shown = false
            m.begin_time = nil
        end

        if m.shown then
            -- This may happend for two reasons:
            -- - the condition of the if at the beginning of this loop is true
            -- - the message has been activated in a previous flight phase and consequently still
            --   visible.
            list_left:put(m.priority, m) 

            if m.land_asap ~= nil and m.land_asap == true then
                land_asap = true
            end
        end
    end

end

local function publish_left_list()
    local tot_messages = 0
    local limit = false

    left_current_message = nil;
    set(Ecam_EDW_requested_page, 0)

    for i=0, 7 do
        set(EWD_left_memo_group[i], "")
        set(EWD_left_memo_group_colors[i], COL_INVISIBLE)
    end


    for prio, msg in list_left.pop, list_left do
        if limit then                   -- Extra message not shown
            set(EWD_arrow_overflow, 1)  -- Let's display the overflow arrow
            break
        end
        
        if left_current_message == nil and (msg.color() == COL_WARNING or msg.color() == COL_CAUTION) then
            -- This is the first clearable message, we save it to clear it later with the CLR pushbutton
            -- see also the function ewd_clear_button_handler
            left_current_message = msg
        end  

        if tot_messages == 0 or msg.priority ~= PRIORITY_LEVEL_MEMO then  -- Ignore the MEMO if other messages are present

            -- Set the name of the group
            set(EWD_left_memo_group[tot_messages], msg.text())
            set(EWD_left_memo_group_colors[tot_messages], msg.color())

            for i,m in ipairs(msg.messages) do
                if limit then                   -- Extra message not shown
                    set(EWD_arrow_overflow, 1)  -- Let's display the overflow arrow
                    break
                end
                if m.is_active() then
                    set(EWD_left_memo[tot_messages], m.text())
                    set(EWD_left_memo_colors[tot_messages], m.color())        
                    tot_messages = tot_messages + 1
                    if tot_messages >= 7 then
                        limit = true
                    end
                end 
            end
        end        
    end
    
    for i=tot_messages, 7 do
        set(EWD_left_memo[i], "")
        set(EWD_left_memo_colors[i], COL_INVISIBLE)
    end
    
    -- Update the ECAM requested page (if necessary)
    if left_current_message ~= nil then
        set(EWD_is_clerable, 1)
        if left_current_message.sd_page ~= nil then
            -- ECAM page change request
            -- We put this number of the dataref
            set(Ecam_EDW_requested_page, left_current_message.sd_page)
        end
        if get(TO_Config_is_pressed) == 0 then
            left_was_clearing = true
        end
    else
        set(EWD_is_clerable, 0)
        if left_was_clearing then
            
            -- We cleared all the pages, so, let's display the STATUS page for clearing it
            set(Ecam_is_sts_clearable, 1)
            set(Ecam_EDW_requested_page, ECAM_PAGE_STS)
            left_was_clearing = false
        end
    end
    
    

end

-- This function checks if any message in the cleared list has been
-- deactivated, in that case, we move it back to the original list
-- so that, if retriggered, it will be showed again
local function check_cleared_list()

    -- Let's loop backward so that the remove of the item of the table is safe
    for i=#left_messages_list_cleared,1,-1 do
        if not left_messages_list_cleared[i].is_active() then
            table.insert(left_messages_list, left_messages_list_cleared[i])
            table.remove(left_messages_list_cleared, i)
        end
    end

end

local function restore_cancelled_messages(show_normal)
    if #_G.ewd_left_messages_list_cancelled == 0 and show_normal then
        set(EWD_show_normal, get(TIME)) 
    end

    for i,msg in ipairs(_G.ewd_left_messages_list_cancelled) do
        table.insert(left_messages_list, msg)
    end

    _G.ewd_left_messages_list_cancelled = {}            
end

-- This function check if the flight phase is move from X to 1, that means that a reset occurs
-- (restart of the flight, or 5 minutes after engine shutdown occurs). In this case, we need to
-- re-enable all the cancelled cautions (according to FCOM)
local function check_reset()
    if not flight_phase_not_one then
        if get(EWD_flight_phase) >= 2 and get(TO_Config_is_pressed) == 0 then
            flight_phase_not_one = true
        end
    elseif get(EWD_flight_phase) == 1 then
        -- Reset occurred
        flight_phase_not_one = false
        restore_cancelled_messages(false)
    end
end

function update()

    if get(TIME) - sim_loaded_at < STARTUP_WAIT_SECS then
        return -- Wait some seconds before generates EWD messages
    end

    if get(AC_ess_bus_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.2, 0.2)
    elseif get(AC_bus_1_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.2, 0.2)
    elseif get(AC_bus_2_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.2, 0.2)
    else
        return -- No power
    end

    set(EWD_arrow_overflow, 0)
    update_left_list()
    publish_left_list()
    update_right_list()
    publish_right_list()
    
    check_cleared_list()
    check_reset()
end

function ewd_clear_button_handler(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    if left_current_message == nil then
        return  -- Nothing to clear
    end

    if get(Ecam_is_sts_clearable) == 1 then
        return  -- STS is clearable, CLR should not affect EWD
    end
    
    -- Ok, we have a message, and STS page is not clearable.
    -- Let's search and move the message to the list of cleared message
    for i, m in ipairs(left_messages_list) do
        if m == left_current_message then
            table.insert(left_messages_list_cleared, m)
            table.remove(left_messages_list, i)
            return
        end
    end
    
    print("ERROR: This should not happend, clearing a non-existent message.")
    
end

function ewd_recall_button_handler(phase)
    if phase == SASL_COMMAND_BEGIN then
        rcl_start_press_time = get(TIME)
        return
    end

    if phase == SASL_COMMAND_END then

        if get(TIME) - rcl_start_press_time <= 3 then
        
            -- This is a short-press RCL -> it restores the cleared messages (but not the emerg cancelled messages)
        
            if #left_messages_list_cleared == 0 then
                set(EWD_show_normal, get(TIME)) 
            end

            -- Move back all the messages from the cleared list to the normal list
            for i,msg in ipairs(left_messages_list_cleared) do
                table.insert(left_messages_list, msg)
            end

            left_messages_list_cleared = {}            
        
        end
    end

    if rcl_start_press_time ~= 0 and (get(TIME) - rcl_start_press_time >= 3) then
        rcl_start_press_time = 0
        
        -- This is a long-press RCL -> it restores the emerg cancelled messages
        restore_cancelled_messages(true)
        
    end
    
end

function ewd_emercanc_button_handler(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    if left_current_message == nil then
        return  -- Nothing to cancel
    end

    if left_current_message.color() == COL_WARNING then
        return  -- Warning cannot be de-activated (canceled for the remainer of the flight)
    end
    
    -- Ok, we have a message, and STS page is not clearable.
    -- Let's search and move the message to the list of cleared message
    for i, m in ipairs(left_messages_list) do
        if m == left_current_message then
            table.insert(_G.ewd_left_messages_list_cancelled, m)   -- For convenience, ewd_left_messages_list_cancelled is defined in ECAM_status.lua
            table.remove(left_messages_list, i)
            return
        end
    end

end

function ewd_tocfg_button_handler(phase) 
    if phase == SASL_COMMAND_BEGIN then
        set(TO_Config_is_pressed, 1)
    end


    if phase == SASL_COMMAND_END then
        set(TO_Config_is_pressed, 0)
    end

end
