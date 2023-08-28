require "Cinetracker.libs.Vector"
include("Cinetracker/libs/signal_processing.lua")

local smoothZoom = 1

-- gforce lowpass filters
local nxLP = LowPass:new { freq = 0.25 }
local nyLP = LowPass:new { freq = 0.25 }
local nzLP = LowPass:new { freq = 0.25 }

local function Set_smooth_rotation(current_angle, target, speed)
    assert(speed >= 0, "Anim value speed must be > 0!")
    local delta = (target - current_angle + 180) % 360 - 180
    return Math_approx_value((current_angle + delta * speed * get(DELTA_TIME)), 0.1, 360) % 360
end

local function camRotation()
    local RAD2DEG = math.deg
    local DEG2RAD = math.rad

    local MAX_ROLL = 15
    local MAX_PITCH = 35

    local ROLL, PITCH, TRU_HDG =
        DEG2RAD(get(Flightmodel_roll)),
        DEG2RAD(get(Flightmodel_pitch)),
        DEG2RAD(get(Flightmodel_true_heading))
    local VPATH, HPATH =
        DEG2RAD(get(Vpath)),
        DEG2RAD(get(Flightmodel_true_track))

    --start using velocity vector only if it has enough speed to be jump around
    local VECTOR_BLEND_RATIO = Math_rescale(30, 0, 40, 1, math.abs(get(IAS)))
    VPATH = VPATH * VECTOR_BLEND_RATIO
    local TRK_DELTA = ((HPATH - TRU_HDG) * VECTOR_BLEND_RATIO) % (2 * math.pi)

    local roll_tbl = {
        { -180, 0 },
        { -90,  -MAX_ROLL },
        { 0,    0 },
        { 90,   MAX_ROLL },
        { 180,  0 },
    }
    local pitch_tbl = {
        { -90, -MAX_PITCH },
        { 0,   0 },
        { 90,  MAX_PITCH },
    }

    local CAM_ROLL = Table_interpolate(roll_tbl, RAD2DEG(ROLL))
    local CAM_PITCH = Table_interpolate(pitch_tbl, RAD2DEG(VPATH))
    local CAM_TRUHDG = get(Flightmodel_true_heading) + RAD2DEG(TRK_DELTA)

    return CAM_ROLL, CAM_PITCH, CAM_TRUHDG
end

local function extCamControl()
    smoothZoom = Set_anim_value_no_lim(smoothZoom, CAMERAZOOM, 5)

    smoothUserRot.x = Set_smooth_rotation(smoothUserRot.x, userRot.x, 5)
    smoothUserRot.y = Set_smooth_rotation(smoothUserRot.y, userRot.y, 5)
    smoothUserRot.z = Set_smooth_rotation(smoothUserRot.z, userRot.z, 5)

    local CAM_ROLL, CAM_PITCH, CAM_TRUHDG = camRotation()

    -- transform rotations of the camera view
    local rot = Vector3(CAM_PITCH, CAM_TRUHDG, CAM_ROLL)
    rot = Vector3.RotateY(rot, -smoothUserRot.y)
    rot.x, rot.y, rot.z = rot.x % 360, rot.y % 360, rot.z % 360

    -- filtered camera gforce
    local camNx, camNy, camNz =
        nyLP:filterOut(get(Total_lateral_g_load)),
        nzLP:filterOut(get(Total_vertical_g_load)),
        nxLP:filterOut(get(Total_long_g_load))

    -- camera gforce displacement
    local gDelta = Vector3(-camNx, -camNy, -camNz)
    gDelta = Vector3.RotateZ(gDelta, -get(Flightmodel_roll))
    gDelta = Vector3.RotateX(gDelta, get(Flightmodel_pitch))
    gDelta = Vector3.RotateY(gDelta, -get(Flightmodel_true_heading))
    gDelta = (gDelta + Vector3(0, 1, 0)) * 10

    -- camera positioning around the aircraft
    local pos = Vector3(0, 0, 50) --behind the plane

    -- camera intrinsic rotation positioning
    -- y -> x' -> z'' -> y''' -> x'''' -> z'''''
    pos = Vector3.RotateZ(pos, -smoothUserRot.z)
    pos = Vector3.RotateX(pos, smoothUserRot.x)
    pos = Vector3.RotateY(pos, -smoothUserRot.y)
    pos = Vector3.RotateZ(pos, -CAM_ROLL)
    pos = Vector3.RotateX(pos, CAM_PITCH)
    pos = Vector3.RotateY(pos, -CAM_TRUHDG)

    pos = pos + gDelta              --add g effects
    pos.y = pos.y + 10 / smoothZoom --above the plane

    -- global gl coordinate calculation
    local x = get(Flightmodel_x) + pos.x
    local y = get(Flightmodel_y) + pos.y
    local z = get(Flightmodel_z) + pos.z

    sasl.setCamera(
        x,
        y,
        z,
        rot.x + smoothUserRot.x,
        rot.y + smoothUserRot.y,
        rot.z + smoothUserRot.z,
        smoothZoom
    )
end

-- override SHIFT+8 camera
local extCamController = sasl.registerCameraController(extCamControl)
sasl.registerCommandHandler(EXT_chase_view, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        userRot.x, userRot.y, userRot.z = 0, 0, 0
        if (sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_ALWAYS) then
            sasl.startCameraControl(extCamController, CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE)
        end
    end

    return 0
end)

-- override hatswitches
sasl.registerCommandHandler(Hatswitch_U, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
            return 1
        end

        userRot.x, userRot.y, userRot.z = 0, 180, 0
    end
    if phase == SASL_COMMAND_END then
        userRot.x, userRot.y, userRot.z = 0, 0, 0
    end

    return 1
end)
sasl.registerCommandHandler(Hatswitch_D, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
            return 1
        end

        userRot.x, userRot.y, userRot.z = 0, 0, 0
    end
    if phase == SASL_COMMAND_CONTINUE then
        if sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
            return 1
        end
    end

    return 1
end)
sasl.registerCommandHandler(Hatswitch_L, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
            return 1
        end

        userRot.x, userRot.y, userRot.z = 0, 270, 0
    end
    if phase == SASL_COMMAND_END then
        userRot.x, userRot.y, userRot.z = 0, 0, 0
    end

    return 1
end)
sasl.registerCommandHandler(Hatswitch_R, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if sasl.getCurrentCameraStatus() ~= CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
            return 1
        end

        userRot.x, userRot.y, userRot.z = 0, 90, 0
    end
    if phase == SASL_COMMAND_END then
        userRot.x, userRot.y, userRot.z = 0, 0, 0
    end

    return 1
end)