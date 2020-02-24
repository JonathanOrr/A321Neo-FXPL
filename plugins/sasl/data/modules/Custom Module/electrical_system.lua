
local ext_pwr_button = createGlobalPropertyi("a321neo/electrical/ext_pwr_button", 0, false, true, true)

local bat1_button = createGlobalPropertyi("a321neo/electrical/bat1_button", 0, false, true, true)
local bat2_button = createGlobalPropertyi("a321neo/electrical/bat2_button", 0, false, true, true)

local ext_pwr_on = createGlobalPropertyi("a321neo/electrical/ext_pwr_on", 0, false, true, false)
local apu_gen_on = createGlobalPropertyi("a321neo/electrical/apu_gen_on", 0, false, true, true)
local gen1_on = createGlobalPropertyi("a321neo/electrical/gen1_on", 0, false, true, true)
local gen2_on = createGlobalPropertyi("a321neo/electrical/gen2_on", 0, false, true, true)
local emer_gen_on = createGlobalPropertyi("a321neo/electrical/emer_gen_on", 0, false, true, true)

local ac_bus1_on = createGlobalPropertyi("a321neo/electrical/ac_bus1_on", 0, false, true, true)
local ac_bus2_on = createGlobalPropertyi("a321neo/electrical/ac_bus2_on", 0, false, true, true)
local ac_ess_bus_on = createGlobalPropertyi("a321neo/electrical/ac_ess_bus_on", 0, false, true, true)

-- trs not used yet
local tr1_on = createGlobalPropertyi("a321neo/electrical/tr1_on", 0, false, true, true)
local tr2_on = createGlobalPropertyi("a321neo/electrical/tr2_on", 0, false, true, true)
local tr_ess_on = createGlobalPropertyi("a321neo/electrical/tr_ess_on", 0, false, true, true)
local tr_ent_on = createGlobalPropertyi("a321neo/electrical/tr_ent_on", 0, false, true, true)

local dc_bus1_on = createGlobalPropertyi("a321neo/electrical/dc_bus1_on", 0, false, true, true)
local dc_bus2_on = createGlobalPropertyi("a321neo/electrical/dc_bus2_on", 0, false, true, true)
local dc_bus_ent = createGlobalPropertyi("a321neo/electrical/dc_bus_ent_on", 0, false, true, true)
local dc_bat_bus_on = createGlobalPropertyi("a321neo/electrical/dc_bat_bus_on", 0, false, true, true)
local dc_ess_bus_on = createGlobalPropertyi("a321neo/electrical/dc_ess_bus_on", 0, false, true, true)

local bat1_on = createGlobalPropertyi("a321neo/electrical/bat1_on", 0, false, true, true)
local bat2_on = createGlobalPropertyi("a321neo/electrical/bat2_on", 0, false, true, true)

-- MISC
local indicated_airspeed = globalProperty("sim/flightmodel/position/indicated_airspeed")
local wheel_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")


function exp_pwr_on_and_pb_on()
  return (datarefIsOn(ext_pwr_on) and datarefIsOnBit(ext_pwr_button, 1))
end

--test
local ac1_fault = false
local ac2_fault = false


function update()

  -- Turn off ac_bus1_on and ac_bus2_on if no power
  -- if exp_pwr_on_and_pb_on() == false and datarefIsOff(gen1_on) and datarefIsOff(gen2_on) and datarefIsOff(apu_gen_on)
  -- then
  datarefSetOff(ac_bus1_on)
  datarefSetOff(ac_bus2_on)
  datarefSetOff(ac_ess_bus_on)
  datarefSetOff(dc_bus1_on)
  datarefSetOff(dc_bus2_on)
  datarefSetOff(dc_bus_ent)
  datarefSetOff(dc_bat_bus_on)
  datarefSetOff(dc_ess_bus_on)
  -- end

  -- all gens are interchangable
  if exp_pwr_on_and_pb_on() or datarefIsOn(gen1_on) or  datarefIsOn(gen2_on) or datarefIsOn(apu_gen_on)
  then
    if ac1_fault == false then datarefSetOn(ac_bus1_on) end
    if ac2_fault == false then datarefSetOn(ac_bus2_on) end
  end

  if datarefIsOn(ac_bus1_on)
  then
    datarefSetOn(ac_ess_bus_on)
    datarefSetOn(dc_bus1_on)
  end

  if datarefIsOn(ac_bus2_on)
  then
    datarefSetOn(dc_bus2_on)
    -- power dc_bus_ent if enough power
    if (datarefIsOn(gen1_on) and datarefIsOn(gen2_on)) or exp_pwr_on_and_pb_on() or datarefIsOn(apu_gen_on) then datarefSetOn(dc_bus_ent) end
  end

  -- AC ESS FEED Auto Switching
  if datarefIsOn(ac_bus2_on) and datarefIsOff(ac_bus1_on)
  then
    datarefSetOn(ac_ess_bus_on)
  end

  if datarefIsOn(ac_ess_bus_on) and datarefIsOff(ac_bus1_on)
  then
    datarefSetOn(dc_ess_bus_on)
  end

  if datarefIsOn(dc_bus1_on)
  then
    datarefSetOn(dc_bat_bus_on)
    datarefSetOn(dc_ess_bus_on)
  end

  -- TODO: add delay
  -- DC BUS 2 supplies DC BUS 1 and DC BAT BUS automatically after 5s.
  if datarefIsOn(dc_bus2_on) and datarefIsOff(dc_bus1_on)
  then
    datarefSetOn(dc_bus1_on)
    datarefSetOn(dc_bat_bus_on)
  end


  if datarefIsOn(bat1_on) and (datarefIsOff(dc_bus1_on) and datarefIsOff(dc_bus2_on))
  then
      datarefSetOn(ac_ess_bus_on)
      datarefSetOn(dc_ess_bus_on)
      datarefSetOff(dc_bat_bus_on)
      if get(indicated_airspeed) < 100.0 then datarefSetOn(dc_bat_bus_on) end
      if get(indicated_airspeed) < 50.0 then datarefSetOff(ac_ess_bus_on) end
  end

  if datarefIsOn(bat2_on) and (datarefIsOff(dc_bus1_on) and datarefIsOff(dc_bus2_on))
  then
    datarefSetOn(ac_ess_bus_on)
    datarefSetOn(dc_ess_bus_on)
    datarefSetOff(dc_bat_bus_on)
    if get(indicated_airspeed) < 100.0 then datarefSetOn(dc_bat_bus_on) end
    if get(indicated_airspeed) < 50.0 then datarefSetOff(ac_ess_bus_on) end
  end

  -- if datarefIsOn(dc_bat_bus_on)
  -- then
  -- end

  -- handle if ac_bus1 and ac_bus2 lost in flight using RAT
  if datarefIsOff(ac_bus1_on) and datarefIsOff(ac_bus2_on) and (get(indicated_airspeed) > 100.0 or datarefIsOff(wheel_on_ground) )
  then
    datarefSetOn(emer_gen_on)
  else
    datarefSetOff(emer_gen_on)
  end

  -- emer_gen_on powers only ess buss
  if datarefIsOn(emer_gen_on)
  then
    datarefSetOn(ac_ess_bus_on)
    datarefSetOn(dc_ess_bus_on)
  end

end
