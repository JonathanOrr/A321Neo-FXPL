size = { 400 , 200 }

--declare states--
local PFD = 1
local ND = 2
local EWD = 3
local ECAM = 4

--DMC colors
local DMC_BLACK = {0,0,0}
local DMC_WHITE = {1.0, 1.0, 1.0}
local DMC_BLUE = {0.004, 1.0, 1.0}
local DMC_GREEN = {0.184, 0.733, 0.219}
local DMC_ORANGE = {0.725, 0.521, 0.18}
local DMC_RED = {1, 0.0, 0.0}

local DMC_indicator_color = DMC_GREEN

--the color indications on the UI: green is normal function, amber is swiched to another no default source, red is a turned of display, white is manual source override
local capt_pfd_color = DMC_GREEN
local capt_pfd_text_color = DMC_WHITE
local capt_pfd_text = "PFD"
local capt_nd_color = DMC_GREEN
local capt_nd_text_color = DMC_WHITE
local capt_nd_text = "ND"
local fo_pfd_color = DMC_GREEN
local fo_pfd_text_color = DMC_WHITE
local fo_pfd_text = "PFD"
local fo_nd_color = DMC_GREEN
local fo_nd_text_color = DMC_WHITE
local fo_nd_text = "ND"
local ewd_color = DMC_GREEN
local ewd_text_color = DMC_WHITE
local ewd_text = "EWD"
local ecam_color = DMC_GREEN
local ecam_text_color = DMC_WHITE
local ecam_text = "ECAM"

