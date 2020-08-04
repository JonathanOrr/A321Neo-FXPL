local default_head_x = -0.445792
local default_head_y = 2.244107
local default_head_z = -17.3736

local hud_h_transform = createGlobalPropertyf("a321neo/dynamics/hud/horizontal_transform", 0, false, true, false)
local hud_v_transform = createGlobalPropertyf("a321neo/dynamics/hud/vertical_transform", 0, false, true, false)

function update()
    set(hud_h_transform, (get(Head_x)-default_head_x)*2000)
    set(hud_v_transform, (get(Head_y)-default_head_y)*2000)
end