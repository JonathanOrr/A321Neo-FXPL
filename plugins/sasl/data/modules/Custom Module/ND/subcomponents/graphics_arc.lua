size = {900, 900}

local image_bkg_arc        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc.png")
local image_bkg_arc_red    = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc-red.png")
local image_bkg_arc_inner  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/arc-inner.png")
local image_bkg_arc_tcas   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-arc.png")

local image_track_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-track-arc.png")
local image_hdgsel_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-hdgsel-arc.png")

local image_ils_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-arc.png")
local image_ils_nonprec_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-nonprec-arc.png")

local COLOR_YELLOW = {1,1,0}

local function draw_backgrounds(data)
    -- Main rose background
    if data.inputs.is_heading_valid then
        sasl.gl.drawRotatedTexture(image_bkg_arc, -data.inputs.heading, (size[1]-1330)/2,(size[2]-1330)/2-312,1330,1330, {1,1,1})
        sasl.gl.drawTexture(image_bkg_arc_inner, (size[1]-898)/2,(size[2]-568)/2-13,898,568, {1,1,1})
        
        if data.misc.tcas_ta_triggered or data.misc.tcas_ra_triggered or data.config.range == ND_RANGE_20 then

            -- Inner (TCAS) circle is activated only when:
            -- - Range is 10, or
            -- - TCAS RA or TA activates
            sasl.gl.drawTexture(image_bkg_arc_tcas, (size[1]-122)/2,(size[2]-41)/2-252,122,41, {1,1,1})
        end
        
    else
        -- Heading not available
       sasl.gl.drawTexture(image_bkg_arc_red, (size[1]-898)/2,(size[2]-600)/2-30,898,600, {1,1,1})
    end
end

local function draw_fixed_symbols(data)

    if not data.inputs.is_heading_valid then
        return
    end

    -- Plane
    sasl.gl.drawWideLine(410, 145, 490, 145, 4, COLOR_YELLOW)
    sasl.gl.drawWideLine(450, 95, 450, 170, 4, COLOR_YELLOW)   -- H=75
    sasl.gl.drawWideLine(435, 110, 465, 110, 4, COLOR_YELLOW)

    -- Top heading indicator (yellow)
    sasl.gl.drawWideLine(450, 690, 450, 740, 5, COLOR_YELLOW)
    
end

local function draw_track_symbol(data)
    if not data.inputs.is_track_valid then
        return
    end
    
    if math.abs(data.inputs.track-data.inputs.heading) > 110 then
        return -- not visible, out of visible area
    end

    sasl.gl.drawRotatedTexture(image_track_sym, (data.inputs.track-data.inputs.heading), (size[1]-17)/2,(size[2]-1154)/2-312,17,1154, {1,1,1})
end

local function draw_hdgsel_symbol(data)

    if not data.inputs.hdg_sel_visible then
        return
    end


    if math.abs(data.inputs.hdg_sel-data.inputs.heading) > 50 then
        -- If the HDG sel is over the limit of the arc, then we write the text at left or right depending
        -- on where it is.
        
        local start_x = ((data.inputs.heading - data.inputs.hdg_sel)%180 > 0) and size[1]-40 or 40   -- true -> right, false -> left
        
        -- TODO Rotate
        sasl.gl.drawText(Font_AirbusDUL, start_x, 575 , data.inputs.hdg_sel , 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)    
        return -- not visible, out of visible area
    end

    
    sasl.gl.drawRotatedTexture(image_hdgsel_sym, (data.inputs.hdg_sel-data.inputs.heading), (size[1]-32)/2,(size[2]-1201)/2-312,32,1201, {1,1,1})
end


local function draw_ls_symbol(data)

    if not data.inputs.ls_is_visible then
        return
    end
    
    sasl.gl.drawRotatedTexture(data.inputs.ls_is_precise and image_ils_sym or image_ils_nonprec_sym,
                              (data.inputs.ls_direction-data.inputs.heading+180), (size[1]-19)/2,(size[2]-1217)/2-312,19,1217, {1,1,1})
end

local function draw_ranges(data)

    if data.config.range > 0 then
        local second_ring = math.floor(2^(data.config.range-1) * 10 * 3 / 4)
        local third_ring  = math.floor(2^(data.config.range-1) * 10 * 2 / 4)

        if data.config.range == 1 then
            second_ring = "7.5"  -- This is the only one not integer
        end
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-240, 250, third_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2-370, 320, second_ring, 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2+240, 250, third_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[2]/2+370, 320, second_ring, 24, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end    
    
end

function draw_arc_unmasked(data)
    draw_backgrounds(data)
    draw_fixed_symbols(data)
    draw_ranges(data)
    draw_track_symbol(data)
    draw_hdgsel_symbol(data)
    draw_ls_symbol(data)
end

function draw_arc(data)

end
