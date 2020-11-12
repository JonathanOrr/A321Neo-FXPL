size = {500, 300}

include('constants.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function draw()

    Sasl_DrawWideFrame(150, 100, 200, 100, 3, 1, ECAM_WHITE)
    
    sasl.gl.drawText(Font_AirbusDUL, 10, 30, "Outside local pressure (inhg): ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 10, 10, "Outside sea-level pressure (inhg): ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 270, 30, Round_fill(get(Weather_curr_press_flight_level),2), 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 270, 10, Round_fill(get(Weather_curr_press_sea_level),2), 12, false, false, TEXT_ALIGN_LEFT, UI_LIGHT_BLUE)

    -- Outflow valve    
    sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]/2+20, "Outflow valve", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawWideLine ( size[1]-170, size[2]/2, size[1]-100, size[2]/2, 1 , ECAM_WHITE)
    
    if get(Press_outflow_valve_flow) > 0 then
        sasl.gl.drawWideLine ( size[1]-110, size[2]/2-10, size[1]-100, size[2]/2, 2 , ECAM_GREEN)
        sasl.gl.drawWideLine ( size[1]-110, size[2]/2+10, size[1]-100, size[2]/2, 2 , ECAM_GREEN)
    elseif get(Press_outflow_valve_flow) < 0 then
        sasl.gl.drawWideLine ( size[1]-160, size[2]/2-10, size[1]-170, size[2]/2, 2 , ECAM_GREEN)
        sasl.gl.drawWideLine ( size[1]-160, size[2]/2+10, size[1]-170, size[2]/2, 2 , ECAM_GREEN)
    end
    
    sasl.gl.drawText(Font_AirbusDUL, size[1]-140, size[2]/2-30, "Position:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-140, size[2]/2-45, "Flow:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-140, size[2]/2-60, "Press. out:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, size[1], size[2]/2-30, Round_fill(get(Out_flow_valve_ratio),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1], size[2]/2-45, Round_fill(get(Press_outflow_valve_flow),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1], size[2]/2-60, Round_fill(get(Press_outflow_valve_press),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    -- Internal
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, size[2]/2+25, "Int. press.:", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, size[2]/2+5, "Delta P:", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, size[2]/2-15, "Cabin alt.:", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+20, size[2]/2-35, "Cabin V/S:", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)

    local int_psi = Round_fill(get(Weather_curr_press_flight_level) + get(Cabin_delta_psi), 2)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]/2+25, int_psi, 13, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]/2+5, Round_fill(get(Cabin_delta_psi), 2), 13, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]/2-15, math.floor(get(Cabin_alt_ft)), 13, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]/2-35, math.floor(get(Cabin_vs)), 13, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    -- Packs
    sasl.gl.drawWideLine ( 170, size[2]/2+30, 100, size[2]/2+30, 1 , ECAM_WHITE)
    sasl.gl.drawWideLine ( 170, size[2]/2-30, 100, size[2]/2-30, 1 , ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 30, size[2]/2+35, "Pack 1", 14, false, false, TEXT_ALIGN_LEFT, get(Pack_L) == 0 and ECAM_ORANGE or ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 30, size[2]/2-25, "Pack 2", 14, false, false, TEXT_ALIGN_LEFT, get(Pack_L) == 0 and ECAM_ORANGE or ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 0, size[2]/2+20, "Airmass:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 0, size[2]/2-40, "Airmass:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 90, size[2]/2+20, Round_fill(get(L_pack_Flow_value),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 90, size[2]/2-40, Round_fill(get(R_pack_Flow_value),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, 0, size[2]/2+5, "Temp:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 0, size[2]/2-55, "Temp:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 90, size[2]/2+5, Round_fill(get(L_pack_temp),1), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 90, size[2]/2-55, Round_fill(get(R_pack_temp),1), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)


    if get(Pack_L) == 1 then
        sasl.gl.drawWideLine ( 160, size[2]/2+20, 170, size[2]/2+30, 2 , ECAM_GREEN)
        sasl.gl.drawWideLine ( 160, size[2]/2+40, 170, size[2]/2+30, 2 , ECAM_GREEN)
    end
    
    if get(Pack_R) == 1 then
        sasl.gl.drawWideLine ( 160, size[2]/2-20, 170, size[2]/2-30, 2 , ECAM_GREEN)
        sasl.gl.drawWideLine ( 160, size[2]/2-40, 170, size[2]/2-30, 2 , ECAM_GREEN)
    end
    
    -- Safety valve
    sasl.gl.drawWideLine ( 300, size[2]/2-45, 300, size[2]/2-80, 2 , ECAM_WHITE)
    if get(Press_safety_valve_pos) == 1 then
        sasl.gl.drawWideLine ( 310, size[2]/2-70, 300, size[2]/2-80, 2 , ECAM_RED)
        sasl.gl.drawWideLine ( 290, size[2]/2-70, 300, size[2]/2-80, 2 , ECAM_RED)
    end
    sasl.gl.drawText(Font_AirbusDUL, 310, size[2]/2-90, "Safety valve", 14, false, false, TEXT_ALIGN_LEFT, get(Press_safety_valve_pos) == 1 and ECAM_RED or ECAM_WHITE)

    -- Controllers
    sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-15, "Cabin V/S controller", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    Sasl_DrawWideFrame(10, size[2]-85, 200, 65, 1, 1, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-40, "Set-point:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-60, "Des.Output:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-80, "ACTIVE?", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 150, size[2]-40, math.floor(get(Press_controller_sp_vs)), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 150, size[2]-60, math.floor(get(Press_controller_output_vs)), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)

    if get(TIME) - get(Press_controller_last_vs) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, 150, size[2]-80, "YES", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 150, size[2]-80, "NO", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_RED)
    end

    sasl.gl.drawText(Font_AirbusDUL, 260, size[2]-15, "Outflow valve controller", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    
    Sasl_DrawWideFrame(260, size[2]-85, 200, 65, 1, 1, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 270, size[2]-40, "Set-point:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 270, size[2]-60, "Des.Output:", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 270, size[2]-80, "ACTIVE?", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, 400, size[2]-40, Round_fill(get(Press_controller_sp_ovf),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 400, size[2]-60, Round_fill(get(Press_controller_output_ovf),2), 12, false, false, TEXT_ALIGN_RIGHT, UI_LIGHT_BLUE)
 
    if get(TIME) - get(Press_controller_last_ovf) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, 400, size[2]-80, "YES", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 400, size[2]-80, "NO", 12, false, false, TEXT_ALIGN_RIGHT, ECAM_RED)
    end
 
end
