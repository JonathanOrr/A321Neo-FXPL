-- READ
local ext_pwr_source_on = globalProperty("a321neo/electrical/ext_pwr_source_on")
local dc_bat_bus_on = globalPropertyi("a321neo/electrical/dc_bat_bus_on")
local dc_ess_bus_on = globalPropertyi("a321neo/electrical/dc_ess_bus_on")
local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on")
local bat1_on = globalPropertyi("a321neo/electrical/bat1_on")
local bat2_on = globalPropertyi("a321neo/electrical/bat2_on")
local gen1_on = globalPropertyi("a321neo/electrical/gen1_on")
local gen2_on = globalPropertyi("a321neo/electrical/gen2_on")
local apu_gen_on = globalPropertyi("a321neo/electrical/apu_gen_on")
local bat1_voltage = globalPropertyf("a321neo/electrical/bat1_voltage")
local bat2_voltage = globalPropertyf("a321neo/electrical/bat2_voltage")

-- WRITE
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

local ac_ess_feed_button = createGlobalPropertyi("a321neo/electrical/ac_ess_feed_button", 0, false, true, true)
local ac_ess_feed_button_state = globalPropertyi("a321neo/electrical/ac_ess_feed_button_state")

local bus_tie_button = createGlobalPropertyi("a321neo/electrical/bus_tie_button", 0, false, true, true)
local bus_tie_button_state = globalPropertyi("a321neo/electrical/bus_tie_button_state")

local gelley_button = createGlobalPropertyi("a321neo/electrical/gelley_button", 0, false, true, true)
local gelley_button_state = globalPropertyi("a321neo/electrical/gelley_button_state")

local commercial_button = createGlobalPropertyi("a321neo/electrical/commercial_button", 0, false, true, true)
local commercial_button_state = globalPropertyi("a321neo/electrical/commercial_button_state")

local idg1_button = createGlobalPropertyi("a321neo/electrical/idg1_button", 0, false, true, true)
local idg1_button_state = globalPropertyi("a321neo/electrical/idg1_button_state")
local idg2_button = createGlobalPropertyi("a321neo/electrical/idg2_button", 0, false, true, true)
local idg2_button_state = globalPropertyi("a321neo/electrical/idg2_button_state")


-- CMD
sasl.registerCommandHandler(createCommand("a321neo/electrical/ext_pwr_button_push", "Push EXT PWR"), 0, function(phase)
 if phase == SASL_COMMAND_BEGIN then datarefFlip(ext_pwr_button_state) end
end)

sasl.registerCommandHandler(createCommand("a321neo/electrical/apu_gen_button_push", "Push APU GEN"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(apu_gen_button_state) end
end)

sasl.registerCommandHandler(createCommand("a321neo/electrical/bat1_button_push", "Push BAT 1"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat1_button_state) end
end)

sasl.registerCommandHandler(createCommand("a321neo/electrical/bat2_button_push", "Push BAT 2"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(bat2_button_state) end
end)

sasl.registerCommandHandler(createCommand("a321neo/electrical/gen1_button_push", "Push GEN 1"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(gen1_button_state) end
end)

sasl.registerCommandHandler(createCommand("a321neo/electrical/gen2_button_push", "Push GEN 2"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefFlip(gen2_button_state) end
end)


-- BITS: 1 bit for bottom part of the button, 2 bit is the upper part of the bottom
function update()
  datarefSetValue(ext_pwr_button, 0)
  datarefSetValue(bat1_button, 0)
  datarefSetValue(bat2_button, 0)
  datarefSetValue(gen1_button, 0)
  datarefSetValue(gen2_button, 0)

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

  if datarefIsOn(dc_ess_bus_on) and datarefIsOff(gen1_on) and datarefIsOn(gen1_button_state)
  then
      datarefSetBitValue(gen1_button, CONST.UPPER_BIT, 1) -- fault light
  end

  if datarefIsOff(gen1_button_state) and datarefIsOn(dc_ess_bus_on)
  then
      datarefSetBitValue(gen1_button, CONST.UPPER_BIT, 0) -- fault light reset
      datarefSetBitValue(gen1_button, CONST.BOTTOM_BIT, 1) -- off light
  end

  if datarefIsOn(dc_ess_bus_on) and datarefIsOff(gen2_on) and datarefIsOn(gen2_button_state)
  then
      datarefSetBitValue(gen2_button, CONST.UPPER_BIT, 1) -- fault light
  end

  if datarefIsOff(gen2_button_state) and datarefIsOn(dc_ess_bus_on)
  then
      datarefSetBitValue(gen2_button, CONST.UPPER_BIT, 0) -- fault light reset
      datarefSetBitValue(gen2_button, CONST.BOTTOM_BIT, 1) -- off light
  end
end