--manual switching in progress
local manual_switching_in_progress = 0 --if the user is swiching the sources manually 1 swiching capt pfd , 2 switching capt nd, 3 switching ewd, 4 switching fo nd, 5 switching fo pfd, 6 switching ecam

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local B612MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--mouse functions
function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        --click region for EMC override--
        if x >= 335 and x <= 335 + 40 and y >= 170 and y <= 170 +20 then
            set(Override_DMC, 1 - get(Override_DMC))
        end

        if manual_switching_in_progress ~= 0 then
            --click regions for the sources--
            --PFD--
            if x >= size[1]/2 - 160 and x <= size[1]/2 - 160 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50 then
                if manual_switching_in_progress == 1 then
                    set(Capt_pfd_displaying_status, 1)
                elseif manual_switching_in_progress == 2 then
                    set(Capt_nd_displaying_status, 1)
                elseif manual_switching_in_progress == 3 then
                    set(EWD_displaying_status, 1)
                elseif manual_switching_in_progress == 4 then
                    set(Fo_nd_displaying_status, 1)
                elseif manual_switching_in_progress == 5 then
                    set(Fo_pfd_displaying_status, 1)
                elseif manual_switching_in_progress == 6 then
                    set(ECAM_displaying_status, 1)
                end
                manual_switching_in_progress = 0
                print("clicked pfd source")
                return
            end
            --ND--
            if x >= size[1]/2 - 70 and x <= size[1]/2 - 70 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50 then
                if manual_switching_in_progress == 1 then
                    set(Capt_pfd_displaying_status, 2)
                elseif manual_switching_in_progress == 2 then
                    set(Capt_nd_displaying_status, 2)
                elseif manual_switching_in_progress == 3 then
                    set(EWD_displaying_status, 2)
                elseif manual_switching_in_progress == 4 then
                    set(Fo_nd_displaying_status, 2)
                elseif manual_switching_in_progress == 5 then
                    set(Fo_pfd_displaying_status, 2)
                elseif manual_switching_in_progress == 6 then
                    set(ECAM_displaying_status, 2)
                end
                print("clicked nd source")
                manual_switching_in_progress = 0
                return
            end
            --EWD--
            if x >= size[1]/2 + 20 and x <= size[1]/2 + 20 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50 then
                if manual_switching_in_progress == 1 then
                    set(Capt_pfd_displaying_status, 3)
                elseif manual_switching_in_progress == 2 then
                    set(Capt_nd_displaying_status, 3)
                elseif manual_switching_in_progress == 3 then
                    set(EWD_displaying_status, 3)
                elseif manual_switching_in_progress == 4 then
                    set(Fo_nd_displaying_status, 3)
                elseif manual_switching_in_progress == 5 then
                    set(Fo_pfd_displaying_status, 3)
                elseif manual_switching_in_progress == 6 then
                    set(ECAM_displaying_status, 3)
                end
                print("clicked ewd source")
                manual_switching_in_progress = 0
                return
            end
            --ECAM--
            if x >= size[1]/2 + 110 and x <= size[1]/2 + 110 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50 then
                if manual_switching_in_progress == 1 then
                    set(Capt_pfd_displaying_status, 4)
                elseif manual_switching_in_progress == 2 then
                    set(Capt_nd_displaying_status, 4)
                elseif manual_switching_in_progress == 3 then
                    set(EWD_displaying_status, 4)
                elseif manual_switching_in_progress == 4 then
                    set(Fo_nd_displaying_status, 4)
                elseif manual_switching_in_progress == 5 then
                    set(Fo_pfd_displaying_status, 4)
                elseif manual_switching_in_progress == 6 then
                    set(ECAM_displaying_status, 4)
                end
                print("clicked ecam source")
                manual_switching_in_progress = 0
                return
            end

            --clicking anywhwere else
            if (x >= size[1]/2 - 160 and x <= size[1]/2 - 160 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50) or
                (x >= size[1]/2 - 70 and x <= size[1]/2 - 70 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50) or
                (x >= size[1]/2 + 20 and x <= size[1]/2 + 20 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50) or
                (x >= size[1]/2 + 110 and x <= size[1]/2 + 110 + 50 and y >= size[2]/2 - 25 and y <= size[2]/2 - 25 + 50) then
            else
                print("clicked somewhere else")
                manual_switching_in_progress = 0
                return
            end
        end

        if get(Override_DMC) == 1 then
            if manual_switching_in_progress == 0 then
                --click regions for the screens--
                --Capt PFD--
                if x >= size[1]/2 - 175 and x <= size[1]/2 - 175 + 50 and y >= size[2]/2 + 10 and y <= size[2]/2 + 10 + 50 then
                    print("clicked capt pfd")
                    manual_switching_in_progress = 1
                end
                --Capt ND--
                if x >= size[1]/2 - 100 and x <= size[1]/2 - 100 + 50 and y >= size[2]/2 + 10 and y <= size[2]/2 + 10 + 50 then
                    print("clicked capt nd")
                    manual_switching_in_progress = 2
                end
                --EWD--
                if x >= size[1]/2 - 25 and x <= size[1]/2 - 25 + 50 and y >= size[2]/2 + 10 and y <= size[2]/2 + 10 + 50 then
                    print("clicked ewd")
                    manual_switching_in_progress = 3
                end
                --FO ND--
                if x >= size[1]/2 + 50 and x <= size[1]/2 + 50 + 50 and y >= size[2]/2 + 10 and y <= size[2]/2 + 10 + 50 then
                    print("clicked fo nd")
                    manual_switching_in_progress = 4
                end
                --FO PFD--
                if x >= size[1]/2 + 125 and x <= size[1]/2 + 125 + 50 and y >= size[2]/2 + 10 and y <= size[2]/2 + 10 + 50 then
                    print("clicked fo pfd")
                    manual_switching_in_progress = 5
                end
                --ECAM--
                if x >= size[1]/2 - 25 and x <= size[1]/2 - 25 + 50 and y >= size[2]/2 - 65 and y <= size[2]/2 - 65 + 50 then
                    print("clicked ecam")
                    manual_switching_in_progress = 6
                end
            end
        end
    end
end

