
local BTN_WIDTH  = 150
local BTN_HEIGHT = 39


function draw_waypoints()
    sasl.gl.drawWideLine(100,100,100,500,3,UI_WHITE)
    sasl.gl.drawWideLine(900,100,900,500,3,UI_WHITE)

    sasl.gl.drawWideLine(100,500,900,500,3,ECAM_GREEN)

    local max_alt = FMGS_sys.data.init.crz_fl or 40000
    sasl.gl.drawText(Font_B612MONO_regular, 10, 495, max_alt, 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 370, 3*max_alt/4, 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 245, max_alt/2, 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10, 120, max_alt/4, 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    
    local s_px = 100
    local e_px = 900

    local legs = FMGS_sys.pred_debug.get_big_array()
    if not legs then
        return
    end
    local tot = #legs
    if tot == 1 then
        tot = 2 -- Just to avoid division by zero
    end
    local prev_px_alt
    for i,leg in ipairs(legs) do
        local inc = (e_px-s_px)/(tot-1)
        local x = s_px + inc * (i - 1)
        sasl.gl.drawWideLine(x,70,x,80,3,UI_WHITE)
        sasl.gl.drawRotatedText(Font_B612MONO_regular, x-2, 40, x-2, 40, 90,
                                leg.id or "[UNKN]", 11, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

        local leg_alt = leg.pred.altitude
        if leg_alt then
            local px_alt = (leg_alt / max_alt) * (500-100);
            if prev_px_alt then
                sasl.gl.drawWideLine(x-inc,100+prev_px_alt,x,100+px_alt,3,UI_LIGHT_BLUE)
            end
            prev_px_alt = px_alt
        end

        if leg.cstr_alt_type == CIFP_CSTR_ALT_BELOW then
            -- If altitude is Below or At (or the block) take it for the climb
            local alt = leg.cstr_altitude1
            if leg.cstr_altitude1_fl then
                alt = alt * 100
            end
            local px_cstr = (alt / max_alt) * (500-100); 
            sasl.gl.drawWideLine(x-10,100+px_cstr, x+10,100+px_cstr,2,ECAM_GREEN)
            sasl.gl.drawWideLine(x,100+px_cstr, x,100+px_cstr-10,2,ECAM_GREEN)
            sasl.gl.drawWideLine(x-5,100+px_cstr-5, x,100+px_cstr-10,2,ECAM_GREEN)
            sasl.gl.drawWideLine(x+5,100+px_cstr-5, x,100+px_cstr-10,2,ECAM_GREEN)
        end
        if leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE or leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND then
            -- If altitude is Below or At (or the block) take it for the climb
            local alt = leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE and leg.cstr_altitude1 or leg.cstr_altitude2
            if (leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE and leg.cstr_altitude1_fl) or (leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND and leg.cstr_altitude2_fl) then
                alt = alt * 100
            end
            local px_cstr = (alt / max_alt) * (500-100); 
            sasl.gl.drawWideLine(x-10,100+px_cstr, x+10,100+px_cstr,2,ECAM_RED)
            sasl.gl.drawWideLine(x,100+px_cstr, x,100+px_cstr+10,2,ECAM_RED)
            sasl.gl.drawWideLine(x-5,100+px_cstr+5, x,100+px_cstr+10,2,ECAM_RED)
            sasl.gl.drawWideLine(x+5,100+px_cstr+5, x,100+px_cstr+10,2,ECAM_RED)
            print(leg.id, alt)
        end
        if leg.cstr_alt_type == CIFP_CSTR_ALT_AT then
            -- If altitude is Below or At (or the block) take it for the climb
            local alt = leg.cstr_altitude1
            if leg.cstr_altitude1_fl then
                alt = alt * 100
            end
            local px_cstr = (alt / max_alt) * (500-100); 
            sasl.gl.drawWideLine(x-10,100+px_cstr+5, x+10,100+px_cstr+5,2,ECAM_ORANGE)
            sasl.gl.drawWideLine(x-10,100+px_cstr-5, x+10,100+px_cstr-5,2,ECAM_ORANGE)
        end

    end

end

function draw_cstrs()

    draw_waypoints()

    if FMGS_sys.data.pred.invalid then
        sasl.gl.drawText(Font_B612MONO_regular, 650, 490, "Invalid Vertical Profile.", 16, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
    end

end
