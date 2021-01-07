local function draw_airports(data)
    if not data.config.is_active_arpt then
        return  -- Airport button not selected
    end
    
    -- 588 px is the diameter of our ring, so this corresponds to the range scale selected:
    local range_in_nm = math.floor(2^(data.config.range-1) * 10)
    -- Now we need to expand the search to the 900x900 size of the display:
    -- 588 : range_in_nm = 900 : range_search
    local range_search = range_in_nm * size[1] / 588
    
    -- I have to search in a square range_search x range_search
    
    
end
