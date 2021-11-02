Cinetracker.camera = {
    AXIS_MATH = {
        Common = {
            get_user_cam_pos = function ()
                return Cinetracker.status.camera_pos.x,
                       Cinetracker.status.camera_pos.y,
                       Cinetracker.status.camera_pos.z
            end,
            get_user_cam_rot = function ()
                return Cinetracker.status.camera_pos.roll,
                       Cinetracker.status.camera_pos.pitch,
                       Cinetracker.status.camera_pos.yaw
            end,
            get_user_orbit_rot = function ()
                local deg2rad = math.rad
                return Cinetracker.status.camera_pos.r,
                       deg2rad(Cinetracker.status.camera_pos.h_rot),
                       deg2rad(Cinetracker.status.camera_pos.v_rot)
            end,
            get_acf_rot = function ()
                local deg2rad = math.rad
                return deg2rad(get(Flightmodel_NRM_roll)),
                       deg2rad(get(Flightmodel_NRM_pitch)),
                       deg2rad(get(Flightmodel_NRM_heading))
            end,
            get_flt_rot = function ()
                local deg2rad = math.rad
                return math.atan(get(Flightmodel_vy)/math.sqrt(get(Flightmodel_vz)^2 + get(Flightmodel_vx)^2)),-- deg2rad(get(Vpath)),
                       (math.atan2(get(Flightmodel_vz), get(Flightmodel_vx)) + math.pi/2) % (2 * math.pi)
            end,
        },
        Global = {
            GLOBAL = function ()
                local SIN = math.sin
                local COS = math.cos
                local TAN = math.tan
                local RAD2DEG = math.deg
                local DEG2RAD = math.rad

                local CURR_BANK, CURR_PITCH, CURR_TRU_HDG = Cinetracker.camera.AXIS_MATH.Common.get_acf_rot()
                local USER_roll, USER_pitch, USER_yaw = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_rot()
                local USER_x, USER_y, USER_z = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_pos()

                local LOCAL_x = USER_x
                local LOCAL_y = USER_y
                local LOCAL_z = USER_z

                local GLOBAL_dx = LOCAL_x * COS(CURR_TRU_HDG) - LOCAL_z * SIN(CURR_TRU_HDG)
                local GLOBAL_dy = LOCAL_y
                local GLOBAL_dz = LOCAL_z * COS(CURR_TRU_HDG) + LOCAL_x * SIN(CURR_TRU_HDG)

                return GLOBAL_dx, GLOBAL_dy, GLOBAL_dz, USER_roll, USER_pitch, USER_yaw
            end,
            GLOBAL_ROT = function ()
                local SIN = math.sin
                local COS = math.cos
                local TAN = math.tan
                local RAD2DEG = math.deg
                local DEG2RAD = math.rad

                local CURR_BANK, CURR_PITCH, CURR_TRU_HDG = Cinetracker.camera.AXIS_MATH.Common.get_acf_rot()
                local USER_roll, USER_pitch, USER_yaw = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_rot()
                local USER_x, USER_y, USER_z = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_pos()

                local LOCAL_x = USER_x * COS(CURR_BANK) + USER_y * SIN(CURR_BANK)
                local LOCAL_y = USER_y * COS(CURR_BANK) * COS(CURR_PITCH)
                local LOCAL_z = USER_z * COS(CURR_PITCH) + USER_y * COS(CURR_BANK) * SIN(CURR_PITCH)

                --bank correction--
                LOCAL_z = LOCAL_z - USER_x * SIN(CURR_BANK) * SIN(CURR_PITCH)

                local GLOBAL_dx = LOCAL_x * COS(CURR_TRU_HDG) - LOCAL_z * SIN(CURR_TRU_HDG)
                local GLOBAL_dy = LOCAL_y - USER_x * SIN(CURR_BANK) * COS(CURR_PITCH) - USER_z * SIN(CURR_PITCH)
                local GLOBAL_dz = LOCAL_z * COS(CURR_TRU_HDG) + LOCAL_x * SIN(CURR_TRU_HDG)

                return GLOBAL_dx, GLOBAL_dy, GLOBAL_dz, USER_roll, USER_pitch, USER_yaw
            end
        },
        Orbit = {
            ORBIT = function ()
                local SIN = math.sin
                local COS = math.cos
                local TAN = math.tan
                local RAD2DEG = math.deg
                local DEG2RAD = math.rad

                local CURR_BANK, CURR_PITCH, CURR_TRU_HDG = Cinetracker.camera.AXIS_MATH.Common.get_acf_rot()
                local USER_roll, USER_pitch, USER_yaw = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_rot()
                local USER_r, USER_h_rot, USER_v_rot = Cinetracker.camera.AXIS_MATH.Common.get_user_orbit_rot()

                local LOCAL_x = USER_r * COS(USER_v_rot) * COS(USER_h_rot)
                local LOCAL_y = USER_r * SIN(USER_v_rot)
                local LOCAL_z = USER_r * COS(USER_v_rot) * SIN(-USER_h_rot)

                local GLOBAL_dx = LOCAL_x * COS(CURR_TRU_HDG) - LOCAL_z * SIN(CURR_TRU_HDG)
                local GLOBAL_dy = LOCAL_y
                local GLOBAL_dz = LOCAL_z * COS(CURR_TRU_HDG) + LOCAL_x * SIN(CURR_TRU_HDG)

                USER_pitch = Math_clamp(USER_pitch -RAD2DEG(USER_v_rot), -90, 90)
                USER_yaw = (USER_yaw -RAD2DEG(USER_h_rot) - 90) % 360

                return GLOBAL_dx, GLOBAL_dy, GLOBAL_dz, USER_roll, USER_pitch, USER_yaw
            end
        },
        Local = {
            
        },
        Follow = {
            FOLLOW_GLOAD = function ()
                local SIN = math.sin
                local COS = math.cos
                local TAN = math.tan
                local RAD2DEG = math.deg
                local DEG2RAD = math.rad

                local FIXED_USER_pitch = 0
                local MAX_ROLL = 15
                local MAX_PITCH = 35

                local CURR_BANK, CURR_PITCH, CURR_TRU_HDG = Cinetracker.camera.AXIS_MATH.Common.get_acf_rot()
                local CURR_VPATH, CURR_HPATH = Cinetracker.camera.AXIS_MATH.Common.get_flt_rot()
                local USER_roll, USER_pitch, USER_yaw = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_rot()
                local USER_x, USER_y, USER_z = Cinetracker.camera.AXIS_MATH.Common.get_user_cam_pos()

                local vector_blend_table = {
                    {0,  0},
                    {30, 0},
                    {40, 1},
                }
                local VECTOR_BLEND_RATIO = Table_interpolate(vector_blend_table, get(IAS))
                CURR_VPATH = CURR_VPATH * VECTOR_BLEND_RATIO
                local TRK_DELTA = ((CURR_HPATH - CURR_TRU_HDG) * VECTOR_BLEND_RATIO) % (2*math.pi)

                local ORIGIN_y = 2.52
                local ORIGIN_z = 23.95

                local LOCAL_ORIGIN_x = ORIGIN_y * SIN(CURR_BANK)
                local LOCAL_ORIGIN_y = ORIGIN_y * COS(CURR_BANK) * COS(CURR_VPATH) - ORIGIN_z * SIN(CURR_VPATH)
                local LOCAL_ORIGIN_z = ORIGIN_y * COS(CURR_BANK) * SIN(CURR_VPATH) + ORIGIN_z * COS(CURR_VPATH)

                local ORIGIN_H_ROT_x = LOCAL_ORIGIN_z * COS(TRK_DELTA + math.pi/2)
                local ORIGIN_H_ROT_y = LOCAL_ORIGIN_y
                local ORIGIN_H_ROT_z = LOCAL_ORIGIN_z * SIN(TRK_DELTA + math.pi/2)

                local FOLLOW_y = 6.8
                local FOLLOW_z = 26.5

                local LOCAL_x = ORIGIN_H_ROT_x + FOLLOW_z * COS(TRK_DELTA + math.pi/2)
                local LOCAL_y = ORIGIN_H_ROT_y + FOLLOW_y
                local LOCAL_z = ORIGIN_H_ROT_z + FOLLOW_z * SIN(TRK_DELTA + math.pi/2)

                local GLOBAL_dx = LOCAL_x * COS(CURR_TRU_HDG) - LOCAL_z * SIN(CURR_TRU_HDG)
                local GLOBAL_dy = LOCAL_y
                local GLOBAL_dz = LOCAL_z * COS(CURR_TRU_HDG) + LOCAL_x * SIN(CURR_TRU_HDG)

                local roll_table = {
                    {-180,        0},
                    {-90, -MAX_ROLL},
                    {0,           0},
                    {90,   MAX_ROLL},
                    {180,         0},
                }
                local pitch_table = {
                    {-90, -MAX_PITCH},
                    {0,           0},
                    {90,   MAX_PITCH},
                }

                USER_roll =  Table_interpolate(roll_table, RAD2DEG(CURR_BANK))
                USER_pitch = Table_interpolate(pitch_table, RAD2DEG(CURR_VPATH))
                USER_pitch = Math_clamp(USER_pitch + FIXED_USER_pitch, -90, 90)

                return GLOBAL_dx, GLOBAL_dy, GLOBAL_dz, USER_roll, USER_pitch, RAD2DEG(TRK_DELTA)
            end,
        },
    },

    Global_controller = function ()
        local dx, dy, dz, roll, pitch, yaw = Cinetracker.camera.AXIS_MATH.Follow.FOLLOW_GLOAD()

        local x = get(Flightmodel_x) + dx
        local y = get(Flightmodel_y) + dy
        local z = get(Flightmodel_z) + dz

        sasl.setCamera(
            x,
            y,
            z,
            pitch,
            get(Flightmodel_NRM_heading) + yaw,
            roll,
            Cinetracker.status.camera_pos.zoom
        )
    end,
}

Cinetracker.camera.Controller_ID = {
    Global = {

    },
    follow = {
        FOLLOW_GLOAD = sasl.registerCameraController(Cinetracker.camera.Global_controller)
    },
}
