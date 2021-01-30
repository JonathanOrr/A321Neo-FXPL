local TIME_LOGO = 2 -- In seconds

local delay_flag = false -- It tells you if we already showed the page or not, to avoid double button clicks
local click_time = 0 -- Time at which the user pressed the screen

--MOUSE & BUTTONS--
function EFB_execute_page_10_buttons()
    if EFB_PAGE == 10 and delay_flag then
        click_time = get(TIME)
        print("EFB On")
    end
end

--UPDATE LOOPS--
function EFB_update_page_10()

end

--DRAW LOOPS--
function EFB_draw_page_10()
  
  	delay_flag = true
  
    if click_time == 0 then	-- Screen is off
        sasl.gl.drawRectangle ( 0 , 0 , size[1] , size[2] , EFB_BLACK )
    elseif get(TIME) - click_time < TIME_LOGO then	-- Screen is showing logo
        sasl.gl.drawRectangle ( 0 , 0 , size[1] , size[2] , EFB_WHITE )
    else	-- Time to go back to the previous page
        EFB_PAGE = EFB_PREV_PAGE
        click_time = 0 -- Let's reset it for the future
        delay_flag = false
    end
end