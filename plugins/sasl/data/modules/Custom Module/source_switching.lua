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
        set(Capt_pfd_pfd_show, 1)
    else
        set(Capt_pfd_pfd_show, 0)
    end
    if get(Capt_pfd_displaying_status) == ND then
        set(Capt_pfd_nd_show, 1)
    else
        set(Capt_pfd_nd_show, 0)
    end
    if get(Capt_pfd_displaying_status) == EWD then
        set(Capt_pfd_ewd_show, 1)
    else
        set(Capt_pfd_ewd_show, 0)
    end
    if get(Capt_pfd_displaying_status) == ECAM then
        set(Capt_pfd_ecam_show, 1)
    else
        set(Capt_pfd_ecam_show, 0)
    end

    --capt ND show and hide--
    if get(Capt_nd_displaying_status) == PFD then
        set(Capt_nd_pfd_show, 1)
    else
        set(Capt_nd_pfd_show, 0)
    end
    if get(Capt_nd_displaying_status) == ND then
        set(Capt_nd_nd_show, 1)
    else
        set(Capt_nd_nd_show, 0)
    end
    if get(Capt_nd_displaying_status) == EWD then
        set(Capt_nd_ewd_show, 1)
    else
        set(Capt_nd_ewd_show, 0)
    end
    if get(Capt_nd_displaying_status) == ECAM then
        set(Capt_nd_ecam_show, 1)
    else
        set(Capt_nd_ecam_show, 0)
    end

    --FO PFD show and hide--
    if get(Fo_pfd_displaying_status) == PFD then
        set(Fo_pfd_pfd_show, 1)
    else
        set(Fo_pfd_pfd_show, 0)
    end
    if get(Fo_pfd_displaying_status) == ND then
        set(Fo_pfd_nd_show, 1)
    else
        set(Fo_pfd_nd_show, 0)
    end
    if get(Fo_pfd_displaying_status) == EWD then
        set(Fo_pfd_ewd_show, 1)
    else
        set(Fo_pfd_ewd_show, 0)
    end
    if get(Fo_pfd_displaying_status) == ECAM then
        set(Fo_pfd_ecam_show, 1)
    else
        set(Fo_pfd_ecam_show, 0)
    end

    --FO ND show and hide--
    if get(Fo_nd_displaying_status) == PFD then
        set(Fo_nd_pfd_show, 1)
    else
        set(Fo_nd_pfd_show, 0)
    end
    if get(Fo_nd_displaying_status) == ND then
        set(Fo_nd_nd_show, 1)
    else
        set(Fo_nd_nd_show, 0)
    end
    if get(Fo_nd_displaying_status) == EWD then
        set(Fo_nd_ewd_show, 1)
    else
        set(Fo_nd_ewd_show, 0)
    end
    if get(Fo_nd_displaying_status) == ECAM then
        set(Fo_nd_ecam_show, 1)
    else
        set(Fo_nd_ecam_show, 0)
    end

    --EWD show and hide--
    if get(EWD_displaying_status) == PFD then
        set(EWD_pfd_show, 1)
    else
        set(EWD_pfd_show, 0)
    end
    if get(EWD_displaying_status) == ND then
        set(EWD_nd_show, 1)
    else
        set(EWD_nd_show, 0)
    end
    if get(EWD_displaying_status) == EWD then
        set(EWD_ewd_show, 1)
    else
        set(EWD_ewd_show, 0)
    end
    if get(EWD_displaying_status) == ECAM then
        set(EWD_ecam_show, 1)
    else
        set(EWD_ecam_show, 0)
    end

    --ECAM show and hide--
    if get(ECAM_displaying_status) == PFD then
        set(ECAM_pfd_show, 1)
    else
        set(ECAM_pfd_show, 0)
    end
    if get(ECAM_displaying_status) == ND then
        set(ECAM_nd_show, 1)
    else
        set(ECAM_nd_show, 0)
    end
    if get(ECAM_displaying_status) == EWD then
        set(ECAM_ewd_show, 1)
    else
        set(ECAM_ewd_show, 0)
    end
    if get(ECAM_displaying_status) == ECAM then
        set(ECAM_ecam_show, 1)
    else
        set(ECAM_ecam_show, 0)
    end

end