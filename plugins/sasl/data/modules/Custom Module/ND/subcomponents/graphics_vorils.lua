
local image_h_deviation_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vorils-dev.png")

local image_deviation_ind = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-outer-ring.png")
local image_deviation_arrow = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-arrow-ring.png")

size = {900, 900}

local function leading_zeros_int(num, num_total)
    return string.format("%0" .. num_total .. "d", num) 
end

local function draw_upper_right_info(data, typ)    -- typ 1: vor, 2: ils
    local curr_nav = data.inputs.which_nav_is_active
    if curr_nav == 0 then
        return -- No active vor
    end

    sasl.gl.drawText(Font_AirbusDUL, size[1]-250, size[2]-50, (typ == 1 and "VOR" or "ILS") .. curr_nav, 34, false, false, TEXT_ALIGN_LEFT, (not data.nav[curr_nav].is_valid or data.nav[curr_nav].selector ~= ND_SEL_VOR) and ECAM_RED or ECAM_WHITE)

    if data.nav[curr_nav].selector ~= ND_SEL_VOR then
        return 
    end

    -- Frequency
    sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-50, math.floor(data.nav[curr_nav].frequency/100), 34, false, false, TEXT_ALIGN_LEFT, typ == 1 and ECAM_WHITE or ECAM_MAGENTA)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-70, size[2]-50, "." .. leading_zeros_int(data.nav[curr_nav].frequency%100, 2), 28, false, false, TEXT_ALIGN_LEFT, typ == 1 and ECAM_WHITE or ECAM_MAGENTA)
    
    -- CRS
    sasl.gl.drawText(Font_AirbusDUL, size[1]-170, size[2]-90, "CRS", 34, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    if data.nav[curr_nav].crs_is_computed then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-90, data.nav[curr_nav].crs .. "°", 34, false, false, TEXT_ALIGN_RIGHT, typ == 1 and ECAM_BLUE or ECAM_MAGENTA)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-90, "---°", 34, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)    
    end        
    -- Identifier
    sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-130, data.nav[curr_nav].identifier, 34, false, false, TEXT_ALIGN_RIGHT, typ == 1 and ECAM_WHITE or ECAM_MAGENTA)

    -- Tuned symbol
    local tuned_symbol = ""
    if data.nav[curr_nav].tuning_type == ND_NAV_TUNED_M then
        tuned_symbol = "M"
    elseif data.nav[curr_nav].tuning_type == ND_NAV_TUNED_R then
        tuned_symbol = "R"
    end
    
    if tuned_symbol ~= "" then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-130, tuned_symbol, 22, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawWideLine(size[1]-130, size[2]-135, size[1]-140, size[2]-135, 2, ECAM_WHITE)
    end

end

local function draw_rose_vor_indication(data)
    local curr_nav = data.inputs.which_nav_is_active
    if curr_nav == 0 then
        return -- No active vor
    end

    local angle = 0
    if data.nav[curr_nav].crs_is_computed then
        angle = data.nav[curr_nav].crs
    else
        angle = data.inputs.heading -- Stay at zero
    end
    
    sasl.gl.drawRotatedTexture(image_h_deviation_sym, -data.inputs.heading+angle, (size[1]-500)/2,(size[2]-176)/2,500,176, {1,1,1})
    sasl.gl.drawRotatedTexture(image_deviation_ind, -data.inputs.heading+angle, (size[1]-75)/2,(size[2]-590)/2,75,590, {1,1,1})

    --image_deviation_arrow
    if data.nav[curr_nav].deviation_is_visible then
        
        local degrees = data.nav[curr_nav].deviation_deg
        local degrees_clamp = Math_clamp(degrees, -11, 11)
        if degrees_clamp ~= degrees and get(TIME) % 1 < 0.5 then
            return
        end
        local degrees_px = degrees_clamp / 5 * 88
        sasl.gl.drawRotatedTextureCenter(image_deviation_arrow, -data.inputs.heading+angle, size[1]/2, size[2]/2, (size[1]-28)/2+degrees_px,(size[2]-176)/2, 28,176, {1,1,1})
    end


end

function draw_rose_vor(data)
    draw_upper_right_info(data, 1)
    draw_rose_vor_indication(data)
end

function draw_rose_ils(data)
    draw_upper_right_info(data, 2)
end
