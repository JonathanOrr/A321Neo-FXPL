position= {0,0,250,250}
size = {500, 500}

function draw()
    if ISIS_window:isVisible() then
        local window_x, window_y, window_width, window_height = ISIS_window:getPosition()
        ISIS_window:setPosition ( window_x , window_y , window_width, window_width)
    end
    sasl.gl.drawTexture(ISIS_popup_texture, 0, 0, 500, 500, {1,1,1})
end