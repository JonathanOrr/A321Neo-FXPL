--colors
local COL_INVISIBLE = 0    
local COL_WARNING = 1       -- RED
local COL_CAUTION = 2       -- AMBER
local COL_INDICATION = 3    -- GREEN
local COL_REMARKS = 4       -- WHITE
local COL_ACTIONS = 5       -- BLUE
local COL_SPECIAL = 6       -- MAGENTA

--initialisation--
for i=0,6 do
    set(EWD_left_memo[i], "LINE " .. i)
    set(EWD_left_memo_colors[i], COL_WARNING)
end
for i=0,6 do
    set(EWD_right_memo[i], "LINE " .. i)
    set(EWD_right_memo_colors[i], COL_INDICATION)
end

-- PriorityQueue external implementation
-- Source: https://rosettacode.org/wiki/Priority_queue#Lua
-- License: GNU Free Documentation License 1.2
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
            for p, q in pairs(self) do
                if q.first <= q.last then
                    local v = q[q.first]
                    q[q.first] = nil
                    q.first = q.first + 1
                    return p, v
                else
                    self[p] = nil
                end
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
function update_right_list()

    list_right = PriorityQueue()

    if get(Apu_avail) == 1 then
        list_right:put(COL_INDICATION, "APU AVAIL")
    end 
    if get(Apu_bleed_state) == 2 then
        list_right:put(COL_INDICATION, "APU BLEED")
    end 
    if get(Brakes_fan) == 1 then
        list_right:put(COL_INDICATION, "BRK FAN")
    end

end

function publish_right_list()

    tot_messages = 0

    for prio,msg in list_right.pop, list_right do

        set(EWD_right_memo[tot_messages], msg)
        set(EWD_right_memo_colors[tot_messages], prio)
        
        
        tot_messages = tot_messages + 1
        if tot_messages >= 7 then
            break
        end 
    end

    for i=tot_messages, 7 do
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

function update_left_list()
    local LEVEL_1=1 -- Highest emergency
    local LEVEL_2=2
    local LEVEL_3=3
    local NORMAL=4  -- Normal messages

    list_left  = PriorityQueue()

    if get(FBW_status) == 1 then
        list_left:put(LEVEL_1, {COL_CAUTION, "F/CTL ALTN LAW"})
        list_left:put(LEVEL_1, {COL_CAUTION, "      (PROT LOST)"})
        list_left:put(LEVEL_1, {COL_ACTIONS, "MAX SPEED.........330/.82"})
    end 
    if get(FBW_status) == 0 then
        list_left:put(LEVEL_1, {COL_CAUTION, "F/CTL DIRECT LAW"})
        list_left:put(LEVEL_1, {COL_CAUTION, "      (PROT LOST)"})
        list_left:put(LEVEL_1, {COL_ACTIONS, "SPD BRK........DO NOT USE"})
        list_left:put(LEVEL_1, {COL_ACTIONS, "MAX SPEED.........305/.80"})
        list_left:put(LEVEL_1, {COL_ACTIONS, "MAN PITCH TRIM........USE"})
        list_left:put(LEVEL_1, {COL_ACTIONS, "MANEUVER WITH CARE"})
    end 

end

function publish_left_list()
    tot_messages = 0

    for prio, msg_arr in list_left.pop, list_left do

        set(EWD_left_memo[tot_messages], msg_arr[2])
        set(EWD_left_memo_colors[tot_messages], msg_arr[1])
        
        tot_messages = tot_messages + 1
        if tot_messages >= 7 then
            break
        end 
    end
    
    for i=tot_messages, 7 do
        set(EWD_left_memo[i], "")
        set(EWD_left_memo_colors[i], COL_INVISIBLE)
    end

end

function update()

    update_left_list()
    publish_left_list()
    update_right_list()
    publish_right_list()
end
