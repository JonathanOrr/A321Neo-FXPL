--sim datarefs

--a32nx datarefs

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
