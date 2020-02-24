local bit = require("bit")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)

size = { 2048, 2048 }

panelWidth3d = 2048
panelHeight3d = 2048




components = {
  electrical_system {},
  flight_deck {},
 }
