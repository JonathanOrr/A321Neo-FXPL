-- READ
local ext_pwr_source_on = globalProperty("a321neo/electrical/ext_pwr_source_on")
local dc_bat_bus_on = globalPropertyi("a321neo/electrical/dc_bat_bus_on")


-- WRITE
-- BITS: 1 bit for bottom part of the button, 2 bit is the upper part of the bottom
local ext_pwr_button = createGlobalPropertyi("a321neo/electrical/ext_pwr_button", 0, false, true, true)
local ext_pwr_button_state = globalPropertyi("a321neo/electrical/ext_pwr_button_state")

local bat1_button = createGlobalPropertyi("a321neo/electrical/bat1_button", 0, false, true, true)
local bat1_button_state = globalPropertyi("a321neo/electrical/bat1_button_state")

local bat2_button = createGlobalPropertyi("a321neo/electrical/bat2_button", 0, false, true, true)
local bat2_button_state = globalPropertyi("a321neo/electrical/bat2_button_state")

local apu_gen_button = createGlobalPropertyi("a321neo/electrical/apu_gen_button", 0, false, true, true)
local apu_gen_button_state = globalPropertyi("a321neo/electrical/apu_gen_button_state")
local gen1_button = createGlobalPropertyi("a321neo/electrical/gen1_button", 0, false, true, true)
local gen1_button_state = globalPropertyi("a321neo/electrical/gen1_button_state")
local gen2_button = createGlobalPropertyi("a321neo/electrical/gen2_button", 0, false, true, true)
local gen2_button_state = globalPropertyi("a321neo/electrical/gen2_button_state")


local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on")
local bat1_on = globalPropertyi("a321neo/electrical/bat1_on")
local bat2_on = globalPropertyi("a321neo/electrical/bat2_on")
local gen1_on = globalPropertyi("a321neo/electrical/gen1_on")
local gen2_on = globalPropertyi("a321neo/electrical/gen2_on")
local apu_gen_on = globalPropertyi("a321neo/electrical/apu_gen_on")

-- CMD
local command_ext_pwr_button_push = createCommand("a321neo/electrical/ext_pwr_button_push", "Push EXT PWR")
local command_bat1_button_push = createCommand("a321neo/electrical/bat1_button_push", "Push BAT 1")
local command_bat2_button_push = createCommand("a321neo/electrical/bat2_button_push", "Push BAT 2")

local command_apu_gen_button_push = createCommand("a321neo/electrical/apu_gen_button_push", "Push APU GEN")
local command_gen1_button_push = createCommand("a321neo/electrical/gen1_button_push", "Push GEN 1")
local command_gen2_button_push = createCommand("a321neo/electrical/bat2_button_push", "Push GEN 2")


function update()
  datarefSetValue(ext_pwr_button, 0)
  datarefSetValue(bat1_button, 0)
  datarefSetValue(bat2_button, 0)

  if datarefIsOn(ext_pwr_on) and datarefIsOn(ext_pwr_source_on)
  then
    datarefSetBitValue(ext_pwr_button, CONST.UPPER_BIT, 0)
    datarefSetBitValue(ext_pwr_button, CONST.BOTTOM_BIT, 1)
  elseif datarefIsOn(ext_pwr_source_on)
  then
    datarefSetBitValue(ext_pwr_button, CONST.UPPER_BIT, 1) -- avail light
  end

  if datarefIsOff(bat1_on)
  then
    datarefSetBitValue(bat1_button, CONST.BOTTOM_BIT, get(dc_bat_bus_on)) -- off light
  end

  if datarefIsOff(bat2_on)
  then
    datarefSetBitValue(bat2_button, CONST.BOTTOM_BIT, get(dc_bat_bus_on)) -- off light
  end

  if datarefIsOn(dc_bat_bus_on) and datarefIsOff(gen1_on)
  then
      datarefSetBitValue(gen1_button, CONST.UPPER_BIT, 1) -- fault light
  end

  if datarefIsOn(dc_bat_bus_on) and datarefIsOff(gen1_on)
  then
      datarefSetBitValue(gen2_button, CONST.UPPER_BIT, 1) -- fault light
  end


end

sasl.registerCommandHandler(command_ext_pwr_button_push, 0, function(phase)
 if phase == SASL_COMMAND_BEGIN then datarefFlip(ext_pwr_button_state) end
end)

sasl.registerCommandHandler(command_apu_gen_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(apu_gen_button_state) end
end)

sasl.registerCommandHandler(command_bat1_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat1_button_state) end
end)

sasl.registerCommandHandler(command_bat2_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat2_button_state) end
end)

sasl.registerCommandHandler(command_gen1_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(gen1_button_state) end
end)

sasl.registerCommandHandler(command_gen2_button_push, 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(gen2_button_state) end
end)
