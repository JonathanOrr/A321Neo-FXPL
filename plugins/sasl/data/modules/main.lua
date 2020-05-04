include("helpers.lua")
include("global_datarefs_functions.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)



size = { 4096, 2048 }

panelWidth3d = 4096
panelHeight3d = 2048



components = {
  --power_system {},
  --electrical_system {},
  --flight_deck {},
  engine_and_apu {},
  cabin_screens {},
  flight_controls {},
  fcu_ap_at {}
 }
