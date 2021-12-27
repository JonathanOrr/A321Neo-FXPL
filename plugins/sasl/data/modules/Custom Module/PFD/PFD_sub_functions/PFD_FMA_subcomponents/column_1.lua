PFD_FMA_column_1 = {
    {
        size = {163, 82},
        position = {10, 808},
        shown = function ()
            return get(Cockpit_throttle_lever_L) >= THR_TOGA_START or get(Cockpit_throttle_lever_L) >= THR_TOGA_START
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "MAN",
        text_line_2 = "TOGA",
        text_color = ECAM_WHITE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 82},
        position = {10, 808},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "MAN",
        text_line_2 = "MCT",
        text_color = ECAM_WHITE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 82},
        position = {10, 808},
        shown = function ()
            return ENG.dyn[1].n1_mode == 7 or ENG.dyn[2].n1_mode == 7
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "MAN",
        text_line_2 = "GA SOFT",
        text_color = ECAM_WHITE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 82},
        position = {10, 808},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "MAN",
        text_line_2 = "THR",
        text_color = ECAM_WHITE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR MCT",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR CLB",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR IDLE",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR LVR",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_ORANGE,
        box_flash_length = 10,
        text_line_1 = "A.FLOOR",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_ORANGE,
        box_flash_length = 10,
        text_line_1 = "TOGA TK",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "LVR CLB",
        text_line_2 = nil,
        text_color = ECAM_WHITE,
        text_flashing = true,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "LVR MCT",
        text_line_2 = nil,
        text_color = ECAM_WHITE,
        text_flashing = true,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "LVR TOGA",
        text_line_2 = nil,
        text_color = ECAM_WHITE,
        text_flashing = true,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "LVR ASYM",
        text_line_2 = nil,
        text_color = ECAM_ORANGE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR LK",
        text_line_2 = nil,
        text_color = ECAM_ORANGE,
        text_flashing = true,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "THR LK",
        text_line_2 = nil,
        text_color = ECAM_ORANGE,
        text_flashing = true,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return get(Wheel_autobrake_status) == 1 and get(Wheel_autobrake_is_in_decel) == 1
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK LO",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return get(Wheel_autobrake_status) == 2 and get(Wheel_autobrake_is_in_decel) == 1
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK MED",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 854},
        shown = function ()
            return get(Wheel_autobrake_status) == 3 and get(Wheel_autobrake_is_in_decel) == 1
        end,
        draw_with_function = false,
        boxed = true,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK MAX",
        text_line_2 = nil,
        text_color = ECAM_GREEN,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 808},
        shown = function ()
            return get(Wheel_autobrake_status) == 1 and get(Wheel_autobrake_is_in_decel) == 0 and PFD_FMA_column_1[1].shown() == false and PFD_FMA_column_1[3].shown() == false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK LO",
        text_line_2 = nil,
        text_color = ECAM_BLUE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 808},
        shown = function ()
            return get(Wheel_autobrake_status) == 2 and get(Wheel_autobrake_is_in_decel) == 0 and PFD_FMA_column_1[1].shown() == false and PFD_FMA_column_1[3].shown() == false
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK MED",
        text_line_2 = nil,
        text_color = ECAM_BLUE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },

    {
        size = {163, 36},
        position = {10, 762},
        shown = function ()
            return get(Wheel_autobrake_status) == 3 and get(Wheel_autobrake_is_in_decel) == 0
        end,
        draw_with_function = false,
        boxed = false,
        box_color = ECAM_WHITE,
        box_flash_length = 10,
        text_line_1 = "BRK MAX",
        text_line_2 = nil,
        text_color = ECAM_BLUE,
        text_flashing = false,
        draw_function = function ()
            
        end,
    },
}