--colors
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_HIGH_GREY = {0.6, 0.6, 0.6}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.184, 0.733, 0.219}
local ECAM_ORANGE = {0.725, 0.521, 0.18}
local ECAM_RED = {1.0, 0.0, 0.0}
local ECAM_MAGENTA = {1.0, 0.0, 1.0}
local ECAM_GREY = {0.3, 0.3, 0.3}


ecam_sts = {
    
    get_max_speed = function()
        return 250,80
    end,
    
    get_max_fl = function()
        return 100
    end,
    
    get_appr_proc = function()
        return {
            { text="-FOR LDG.......USE FLAP 3", color=ECAM_BLUE},
            { text=".IF PERF PERMITS:",       color=ECAM_WHITE},
            { text="-X BLEED.............OPEN", color=ECAM_BLUE}
        }
    end,
    
    get_procedures = function()
        return {
            { text="L/G...............GRVTY EXTN", color=ECAM_BLUE},
            { text="LDG SPD INCREM..........10KT", color=ECAM_BLUE},
            { text="LDG DIST...............X 1.8", color=ECAM_BLUE},

        }
    end,
    
    get_information = function()
        return { "CAT 1 ONLY", "SLATS SLOW", "D","E", "F"}
    end,
    
    get_cancelled_cautions = function()
        return {
            { title="NAV", text="IR 2 FAULT"}
        }
    end,
    
    get_inop_sys = function()
        return { "G+B HYD", "CAT 3", "G RSVR", "L+R AIL", "SPLR 1+3+5", "L ELEV", "AP 1+2", "REVERSER 1", "NORM BRK", "NW STEER" }
    end,
    
    get_maintenance = function()
        return { "A", "B","C"  }
    end
    
}



