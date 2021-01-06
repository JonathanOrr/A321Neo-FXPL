size = {900, 900}

local image_bkg_plan        = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/plan.png")
local image_bkg_plan_middle = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/ring-middle.png")

local COLOR_YELLOW = {1,1,0}

local function draw_ranges(data)
    -- Ranges
    if data.config.range > 0 then
        local ext_range = math.floor(2^(data.config.range-1) * 10 / 2) 
        local int_range = math.floor(ext_range / 2)
        sasl.gl.drawText(Font_AirbusDUL, 230, 250, ext_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, 365, 340, int_range, 20, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
    end

end

local function draw_background(data)
    sasl.gl.drawTexture(image_bkg_plan, (size[1]-621)/2,(size[2]-621)/2,621,621)
    sasl.gl.drawTexture(image_bkg_plan_middle, (size[1]-750)/2,(size[2]-750)/2,750,750)
end




local function rotate_point(point_to_rotate_x, point_to_rotate_y, center_of_rotation_x, center_of_rotation_y, angle)
    local cos_t = math.cos(math.rad(angle))
    local sin_t = math.sin(math.rad(angle))

    local x = cos_t * (point_to_rotate_x - center_of_rotation_x) - 
              sin_t * (point_to_rotate_y - center_of_rotation_y) + center_of_rotation_x

    local y = sin_t * (point_to_rotate_x - center_of_rotation_x) +
              cos_t * (point_to_rotate_y - center_of_rotation_y) + center_of_rotation_y

    return x,y
end


local function draw_plane(data)

    if not data.inputs.is_heading_valid then
        return
    end

    local plane_pos_x = 300
    local plane_pos_y = 200
    local angle = -data.inputs.heading
    
    -- Plane
    local x1, y1 = rotate_point(plane_pos_x, plane_pos_y-37, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x, plane_pos_y+37, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, COLOR_YELLOW)

    local x1, y1 = rotate_point(plane_pos_x-40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x+40, plane_pos_y+13, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, COLOR_YELLOW)

    local x1, y1 = rotate_point(plane_pos_x-15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)
    local x2, y2 = rotate_point(plane_pos_x+15, plane_pos_y-22, plane_pos_x, plane_pos_y, angle)    
    sasl.gl.drawWideLine(x1, y1, x2, y2, 4, COLOR_YELLOW)
    
end

function draw_plan_unmasked(data)
    draw_background(data)
    draw_ranges(data)
end
function draw_plan(data)
    draw_plane(data)
end

