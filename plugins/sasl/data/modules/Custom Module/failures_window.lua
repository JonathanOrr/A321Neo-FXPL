size = {800, 600}

include('constants.lua')

-- Constants
local X_START_MENU_RECT = 165
local X_START_MENU_TEXT = 215
local Y_START_MENU_RECT = size[2]-90
local Y_START_MENU_TEXT = size[2]-80
local X_SIZE_MENU_RECT = 100
local Y_SIZE_MENU_RECT = 32
local X_SPACING_MENU = 105
local Y_SPACING_MENU = 35
local MENU_TOT_LINES = 2

local Y_START_FAIL_RECT = size[2]-190
local Y_START_FAIL_TEXT = size[2]-180


local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local master_caution_image = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/master_caution.png", 0, 0, 128, 128)
local master_warning_image = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/master_warning.png", 0, 0, 128, 128)

-- Variables
local group_selected = 0
local fail_tot_lines = 0

-- Global structures
local failures_data = {
    { 
        group="ADIRS",
        failures={
            {name="ADR1", status=false, dataref=FAILURE_ADR[1] },
            {name="ADR2", status=false, dataref=FAILURE_ADR[2] },
            {name="ADR3", status=false, dataref=FAILURE_ADR[3] },
            {name="IR1",  status=false, dataref=FAILURE_IR[1] },
            {name="IR2",  status=false, dataref=FAILURE_IR[2] },
            {name="IR3",  status=false, dataref=FAILURE_IR[3] }
        }
    },
    {
        group="ANTI-ICE",
        failures={
        }
    },
    {
        group="AUTOPILOT",
        failures={
        }
    },
    {
        group="ELECTRICAL",
        failures={
            {name="BAT 1\nFAILURE", status=false, dataref=FAILURE_ELEC_battery_1 },
            {name="BAT 2\nFAILURE", status=false, dataref=FAILURE_ELEC_battery_2 },
            {name="GEN 1\nFAILURE", status=false, dataref=FAILURE_ELEC_GEN_1 },
            {name="GEN 2\nFAILURE", status=false, dataref=FAILURE_ELEC_GEN_2 },
            {name="APU GEN\nFAILURE", status=false, dataref=FAILURE_ELEC_GEN_APU },
            {name="RAT GEN\nFAILURE", status=false, dataref=FAILURE_ELEC_GEN_EMER },
            {name="EXT PWR\nFAILURE", status=false, dataref=FAILURE_ELEC_GEN_EXT },
            {name="STATIC INV.\nFAILURE", status=false, dataref=FAILURE_ELEC_STATIC_INV },
            {name="TR 1\nFAILURE", status=false, dataref=FAILURE_ELEC_TR_1 },
            {name="TR 2\nFAILURE", status=false, dataref=FAILURE_ELEC_TR_2 },
            {name="TR ESS\nFAILURE", status=false, dataref=FAILURE_ELEC_TR_ESS },
            {name="IDG 1\nOVERHEAT", status=false, dataref=FAILURE_ELEC_IDG1_temp },
            {name="IDG 1\nLOW OIL", status=false, dataref=FAILURE_ELEC_IDG1_oil },
            {name="IDG 2\nOVERHEAT", status=false, dataref=FAILURE_ELEC_IDG2_temp },
            {name="IDG 2\nLOW OIL", status=false, dataref=FAILURE_ELEC_IDG2_oil },
            {name="GALLEY\nFAILURE", status=false, dataref=FAILURE_ELEC_GALLEY },
            {name="AC 1 BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_AC1_bus },
            {name="AC 2 BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_AC2_bus },
            {name="AC ESS BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_AC_ESS_bus },
            {name="AC ESS BUS\nSHED", status=false, dataref=FAILURE_ELEC_AC_ESS_SHED_bus },
            {name="DC 1 BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_DC1_bus },
            {name="DC 2 BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_DC2_bus },
            {name="DC ESS BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_DC_ESS_bus },
            {name="DC ESS BUS\nSHED", status=false, dataref=FAILURE_ELEC_DC_ESS_SHED_bus },
            {name="DC BAT BUS\nFAILURE", status=false, dataref=FAILURE_ELEC_DC_BAT_bus }
        }
    },
    {
        group="F/CTL",
        failures={
            {name="SFCC 1\nFAILURE", status=false, dataref=FAILURE_FCTL_SFCC_1 },
            {name="SFCC 2\nFAILURE", status=false, dataref=FAILURE_FCTL_SFCC_2 },
            {name="L AILERON\nSTUCK", status=false, dataref=FAILURE_FCTL_LAIL },
            {name="R AILERON\nSTUCK", status=false, dataref=FAILURE_FCTL_RAIL },
        }
    },
    {
        group="ENGINES",
        failures={
        }
    },
    {
        group="FUEL",
        failures={
            {name="X FEED VALVE\nSTUCK", status=false, dataref=FAILURE_FUEL_X_FEED },
            {name="FUEL PUMP\nL1 FAILURE", status=false, dataref=FAILURE_FUEL, nr=1},
            {name="FUEL PUMP\nL2 FAILURE", status=false, dataref=FAILURE_FUEL, nr=2},
            {name="FUEL PUMP\nR1 FAILURE", status=false, dataref=FAILURE_FUEL, nr=3},
            {name="FUEL PUMP\nR2 FAILURE", status=false, dataref=FAILURE_FUEL, nr=4},
            {name="FUEL XFR\nC1 FAILURE", status=false, dataref=FAILURE_FUEL, nr=5},
            {name="FUEL XFR\nC2 FAILURE", status=false, dataref=FAILURE_FUEL, nr=6},
            {name="FUEL XFR ACT\nFAILURE", status=false, dataref=FAILURE_FUEL, nr=7},
            {name="FUEL XFR RCT\nFFAILURE", status=false, dataref=FAILURE_FUEL, nr=8},
            {name="APU VALVE\nSTUCK", status=false, dataref=FAILURE_FUEL_APU_VALVE_STUCK},
            {name="APU PUMP\nFAILURE", status=false, dataref=FAILURE_FUEL_APU_PUMP_FAIL},
            {name="ENG 1 FW\nVALVE STUCK", status=false, dataref=FAILURE_FUEL_ENG1_VALVE_STUCK},
            {name="ENG 2 FW\nVALVE STUCK", status=false, dataref=FAILURE_FUEL_ENG2_VALVE_STUCK},
            
        }
    },
    {
        group="HYD",
        failures={
            {name="G SYSTEM\nLEAK", status=false, dataref=FAILURE_HYD_G_leak },
            {name="B SYSTEM\nLEAK", status=false, dataref=FAILURE_HYD_B_leak },
            {name="Y SYSTEM\nLEAK", status=false, dataref=FAILURE_HYD_Y_leak },
            {name="ENG 1 PUMP\n(G) FAILURE", status=false, dataref=FAILURE_HYD_G_pump },
            {name="ENG 2 PUMP\n(Y) FAILURE", status=false, dataref=FAILURE_HYD_Y_pump },
            {name="ELEC B PUMP\nFAILURE", status=false, dataref=FAILURE_HYD_B_pump },
            {name="ELEC Y PUMP\nFAILURE", status=false, dataref=FAILURE_HYD_Y_E_pump },
            {name="RAT\nFAILURE", status=false, dataref=FAILURE_HYD_RAT },
            {name="PTU\nFAILURE", status=false, dataref=FAILURE_HYD_PTU },

            {name="ELEC PUMP B\nOVHT", status=false, dataref=FAILURE_HYD_B_E_overheat },
            {name="ELEC PUMP Y\nOVHT", status=false, dataref=FAILURE_HYD_Y_E_overheat },
            {name="RESERVOIR G\nOVHT", status=false, dataref=FAILURE_HYD_G_R_overheat },
            {name="RESERVOIR B\nOVHT", status=false, dataref=FAILURE_HYD_B_R_overheat },
            {name="RESERVOIR Y\nOVHT", status=false, dataref=FAILURE_HYD_Y_R_overheat },
            {name="RESERVOIR G\nLOW AIR", status=false, dataref=FAILURE_HYD_G_low_air },
            {name="RESERVOIR B\nLOW AIR", status=false, dataref=FAILURE_HYD_B_low_air },
            {name="RESERVOIR Y\nLOW AIR", status=false, dataref=FAILURE_HYD_Y_low_air },
  }
    },


    {
        group="L/G",
        failures={
        }
    },
    {
        group="MISC",
        failures={
        }
    },
    {
        group="PACKS",
        failures={
        }
    },
    {
        group="RADIOS",
        failures={
        }
    }
}


-- Functions
function update()
    if failures_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideFailures, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideFailures, MENU_UNCHECKED)
    end

end

local function draw_warning_caution()
    if get(MasterCaution) == 1 then
        sasl.gl.drawTexture(master_caution_image, 10, size[2]-110, 64, 64)
    else
        sasl.gl.drawRectangle (10, size[2]-110, 64, 64, {0,0,0})    
    end

    if get(MasterWarningBlinking) == 1 then
        sasl.gl.drawTexture(master_warning_image, 80, size[2]-110, 64, 64)
    else
        sasl.gl.drawRectangle (80, size[2]-110, 64, 64, {0,0,0})
    end

end

local function create_button(text, offset_x, offset_y)
    local rect_x = X_START_MENU_RECT+offset_x*X_SPACING_MENU
    local rect_y = Y_START_MENU_RECT-offset_y*Y_SPACING_MENU
    local text_x = X_START_MENU_TEXT+offset_x*X_SPACING_MENU
    local text_y = Y_START_MENU_TEXT-offset_y*Y_SPACING_MENU

    sasl.gl.drawRectangle (rect_x, rect_y, X_SIZE_MENU_RECT, Y_SIZE_MENU_RECT, UI_LIGHT_GREY)

    if group_selected > 0 and failures_data[group_selected].group == text then 
        sasl.gl.drawText(B612MONO_regular, text_x, text_y, text, 14, false, false, TEXT_ALIGN_CENTER, UI_LIGHT_BLUE)
    else
        sasl.gl.drawText(B612MONO_regular, text_x, text_y, text, 14, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    end
end

local function create_failure_button(failure, offset_x, offset_y)

    local rect_x = X_START_MENU_RECT+offset_x*X_SPACING_MENU
    local rect_y = Y_START_FAIL_RECT-offset_y*Y_SPACING_MENU
    local text_x = X_START_MENU_TEXT+offset_x*X_SPACING_MENU
    local text_y = Y_START_FAIL_TEXT-offset_y*Y_SPACING_MENU+10

    sasl.gl.drawRectangle (rect_x, rect_y, X_SIZE_MENU_RECT, Y_SIZE_MENU_RECT, UI_LIGHT_GREY)
    sasl.gl.drawFrame (rect_x, rect_y, X_SIZE_MENU_RECT, Y_SIZE_MENU_RECT, failure.status and ECAM_RED or UI_LIGHT_BLUE)
    sasl.gl.drawText(B612MONO_regular, text_x, text_y, failure.name, 12, false, false, TEXT_ALIGN_CENTER, failure.status and ECAM_RED or UI_WHITE)

end

function draw_active_failures()

    pos = size[2]-150

    for i, x in ipairs(failures_data) do
        for j, M in ipairs(x.failures) do
            if M.status then
                sasl.gl.drawText(B612MONO_regular, 10, pos, M.name:gsub("%\n", " "):sub(1,17), 12, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
                pos = pos - 20
            end
        end
    end
end

function draw()

    --draw background
    sasl.gl.drawRectangle(0, 0, size[1], size[2], UI_LIGHT_GREY)
    sasl.gl.drawRectangle(5, 5, size[1]-10, size[2]-10, UI_DARK_GREY)
    -- Fixed elements
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-40, "Failures Manager", 30, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawLine(160,10,160,550, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-130, "Active Failures", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 340, size[2]-20, "DO NOT USE X-PLANE FAILURES MENU! It doesn't work with\nthis airplane and strange things may happen. Please use\nONLY this menu to simulate random or intentional failures.", 12, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)

    draw_warning_caution()

    -- Menu
    for i, x in ipairs(failures_data) do
        create_button(x.group, (i-1)%6, math.floor((i-1)/6))
    end

    -- Failure buttons
    if group_selected == 0 then
        return
    end

    fail_tot_lines = 0
    for i, x in ipairs(failures_data[group_selected].failures) do
        create_failure_button(x, (i-1)%6, math.floor((i-1)/6))
        fail_tot_lines = fail_tot_lines + 1
    end
    fail_tot_lines = math.floor(fail_tot_lines/6) + 1

    draw_active_failures()

end

local function mouse_handler_menu(x, y)
    local i = math.floor((x - X_START_MENU_RECT) / ( X_SPACING_MENU ))   -- Nr. of column of the button
    local j = math.floor((Y_START_MENU_RECT + Y_SIZE_MENU_RECT - y) / (  Y_SPACING_MENU ))   -- Nr. of row of the button
    
    group_selected = i + 1 + j*6    
end

local function mouse_handler_fail(x, y)
    local i = math.floor((x - X_START_MENU_RECT) / ( X_SPACING_MENU ))   -- Nr. of column of the button
    local j = math.floor((Y_START_FAIL_RECT + Y_SIZE_MENU_RECT - y) / (  Y_SPACING_MENU ))   -- Nr. of row of the button
    
    local clicked_fail = failures_data[group_selected].failures[i + 1 + j*6]
    
    if clicked_fail ~= nil then
        clicked_fail.status = not clicked_fail.status
        if clicked_fail.status then
            if clicked_fail.nr == nil then
                set(clicked_fail.dataref, 1)
            else
                set(clicked_fail.dataref, 1, clicked_fail.nr)
            end            
        else
            if clicked_fail.nr == nil then
                set(clicked_fail.dataref, 0)
            else
                set(clicked_fail.dataref, 0, clicked_fail.nr)
            end            
        end
    end
    
end

function onMouseDown (component , x , y , button , parentX , parentY)

    if x >= X_START_MENU_RECT and y <= Y_START_MENU_RECT+Y_SIZE_MENU_RECT and y >= Y_START_MENU_RECT-(MENU_TOT_LINES-1)*Y_SPACING_MENU then
        mouse_handler_menu(x, y)
    end
    
    if x >= X_START_MENU_RECT and y <= Y_START_FAIL_RECT+Y_SIZE_MENU_RECT and y >= Y_START_FAIL_RECT-(fail_tot_lines-1)*Y_SPACING_MENU then
        mouse_handler_fail(x, y)
    end
    
    return true
end
