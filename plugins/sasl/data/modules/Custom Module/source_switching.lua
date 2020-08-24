--declare states--
local PFD = 1
local ND = 2
local EWD = 3
local ECAM = 4

--a32nx datarefs

function update()
    if get(Override_DMC) == 0 then
        set(Capt_pfd_displaying_status, 1)
        set(Capt_nd_displaying_status, 2)
        set(Fo_pfd_displaying_status, 1)
        set(Fo_nd_displaying_status, 2)
        set(EWD_displaying_status, 3)
        set(ECAM_displaying_status, 4)
    end

    --capt PFD show and hide--
    if get(Capt_pfd_displaying_status) == PFD then
        set(Capt_pfd_show, 1, 1)
    else
        set(Capt_pfd_show, 0, 1)
    end
    if get(Capt_pfd_displaying_status) == ND then
        set(Capt_pfd_show, 1, 2)
    else
        set(Capt_pfd_show, 0, 2)
    end
    if get(Capt_pfd_displaying_status) == EWD then
        set(Capt_pfd_show, 1, 3)
    else
        set(Capt_pfd_show, 0, 3)
    end
    if get(Capt_pfd_displaying_status) == ECAM then
        set(Capt_pfd_show, 1, 4)
    else
        set(Capt_pfd_show, 0, 4)
    end

    --capt ND show and hide--
    if get(Capt_nd_displaying_status) == PFD then
        set(Capt_nd_show, 1, 1)
    else
        set(Capt_nd_show, 0, 1)
    end
    if get(Capt_nd_displaying_status) == ND then
        set(Capt_nd_show, 1, 2)
    else
        set(Capt_nd_show, 0, 2)
    end
    if get(Capt_nd_displaying_status) == EWD then
        set(Capt_nd_show, 1, 3)
    else
        set(Capt_nd_show, 0, 3)
    end
    if get(Capt_nd_displaying_status) == ECAM then
        set(Capt_nd_show, 1, 4)
    else
        set(Capt_nd_show, 0, 4)
    end

    --FO PFD show and hide--
    if get(Fo_pfd_displaying_status) == PFD then
        set(Fo_pfd_show, 1, 1)
    else
        set(Fo_pfd_show, 0, 1)
    end
    if get(Fo_pfd_displaying_status) == ND then
        set(Fo_pfd_show, 1, 2)
    else
        set(Fo_pfd_show, 0, 2)
    end
    if get(Fo_pfd_displaying_status) == EWD then
        set(Fo_pfd_show, 1, 3)
    else
        set(Fo_pfd_show, 0, 3)
    end
    if get(Fo_pfd_displaying_status) == ECAM then
        set(Fo_pfd_show, 1, 4)
    else
        set(Fo_pfd_show, 0, 4)
    end

    --FO ND show and hide--
    if get(Fo_nd_displaying_status) == PFD then
        set(Fo_nd_show, 1, 1)
    else
        set(Fo_nd_show, 0, 1)
    end
    if get(Fo_nd_displaying_status) == ND then
        set(Fo_nd_show, 1, 2)
    else
        set(Fo_nd_show, 0, 2)
    end
    if get(Fo_nd_displaying_status) == EWD then
        set(Fo_nd_show, 1, 3)
    else
        set(Fo_nd_show, 0, 3)
    end
    if get(Fo_nd_displaying_status) == ECAM then
        set(Fo_nd_show, 1, 4)
    else
        set(Fo_nd_show, 0, 4)
    end

    --EWD show and hide--
    if get(EWD_displaying_status) == PFD then
        set(EWD_show, 1, 1)
    else
        set(EWD_show, 0, 1)
    end
    if get(EWD_displaying_status) == ND then
        set(EWD_show, 1, 2)
    else
        set(EWD_show, 0, 2)
    end
    if get(EWD_displaying_status) == EWD then
        set(EWD_show, 1, 3)
    else
        set(EWD_show, 0, 3)
    end
    if get(EWD_displaying_status) == ECAM then
        set(EWD_show, 1, 4)
    else
        set(EWD_show, 0, 4)
    end

    --ECAM show and hide--
    if get(ECAM_displaying_status) == PFD then
        set(ECAM_show, 1, 1)
    else
        set(ECAM_show, 0, 1)
    end
    if get(ECAM_displaying_status) == ND then
        set(ECAM_show, 1, 2)
    else
        set(ECAM_show, 0, 2)
    end
    if get(ECAM_displaying_status) == EWD then
        set(ECAM_show, 1, 3)
    else
        set(ECAM_show, 0, 3)
    end
    if get(ECAM_displaying_status) == ECAM then
        set(ECAM_show, 1, 4)
    else
        set(ECAM_show, 0, 4)
    end

end