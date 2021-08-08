local aileron_filter_data = {
    {cut_frequency = 3, x=0},   -- LEFT
    {cut_frequency = 3, x=0}    -- RIGHT
}

local ailerons_max_def = 25        -- in °/s
local ailerons_max_actuator = 21.5 -- in mm
local sin_ailerons_max_def = math.sin(math.rad(ailerons_max_def))
local aileron_curr_spd = {0,0}
local aileron_table = {FBW.fctl.surfaces.ail.L,FBW.fctl.surfaces.ail.R}
local ail_no_hyd_spd = 8
local no_hyd_recenter_ias = 80

-- Cache some functions to speed-up computation
local mabs  = math.abs
local masin = math.asin
local msin  = math.sin
local mdeg  = math.deg
local mexp  = math.exp
local mrad  = math.rad

local function aileron_model_deg_to_mm(deg)  -- Convert aileron deg to actuator mm
    deg = Math_clamp(deg, -ailerons_max_def, ailerons_max_def)
    return msin(mrad(deg)) / sin_ailerons_max_def * ailerons_max_actuator
end

local function aileron_model_mm_to_deg(mm)  -- Convert actuator mm to aileron deg
    mm = Math_clamp(mm, -ailerons_max_actuator, ailerons_max_actuator)
    return mdeg(masin(sin_ailerons_max_def * mm / ailerons_max_actuator))
end


local function aileron_model_spd(mm_target, mm_actual, ail_pos) -- Compute the maximum speed depending on the Drag forces and
                                                                -- the G forces. See the document on Discord for explanation
    local IAS = get(IAS)
    local A   = ail_pos
    local rho = get(Weather_Rho)
    local Cd  = 1
    local Aail= 1.016

    local Ad = Aail * msin(mrad(mabs(A)))
    local Fd = 0.5*rho * (IAS*0.514444)^2 * Cd * Ad

    local aero_forces = mabs(get(Flightmodel_aero_norm_forces) / 900 * Aail)

    local Ftot = aero_forces / 1e4

    if mabs(mm_target) > mabs(mm_actual) then   -- Add the drag forces in this case
        Ftot = Ftot + Fd / 1e4
    end

    local max_speed = 83.93358 - (2.031154/-0.8271113)*(1 - mexp(0.8271113*Ftot))

    return max_speed
end


local function compute_acceleration_space(vnow, vtarget, acceleration)  -- distance where to start decelerating
    local delta_time = (vtarget - vnow) / acceleration
    return (vnow + vtarget) / (2 * delta_time)
end

local function aileron_actuation(request_pos, which_one)   -- which one: 1: LEFT, 2: RIGHT

    local curr_pos    = which_one == 1 and get(L_aileron) or get(R_aileron)
    local curr_pos_mm = aileron_model_deg_to_mm(curr_pos)
    local req_pos_mm  = aileron_model_deg_to_mm(request_pos)

    -- 1: Compute the max speed
    local max_speed = aileron_model_spd(req_pos_mm, curr_pos_mm, curr_pos)

    -- 2: Perform a 3 Hz filter on the max speed change
    aileron_filter_data[which_one].x = max_speed
    local target_max_speed = mabs(low_pass_filter(aileron_filter_data[which_one]))

    -- 3: Rescale speed depending on HYD availability
    local max_hyd = math.max(get(Hydraulic_B_press), get(Hydraulic_G_press))
    local max_spd_aft_hyd = Math_rescale(0, 0, 3000, 89, max_hyd)

    -- 4: So, corrently compute pos/neg speed depending on the direction we have to go
    if curr_pos < request_pos then
        target_speed = math.min(max_spd_aft_hyd, target_max_speed)
    elseif curr_pos > request_pos then
        target_speed = -math.min(max_spd_aft_hyd, target_max_speed)
    else
        target_speed = 0
    end

    -- 5: Slow down the actuator near the target
    if target_speed ~= 0 and mabs(curr_pos-request_pos) < 10 then
        target_speed = target_speed * mabs(curr_pos-request_pos)/10
    end

    -- 6: Dampening if both systems avail
    if (get(Hydraulic_B_press) < 1450 or get(Hydraulic_G_press) < 1450) then
        -- If (at least) one actuator is failed, then we don't have dampening
        aileron_curr_spd[which_one] = target_speed
    else
        local A_aileron = 400
        aileron_curr_spd[which_one] = Set_linear_anim_value(aileron_curr_spd[which_one], target_speed, -100, 100, A_aileron)
    end

    -- 7: Failures (stuck)
     aileron_curr_spd[which_one] = aileron_curr_spd[which_one] * (1 - get(which_one == 1 and FAILURE_FCTL_LAIL or FAILURE_FCTL_RAIL))

    local ail_dataref = which_one == 1 and L_aileron or R_aileron

    -- 8: Finally compute actuator value and set the surface position
    if not aileron_table[which_one].controlled then
        -- No HYD at all
        -- Return to neutral depending on TAS (no hyd system)
        local LOCAL_AIRSPD_KTS = get(TAS_ms) * 1.94384
        local pos = Math_rescale(0, ailerons_max_def, no_hyd_recenter_ias, -get(Alpha), LOCAL_AIRSPD_KTS)
        Set_dataref_linear_anim(ail_dataref, pos, -ailerons_max_def, ailerons_max_def, ail_no_hyd_spd)
    else
        -- Normal situation
        local actuator_value = curr_pos_mm + aileron_curr_spd[which_one] * get(DELTA_TIME)  -- DO NOT use the set_anim_linear here: the speed can be negative!
        actuator_value = Math_clamp(actuator_value, -ailerons_max_actuator, ailerons_max_actuator)
        set(ail_dataref, aileron_model_mm_to_deg(actuator_value))
    end
end

FBW.fctl.control.ail = function (lateral_input, has_florence_kit)
    --surface range -25 up +25 down, 10 degrees droop with flaps(calculated by ELAC 1/2)

    --properties
    local l_aileron_def_table = {
        {-1, -ailerons_max_def},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,   ailerons_max_def},
    }
    local r_aileron_def_table = {
        {-1,  ailerons_max_def},
        {0,   10 * get(Flaps_deployed_angle) / 30},
        {1,  -ailerons_max_def},
    }

    local l_aileron_travel_target = Table_interpolate(l_aileron_def_table, lateral_input)
    local r_aileron_travel_target = Table_interpolate(r_aileron_def_table, lateral_input)

    --TRAVEL TARGETS CALTULATION
    --ground spoilers
    if get(Ground_spoilers_mode) == 2 and get(FBW_total_control_law) == FBW_NORMAL_LAW then
        if has_florence_kit == true and get(Flaps_internal_config) ~= 0 and adirs_get_avg_pitch() < 2.5 then
            l_aileron_travel_target = -ailerons_max_def
            r_aileron_travel_target = -ailerons_max_def
        end
    end

    --output to the surfaces
    aileron_actuation(l_aileron_travel_target, 1)
    aileron_actuation(r_aileron_travel_target, 2)
end

function update()
    FBW.fctl.control.ail(get(FBW_roll_output), true)
end