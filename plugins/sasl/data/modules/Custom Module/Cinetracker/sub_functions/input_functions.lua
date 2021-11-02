Cinetracker.inputs = {
    commands = {
        follow_gload_view = function (phase)
            if phase == SASL_COMMAND_BEGIN then
                if (sasl.getCurrentCameraStatus () ~= CAMERA_CONTROLLED_ALWAYS) then
                    sasl.startCameraControl(Cinetracker.camera.Controller_ID.follow.FOLLOW_GLOAD, CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE)
                end
            end

            return 0
        end
    },

    keyboard = {
        down = function (component, char, key, shDown, ctrlDown, altOptDown)
            if key == SASL_VK_Q then
                Cinetracker.status.camera_pos.yaw = Math_cycle(Cinetracker.status.camera_pos.yaw - (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), 0, 360)
            end
            if key == SASL_VK_E then
                Cinetracker.status.camera_pos.yaw = Math_cycle(Cinetracker.status.camera_pos.yaw + (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), 0, 360)
            end
            if key == SASL_VK_R then
                --Cinetracker.status.camera_pos.pitch = Math_clamp(Cinetracker.status.camera_pos.pitch + (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), -90, 90)
                Cinetracker.status.camera_pos.v_rot = Math_clamp(Cinetracker.status.camera_pos.v_rot + (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), -90, 90)
            end
            if key == SASL_VK_F then
                --Cinetracker.status.camera_pos.pitch = Math_clamp(Cinetracker.status.camera_pos.pitch - (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), -90, 90)
                Cinetracker.status.camera_pos.v_rot = Math_clamp(Cinetracker.status.camera_pos.v_rot - (shDown == 1 and 60 or 10) * get(DELTA_TIME_NO_STOP), -90, 90)
            end

            if key == SASL_VK_LEFT then
                Cinetracker.status.camera_pos.x = Cinetracker.status.camera_pos.x - (shDown == 1 and 15 or 2.5) * get(DELTA_TIME_NO_STOP)
            end
            if key == SASL_VK_RIGHT then
                Cinetracker.status.camera_pos.x = Cinetracker.status.camera_pos.x + (shDown == 1 and 15 or 2.5) * get(DELTA_TIME_NO_STOP)
            end
            if key == SASL_VK_UP then
                Cinetracker.status.camera_pos.y = Cinetracker.status.camera_pos.y + (shDown == 1 and 15 or 2.5) * get(DELTA_TIME_NO_STOP)
            end
            if key == SASL_VK_DOWN then
                Cinetracker.status.camera_pos.y = Cinetracker.status.camera_pos.y - (shDown == 1 and 15 or 2.5) * get(DELTA_TIME_NO_STOP)
            end
        end
    },

    mouse = {
        wheel = {
            down = function(component, x, y, button, parentX, parentY, value)
                Cinetracker.status.camera_pos.z = Cinetracker.status.camera_pos.z + value
                Cinetracker.status.camera_pos.h_rot = Cinetracker.status.camera_pos.h_rot + value
            end
        }
    }
}

sasl.registerCommandHandler (EXT_chase_view, 0, Cinetracker.inputs.commands.follow_gload_view)