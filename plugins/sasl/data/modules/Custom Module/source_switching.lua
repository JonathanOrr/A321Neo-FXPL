--declare states--
local PFD = 1
local ND = 2
local EWD = 3
local ECAM = 4

--a32nx datarefs

function update()
    
    if get(Display_source_override) then
        set(Capt_pfd_displaying_status, PFD)
        set(Capt_nd_displaying_status, ND)
        set(Fo_pfd_displaying_status, PFD)
        set(Fo_nd_displaying_status, ND)
        set(EWD_displaying_status, EWD)
        set(ECAM_displaying_status, ECAM)
    end

end