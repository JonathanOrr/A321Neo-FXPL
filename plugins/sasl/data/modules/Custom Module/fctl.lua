--sim datarefs
local left_aileron = globalProperty("sim/flightmodel/controls/lail1def") --25 deg up -25 deg down
local left_outboard_spoilers = globalProperty("sim/flightmodel/controls/wing2l_spo2def") --roll spoilers 35 deg up with ailerons starts at 20% aileron, 35 degrees in flight decel, 50 degrees for ground spoilers
local left_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2l_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local left_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1l_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_aileron = globalProperty("sim/flightmodel/controls/rail1def") --25 deg up -25 deg down
local right_outboard_spoilers = globalProperty("sim/flightmodel/controls/wing2r_spo2def") --roll spoilers 35 deg up with ailerons starts at 20% aileron, 35 degrees in flight decel, 50 degrees for ground spoilers
local right_outboard_flaps = globalProperty("sim/flightmodel/controls/wing2r_fla2def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local right_inboard_flaps = globalProperty("sim/flightmodel/controls/wing1r_fla1def") -- flap detents 0 = 0, 1 = 10, 2 = 15, 3 = 20, 4 = 40
local inboard_spoilers = globalProperty("sim/flightmodel2/wing/speedbrake1_deg[0]") --35 degrees in flight decel, 50 degrees ground spoilers
local slats = globalProperty("sim/flightmodel2/controls/slat1_deploy_ratio") --deploys with flaps 0 = 0, 1 = 0.7, 2 = 0.8, 3 = 0.8, 4 = 1