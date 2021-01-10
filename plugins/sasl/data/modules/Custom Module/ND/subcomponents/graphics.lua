include('ND/subcomponents/constants.lua')
include('ND/subcomponents/graphics_common.lua')
include('ND/subcomponents/graphics_arc.lua')
include('ND/subcomponents/graphics_rose.lua')
include('ND/subcomponents/graphics_plan.lua')
include('ND/subcomponents/graphics_vorils.lua')

local image_mask_all = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-all.png")
local image_mask_arc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/mask-all.png")

function draw_main(data)

    if data.config.mode == ND_MODE_ILS or data.config.mode == ND_MODE_VOR or data.config.mode == ND_MODE_NAV then

        sasl.gl.drawMaskStart()
        sasl.gl.drawTexture(image_mask_all, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        
        draw_rose(data) -- The rose is drawn in all three cases

        if data.config.mode == ND_MODE_VOR then
            draw_rose_vor(data)
        elseif data.config.mode == ND_MODE_ILS then
            draw_rose_ils(data)
        end
        sasl.gl.drawMaskEnd()

        draw_rose_unmasked(data) -- The rose is drawn in all three cases
    elseif data.config.mode == ND_MODE_ARC then
        draw_arc_unmasked(data)
        
        sasl.gl.drawMaskStart()
        sasl.gl.drawTexture(image_mask_arc, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        draw_arc(data)
        sasl.gl.drawMaskEnd()

    elseif data.config.mode == ND_MODE_PLAN then
        draw_plan_unmasked(data)

        sasl.gl.drawMaskStart()
        sasl.gl.drawTexture(image_mask_all, 0,0,900,900)
        sasl.gl.drawUnderMask(true)
        draw_plan(data)
        sasl.gl.drawMaskEnd()
    end

    draw_common(data)

end
