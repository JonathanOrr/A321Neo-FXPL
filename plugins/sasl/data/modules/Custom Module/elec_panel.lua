-- READ
local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on")
local dc_bat_bus_on = globalPropertyi("a321neo/electrical/dc_bat_bus_on")


-- WRITE
-- BITS: 1 bit for bottom part of the button, 2 bit is the upper part of the bottom
local ext_pwr_button = globalProperty("a321neo/electrical/ext_pwr_button")
local bat1_button = globalProperty("a321neo/electrical/bat1_button")
local bat2_button = globalProperty("a321neo/electrical/bat2_button")
local bat1_on = globalPropertyi("a321neo/electrical/bat1_on")
local bat2_on = globalPropertyi("a321neo/electrical/bat2_on")


-- CMD
local command_ext_pwr_button_push = createCommand("a321neo/electrical/ext_pwr_button_push", "Push EXT PWR")
local command_bat1_button_push = createCommand("a321neo/electrical/bat1_button_push", "Push BAT1")
local command_bat2_button_push = createCommand("a321neo/electrical/bat2_button_push", "Push BAT2")


function on_command_ext_pwr_button_push (phase)
  if phase == SASL_COMMAND_BEGIN then set(ext_pwr_button, flipBitValue(get(ext_pwr_button), 1)) end
end

function on_command_bat1_button_push (phase)
  if phase == SASL_COMMAND_BEGIN then
    datarefFlip(bat1_on)
    set(bat1_button, setBitValue(get(bat1_button), 3, get(bat1_on)))
  end
end

function on_command_bat2_button_push (phase)
  if phase == SASL_COMMAND_BEGIN then
    datarefFlip(bat2_on)
    set(bat2_button, setBitValue(get(bat1_button), 3, get(bat2_on)))
  end
end


function update()
  set(ext_pwr_button, setBitValue(get(ext_pwr_button), 2, get(ext_pwr_on)))
  set(bat1_button, setBitValue(get(bat1_button), 1, get(dc_bat_bus_on)))
  set(bat2_button, setBitValue(get(bat2_button), 1, get(dc_bat_bus_on)))
end

sasl.registerCommandHandler(command_ext_pwr_button_push, 0, on_command_ext_pwr_button_push)
sasl.registerCommandHandler(command_bat1_button_push, 0, on_command_bat1_button_push)
sasl.registerCommandHandler(command_bat2_button_push, 0, on_command_bat2_button_push)
