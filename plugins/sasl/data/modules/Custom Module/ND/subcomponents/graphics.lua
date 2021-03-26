include('ND/subcomponents/constants.lua')
include('ND/subcomponents/graphics_common.lua')
include('ND/subcomponents/graphics_arc.lua')
include('ND/subcomponents/graphics_rose.lua')
include('ND/subcomponents/graphics_plan.lua')
include('ND/subcomponents/graphics_vorils.lua')
include('ND/subcomponents/graphics_mouse.lua')


local image_mask_rose = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-rose.png")
local image_mask_arc  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-arc.png")
local image_mask_plan = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-plan.png")
local image_mask_oans = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-oans.png")

function draw_main(data)

    if data.config.mode ~= ND_MODE_PLAN then
        data.plan_ctr_lat = 0
        data.plan_ctr_lon = 0
    end
    
    if data.config.mode == ND_MODE_ILS or data.config.mode == ND_MODE_VOR or data.config.mode == ND_MODE_NAV then

        sasl.gl.drawMaskStart()
        local mask_texture = data.config.range <= ND_RANGE_ZOOM_2 and image_mask_oans or image_mask_rose
        sasl.gl.drawTexture(mask_texture, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        
        draw_rose(data) -- The rose is drawn in all three cases

        if data.config.mode == ND_MODE_VOR then
            draw_rose_vor(data)
        elseif data.config.mode == ND_MODE_ILS then
            draw_rose_ils(data)
        end
        sasl.gl.drawMaskEnd()

        draw_rose_unmasked(data) -- The rose is drawn in all three cases
        if data.config.mode == ND_MODE_VOR or data.config.mode == ND_MODE_ILS then
            draw_rose_vorils_unmasked(data)
        end
    elseif data.config.mode == ND_MODE_ARC then
        sasl.gl.drawMaskStart()
        local mask_texture = data.config.range <= ND_RANGE_ZOOM_2 and image_mask_oans or image_mask_arc
        sasl.gl.drawTexture(mask_texture, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        draw_arc(data)
        sasl.gl.drawMaskEnd()

        draw_arc_unmasked(data)
    elseif data.config.mode == ND_MODE_PLAN then
        sasl.gl.drawMaskStart()
        local mask_texture = data.config.range <= ND_RANGE_ZOOM_2 and image_mask_oans or image_mask_plan
        sasl.gl.drawTexture(mask_texture, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        draw_plan(data)
        sasl.gl.drawMaskEnd()

        draw_plan_unmasked(data)
    end

    draw_common(data)
    draw_mouse(data)

end
