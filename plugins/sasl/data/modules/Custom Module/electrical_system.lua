
local ext_pwr_button = globalProperty("a321neo/electrical/ext_pwr_button")

local ext_pwr_on = createGlobalPropertyi("a321neo/electrical/ext_pwr_on", 0, false, true, false)
local apu_gen_on = createGlobalPropertyi("a321neo/electrical/apu_gen_on", 0, false, true, true)
local gen1_on = createGlobalPropertyi("a321neo/electrical/gen1_on", 0, false, true, true)
local gen2_on = createGlobalPropertyi("a321neo/electrical/gen2_on", 0, false, true, true)
local emer_gen_on = createGlobalPropertyi("a321neo/electrical/emer_gen_on", 0, false, true, true)

local ac_bus1_on = createGlobalPropertyi("a321neo/electrical/ac_bus1_on", 0, false, true, true)
local ac_bus2_on = createGlobalPropertyi("a321neo/electrical/ac_bus2_on", 0, false, true, true)
local ac_ess_bus_on = createGlobalPropertyi("a321neo/electrical/ac_ess_bus_on", 0, false, true, true)

local dc_bus1_on = createGlobalPropertyi("a321neo/electrical/dc_bus1_on", 0, false, true, true)
local dc_bus2_on = createGlobalPropertyi("a321neo/electrical/dc_bus2_on", 0, false, true, true)
local dc_bus_ent = createGlobalPropertyi("a321neo/electrical/dc_bus_ent_on", 0, false, true, true)
local dc_bat_bus_on = createGlobalPropertyi("a321neo/electrical/dc_bat_bus_on", 0, false, true, true)
local dc_ess_bus_on = createGlobalPropertyi("a321neo/electrical/dc_ess_bus_on", 0, false, true, true)

local bat1_on = createGlobalPropertyi("a321neo/electrical/bat1_on", 0, false, true, true)
local bat2_on = createGlobalPropertyi("a321neo/electrical/bat2_on", 0, false, true, true)


function update()

  if datarefIsOn(ext_pwr_on) and datarefIsOnBit(ext_pwr_button, 1)
  then
    datarefSetOn(ac_bus1_on)
    datarefSetOn(ac_bus2_on)
  end
  --

  if datarefIsOn(ac_bus1_on)
  then
    datarefSetOn(ac_ess_bus_on)
    datarefSetOn(dc_bus1_on)
  end


  if datarefIsOn(dc_bus1_on)
  then
    datarefSetOn(dc_bat_bus_on)
  end


  if datarefIsOn(dc_bat_bus_on)
  then
    datarefSetOn(dc_ess_bus_on)
  end


  if datarefIsOn(emer_gen_on)
  then
    datarefSetOn(dc_ess_bus_on)
    datarefSetOn(acc_ess_bus_on)
  end

end
