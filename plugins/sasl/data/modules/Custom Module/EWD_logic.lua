include('EWD_flight_phases.lua')
include('EWD_msgs/brakes_and_antiskid.lua')
include('EWD_msgs/engines_and_apu.lua')
include('EWD_msgs/FBW.lua')
include('EWD_msgs/flight_controls.lua')
include('EWD_msgs/misc.lua')
include('EWD_msgs/to_ldg_memos.lua')

-- commands
local Ecam_btn_cmd_CLR = sasl.findCommand("a321neo/cockpit/ecam/buttons/cmd_clr")
local Ecam_btn_cmd_RCL = sasl.findCommand("a321neo/cockpit/ecam/buttons/cmd_rcl")

sasl.registerCommandHandler (Ecam_btn_cmd_CLR,   0 , function(phase) ewd_clear_button_handler(phase) end )
sasl.registerCommandHandler (Ecam_btn_cmd_RCL,   0 , function(phase) ewd_recall_button_handler(phase) end )

--colors
local COL_INVISIBLE = 0    
local COL_WARNING = 1       -- RED
local COL_SPECIAL = 2       -- MAGENTA
local COL_CAUTION = 3       -- AMBER
local COL_INDICATION = 4    -- GREEN
local COL_REMARKS = 5       -- WHITE
local COL_ACTIONS = 6       -- BLUE

--initialisation--
for i=0,6 do
    set(EWD_left_memo[i], "LINE " .. i)
    set(EWD_left_memo_colors[i], COL_INVISIBLE)
end
for i=0,6 do
    set(EWD_right_memo[i], "LINE " .. i)
    set(EWD_right_memo_colors[i], COL_INVISIBLE)
end

-- This is the list of triggerable messages for the left. When a message is cleared with CLR, the
-- message is removed from the list and moved to the next list "left_messages_list_cleared"
local left_messages_list = {
    -- Normal messages
    MessageGroup_MEMO_TAKEOFF,
    MessageGroup_MEMO_LANDING,
    MessageGroup_GND_SPEEDBRAKES,
    MessageGroup_SEAT_BELTS,
    MessageGroup_NO_SMOKING,
    MessageGroup_IRS_ALIGN,

    -- Cautions
    MessageGroup_FBW_ALTN_DIRECT_LAW,
    MessageGroup_BRAKES_HOT,
    MessageGroup_APU_SHUTDOWN,
    
    -- Warnings
    MessageGroup_CONFIG_TAKEOFF,
    MessageGroup_APU_FIRE
}

local left_messages_list_cleared = {    -- List of message cleared with CLR

}

local left_messages_list_cancelled = {  -- List of message cancelled with EMER CANC

}


local left_current_message = nil;   -- It contains (if exists) the first message group *clearable*
local left_was_clearing = false     -- True when a warning/caution message exists and status page not yet displayed
local land_asap = false;            -- If true, the LAND ASAP message appears (according to flight phase)

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
    if get(Apu_avail) == 1 then
        list_right:put(COL_INDICATION, "APU AVAIL")
    end 
    if get(Apu_bleed_state) == 2 then
        list_right:put(COL_INDICATION, "APU BLEED")
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


    
    -- TODO RAM Air: RAM AIR ON green if related pushbutton switch is ON
    -- TODO Pressurization: MAN LDG ELEV green if LDG ELEV switch is not in AUTO

    -- TODO Autobrake: AUTO BRK LO/MED/MAX (any flight phase)
    -- TODO Autobrake fail: AUTO BRK OFF (any flight phase, amber)

    -- TODO Steer: NW STRG DISC when the nose wheel steering selector is in the towing position
    --             GREEN: if no engine is running, AMBER: is at least one engine is running
    
    -- TODO Audio: AUDIO 3 XFRD displayed green if audo switching selector not in NORM
    -- TODO Acars: ACARS CALL (pulsing green) if received an ACARS message requesting voice conversation
    -- TODO Acars: VHF 3 VOICE (pulsing green) if VHF 3 in voice mode and ACARS comm interrupted (?)
    -- TODO Acars: ACARS MSG (pulsing green) if new ACARS message received
    -- TODO Acars: ACARS STBY (green) if ACARS communication is lost
    
    -- TODO Elec: EMERG GEN displayed in green when emergency generator is running
    
    -- TODO Fuel: OUTR TK FUEL XFRD in green if at least 1 transfer valve is open
    -- TODO Fuel: CTR TK FEEDG, green, if at least one center fuel pump is ON
    -- TODO Fuel: FUEL X FEED:
    --                          green - X FEED valve ON and X FEED not fully closed
    --                          amber if in flight phases 3,4,5
    -- TODO Fuel: REFUELG: green, fuel control panel door open or cockpit PWR pushbutton refuel panel ON
    
    -- TODO Hyd: RAT OUT, green, if ram air turbine is out
    -- TODO Hyd: HYD PTU, green, if PTU is running
    
    -- TODO Anti-ice: WING A. ICE, green, if WING ANTI ICE is ON
    -- TODO Anti-ice: ICE NOT DET, green, if ice no longer detected after 190 secs of pressing WING ANTI ICE
    -- TODO Anti-ice: ENG A. ICE, green, if one or both of ENG ANTI ICE is ON
    -- TODO Anti-ice: ICE NOT DET, green, if ice no longer detected after 190 secs of pressing ENG ANTI ICE
    
    -- TODO windshear: PRED W/S OFF if windshear (weather panel) is selected OFF
    --                  green in phases 1,2,6,10
    --                  amber in phases 3,4,5,7,8,9
    --                  not present in 6

    -- TODO GPWS: GPWS FLAP 3 in green if related pushbutton is ON
    -- TODO GPWS: GPWS FLAP MODE OFF in green if related pushbutton is OFF
    -- TODO GPWS: TERR STBY in green if position is too inaccurate to show terrain on ND

    -- TODO TCAS: TCAS STBY in green if ATC STBY is selected or TCAS STBY is selected or 
    --            ALT RPTG is selected OFF or TCAS failed

    -- TODO Ignition: IGNITION in green when continuous ignition is activated 

    -- TODO Lights: LDG LT

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
            break
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

    list_left  = PriorityQueue()
    list_left:setmax(PRIORITY_LEVEL_MEMO)

    for i, m in ipairs(left_messages_list) do
        if (m.is_active() and (not m.is_inhibited())) then
            m.shown = true
        end    
        if not m.is_active() then
            m.shown = false
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
    set(EWD_arrow_overflow, 0)

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
    
    for i=tot_messages, 7 do
        set(EWD_left_memo[i], "")
        set(EWD_left_memo_colors[i], COL_INVISIBLE)
    end
    
    -- Update the ECAM requested page (if necessary)
    if left_current_message ~= nil then
        if left_current_message.sd_page ~= nil then
            -- ECAM page change request
            -- We put this number of the dataref
            set(Ecam_EDW_requested_page, left_current_message.sd_page)
        end
        left_was_clearing = true
    else
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

function update()

    update_left_list()
    publish_left_list()
    update_right_list()
    publish_right_list()
    
    check_cleared_list()
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
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    -- Move back all the messages from the cleared list to the normal list
    for i,msg in ipairs(left_messages_list_cleared) do
        table.insert(left_messages_list, msg)
    end

    left_messages_list_cleared = {}
    
end