function update()
    --capt PFD show and hide--
    if get(Capt_pfd_displaying_status) == PFD then
        capt_pfd_color = DMC_GREEN
        capt_pfd_text_color = DMC_GREEN
        capt_pfd_text = "PFD"
    elseif get(Capt_pfd_displaying_status) == ND then
        capt_pfd_color = DMC_ORANGE
        capt_pfd_text_color = DMC_ORANGE
        capt_pfd_text = "ND"
    elseif get(Capt_pfd_displaying_status) == EWD then
        capt_pfd_color = DMC_ORANGE
        capt_pfd_text_color = DMC_ORANGE
        capt_pfd_text = "EWD"
    elseif get(Capt_pfd_displaying_status) == ECAM then
        capt_pfd_color = DMC_ORANGE
        capt_pfd_text_color = DMC_ORANGE
        capt_pfd_text = "ECAM"
    end

    --capt ND show and hide--
    if get(Capt_nd_displaying_status) == PFD then
        capt_nd_color = DMC_ORANGE
        capt_nd_text_color = DMC_ORANGE
        capt_nd_text = "PFD"
    elseif get(Capt_nd_displaying_status) == ND then
        capt_nd_color = DMC_GREEN
        capt_nd_text_color = DMC_GREEN
        capt_nd_text = "ND"
    elseif get(Capt_nd_displaying_status) == EWD then
        capt_nd_color = DMC_ORANGE
        capt_nd_text_color = DMC_ORANGE
        capt_nd_text = "EWD"
    elseif get(Capt_nd_displaying_status) == ECAM then
        capt_nd_color = DMC_ORANGE
        capt_nd_text_color = DMC_ORANGE
        capt_nd_text = "ECAM"
    end

    --FO PFD show and hide--
    if get(Fo_pfd_displaying_status) == PFD then
        fo_pfd_color = DMC_GREEN
        fo_pfd_text_color = DMC_GREEN
        fo_pfd_text = "PFD"
    elseif get(Fo_pfd_displaying_status) == ND then
        fo_pfd_color = DMC_ORANGE
        fo_pfd_text_color = DMC_ORANGE
        fo_pfd_text = "ND"
    elseif get(Fo_pfd_displaying_status) == EWD then
        fo_pfd_color = DMC_ORANGE
        fo_pfd_text_color = DMC_ORANGE
        fo_pfd_text = "EWD"
    elseif get(Fo_pfd_displaying_status) == ECAM then
        fo_pfd_color = DMC_ORANGE
        fo_pfd_text_color = DMC_ORANGE
        fo_pfd_text = "ECAM"
    end

    --FO ND show and hide--
    if get(Fo_nd_displaying_status) == PFD then
        fo_nd_color = DMC_ORANGE
        fo_nd_text_color = DMC_ORANGE
        fo_nd_text = "PFD"
    elseif get(Fo_nd_displaying_status) == ND then
        fo_nd_color = DMC_GREEN
        fo_nd_text_color = DMC_GREEN
        fo_nd_text = "ND"
    elseif get(Fo_nd_displaying_status) == EWD then
        fo_nd_color = DMC_ORANGE
        fo_nd_text_color = DMC_ORANGE
        fo_nd_text = "EWD"
    elseif get(Fo_nd_displaying_status) == ECAM then
        fo_nd_color = DMC_ORANGE
        fo_nd_text_color = DMC_ORANGE
        fo_nd_text = "ECAM"
    end

    --EWD show and hide--
    if get(EWD_displaying_status) == PFD then
        ewd_color = DMC_ORANGE
        ewd_text_color = DMC_ORANGE
        ewd_text = "PFD"
    elseif get(EWD_displaying_status) == ND then
        ewd_color = DMC_ORANGE
        ewd_text_color = DMC_ORANGE
        ewd_text = "ND"
    elseif get(EWD_displaying_status) == EWD then
        ewd_color = DMC_GREEN
        ewd_text_color = DMC_GREEN
        ewd_text = "EWD"
    elseif get(EWD_displaying_status) == ECAM then
        ewd_color = DMC_ORANGE
        ewd_text_color = DMC_ORANGE
        ewd_text = "ECAM"
    end

    --ECAM show and hide--
    if get(ECAM_displaying_status) == PFD then
        ecam_color = DMC_ORANGE
        ecam_text_color = DMC_ORANGE
        ecam_text = "PFD"
    elseif get(ECAM_displaying_status) == ND then
        ecam_color = DMC_ORANGE
        ecam_text_color = DMC_ORANGE
        ecam_text = "ND"
    elseif get(ECAM_displaying_status) == EWD then
        ecam_color = DMC_ORANGE
        ecam_text_color = DMC_ORANGE
        ecam_text = "EWD"
    elseif get(ECAM_displaying_status) == ECAM then
        ecam_color = DMC_GREEN
        ecam_text_color = DMC_GREEN
        ecam_text = "ECAM"
    end

    if get(Override_DMC) == 0 then
        manual_switching_in_progress = 0

        DMC_indicator_color = DMC_GREEN

        capt_pfd_text_color = DMC_WHITE
        capt_nd_text_color = DMC_WHITE
        fo_pfd_text_color = DMC_WHITE
        fo_nd_text_color = DMC_WHITE
        ewd_text_color = DMC_WHITE
        ecam_text_color = DMC_WHITE
    else
        DMC_indicator_color = DMC_RED

        capt_pfd_color = DMC_WHITE
        capt_nd_color = DMC_WHITE
        fo_pfd_color = DMC_WHITE
        fo_nd_color = DMC_WHITE
        ewd_color = DMC_WHITE
        ecam_color = DMC_WHITE
    end
