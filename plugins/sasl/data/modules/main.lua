include("helpers.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)

size = { 4096, 2048 }

panelWidth3d = 4096
panelHeight3d = 2048




components = {
  electrical_system {},
  flight_deck {},
 }
