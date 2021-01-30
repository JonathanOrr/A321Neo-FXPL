local TIME_LOGO = 4 -- In seconds

local delay_flag = false -- It tells you if we already showed the page or not, to avoid double button clicks
local click_time = 0 -- Time at which the user pressed the screen

--MOUSE & BUTTONS--
function EFB_execute_page_10_buttons()
    if EFB_PAGE == 10 and delay_flag then
        click_time = get(TIME)
    end
end

--UPDATE LOOPS--
function EFB_update_page_10()

end

local function draw_logo()
    local color = {1, 1, 1, 1}
  	-- Here, you have to compute color[4] based on a sin wave
	color[4] = math.sin(Math_rescale_no_lim(0, math.pi/2, TIME_LOGO, 0, get(TIME) - click_time))
    SASL_draw_img_center_aligned(EFB_CSS_logo, size[1]/2, size[2]/2, 589, 530, color)
end

--DRAW LOOPS--
function EFB_draw_page_10()
  
  	delay_flag = true
  
    if click_time == 0 then	-- Screen is off
        sasl.gl.drawRectangle ( 0 , 0 , size[1] , size[2] , EFB_BLACK )
    elseif get(TIME) - click_time < TIME_LOGO then	-- Screen is showing logo
        sasl.gl.drawRectangle ( 0 , 0 , size[1] , size[2] , EFB_WHITE )
    	draw_logo()
    else	-- Time to go back to the previous page
        EFB_PAGE = EFB_PREV_PAGE
        click_time = 0 -- Let's reset it for the future
        delay_flag = false
    end
end