end

function draw()
    sasl.gl.drawRectangle(0, 0, 400, 200, DMC_BLACK)
    --DMC override indication
    sasl.gl.drawFrame(335, 170, 40, 20, DMC_indicator_color)
    sasl.gl.drawText(B612MONO_regular, 354, 173, "DMC", 16, false, false, TEXT_ALIGN_CENTER, DMC_indicator_color)

    if manual_switching_in_progress == 0 then
        --Capt PFD--
        sasl.gl.drawRectangle(size[1]/2 - 175, size[2]/2 + 10, 50, 50, capt_pfd_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 - 150, size[2]/2 + 27, capt_pfd_text, 19.5, false, false, TEXT_ALIGN_CENTER, capt_pfd_text_color)
        --Capt ND--
        sasl.gl.drawRectangle(size[1]/2 - 100, size[2]/2 + 10, 50, 50, capt_nd_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 - 75, size[2]/2 + 27, capt_nd_text, 19.5, false, false, TEXT_ALIGN_CENTER, capt_nd_text_color)
        --EWD--
        sasl.gl.drawRectangle(size[1]/2 - 25, size[2]/2 + 10, 50, 50, ewd_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2, size[2]/2 + 27, ewd_text, 19.5, false, false, TEXT_ALIGN_CENTER, ewd_text_color)
        --FO ND--
        sasl.gl.drawRectangle(size[1]/2 + 50, size[2]/2 + 10, 50, 50, fo_nd_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 + 75, size[2]/2 + 27, fo_nd_text, 19.5, false, false, TEXT_ALIGN_CENTER, fo_nd_text_color)
        --FO PFD--
        sasl.gl.drawRectangle(size[1]/2 + 125, size[2]/2 + 10, 50, 50, fo_pfd_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 + 150, size[2]/2 + 27, fo_pfd_text, 19.5, false, false, TEXT_ALIGN_CENTER, fo_pfd_text_color)
        --ECAM--
        sasl.gl.drawRectangle(size[1]/2 - 25, size[2]/2 - 65, 50, 50, ecam_color)
        sasl.gl.drawText(B612MONO_bold, size[1]/2, size[2]/2 - 48, ecam_text, 19.5, false, false, TEXT_ALIGN_CENTER, ecam_text_color)
    else
        sasl.gl.drawText(B612MONO_regular, size[1]/2, size[2]/2 + 45, "PLEASE SELECT SOURCE", 22, false, false, TEXT_ALIGN_CENTER, DMC_WHITE)

        sasl.gl.drawRectangle(size[1]/2 - 160, size[2]/2 - 25, 50, 50, DMC_WHITE)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 - 135, size[2]/2 - 8, "PFD", 19.5, false, false, TEXT_ALIGN_CENTER, DMC_BLACK)
        sasl.gl.drawRectangle(size[1]/2 - 70, size[2]/2 - 25, 50, 50, DMC_WHITE)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 - 45, size[2]/2 - 8, "ND", 19.5, false, false, TEXT_ALIGN_CENTER, DMC_BLACK)
        sasl.gl.drawRectangle(size[1]/2 + 20, size[2]/2 - 25, 50, 50, DMC_WHITE)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 + 45, size[2]/2 - 8, "EWD", 19.5, false, false, TEXT_ALIGN_CENTER, DMC_BLACK)
        sasl.gl.drawRectangle(size[1]/2 + 110, size[2]/2 - 25, 50, 50, DMC_WHITE)
        sasl.gl.drawText(B612MONO_bold, size[1]/2 + 135, size[2]/2 - 8, "ECAM", 19.5, false, false, TEXT_ALIGN_CENTER, DMC_BLACK)
    end
end