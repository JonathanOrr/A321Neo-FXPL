-- READ
local ext_pwr_source_on = globalProperty("a321neo/electrical/ext_pwr_source_on")
local dc_bat_bus_on = globalPropertyi("a321neo/electrical/dc_bat_bus_on")


-- WRITE
-- BITS: 1 bit for bottom part of the button, 2 bit is the upper part of the bottom
local ext_pwr_button = createGlobalPropertyi("a321neo/electrical/ext_pwr_button", 0, false, true, true)
local bat1_button = createGlobalPropertyi("a321neo/electrical/bat1_button", 0, false, true, true)
local bat2_button = createGlobalPropertyi("a321neo/electrical/bat2_button", 0, false, true, true)
local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on")
local bat1_on = globalPropertyi("a321neo/electrical/bat1_on")
local bat2_on = globalPropertyi("a321neo/electrical/bat2_on")

-- CMD
local command_ext_pwr_button_push = createCommand("a321neo/electrical/ext_pwr_button_push", "Push EXT PWR")
local command_bat1_button_push = createCommand("a321neo/electrical/bat1_button_push", "Push BAT1")
local command_bat2_button_push = createCommand("a321neo/electrical/bat2_button_push", "Push BAT2")

function update()
  datarefSetValue(ext_pwr_button, 0)
  datarefSetValue(bat1_button, 0)
  datarefSetValue(bat2_button, 0)

  if datarefIsOn(ext_pwr_on)
  then
    if datarefIsOn(ext_pwr_source_on)
    then
      set(ext_pwr_button, setBitValue(get(ext_pwr_button), 2, 0))
      set(ext_pwr_button, setBitValue(get(ext_pwr_button), 1, 1))
    end
  elseif datarefIsOn(ext_pwr_source_on)
  then
    set(ext_pwr_button, setBitValue(get(ext_pwr_button), 2, 1))
  end

  if datarefIsOff(bat1_on)
  then
    set(bat1_button, setBitValue(get(bat1_button), 1, get(dc_bat_bus_on)))
  end

  if datarefIsOff(bat2_on)
  then
    set(bat2_button, setBitValue(get(bat2_button), 1, get(dc_bat_bus_on)))
  end

end

sasl.registerCommandHandler(command_ext_pwr_button_push, 0, function(phase)
 if phase == SASL_COMMAND_BEGIN then datarefFlip(ext_pwr_on) end
end)

sasl.registerCommandHandler(command_bat1_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat1_on) end
end)

sasl.registerCommandHandler(command_bat2_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat2_on) end
end)
