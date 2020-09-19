size = {800, 600}

include('constants.lua')

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

bus_source_labels = {}
bus_source_labels[0] = "NONE"
bus_source_labels[1] = "GEN 1"
bus_source_labels[2] = "GEN 2"
bus_source_labels[3] = "GEN APU"
bus_source_labels[4] = "GEN EXT"
bus_source_labels[5] = "GEN EMER"
bus_source_labels[11] = "AC BUS 1"
bus_source_labels[12] = "AC BUS 2"
bus_source_labels[21] = "ST.INV"
bus_source_labels[31] = "TR 1"
bus_source_labels[32] = "TR 2"
bus_source_labels[33] = "TR ESS"
bus_source_labels[41] = "BAT 1"
bus_source_labels[42] = "BAT 2"
bus_source_labels[98] = "DC BAT"
bus_source_labels[99] = "BUS TIE"

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local function print_value_dec(x, y, label, value)
    sasl.gl.drawText(B612MONO_regular, x, y, label .. ": " .. round(value,2), 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
end

local function print_bool(x, y, label, value)
    sasl.gl.drawText(B612MONO_regular, x, y, label .. "? ", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    w,h = sasl.gl.measureText(B612MONO_regular, label, 12, false, false)

    if value then
        sasl.gl.drawText(B612MONO_regular, x+w+20, y, "YES", 12, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, x+w+20, y, "NO", 12, false, false, TEXT_ALIGN_LEFT, ECAM_RED)    
    end
end

local function print_bus_source(x1,x2,y,label,val)

    sasl.gl.drawText(B612MONO_regular, x1, y, label,
                        12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, x2, y, bus_source_labels[val],
                        12, false, false, TEXT_ALIGN_LEFT, val > 0 and ECAM_GREEN or ECAM_ORANGE)

end

function draw()

    sasl.gl.drawText(B612MONO_regular, 10, size[2]-30, "ELEC DEBUG", 20, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)


    -- Batteries status
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-70, "Battery 1", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 200, size[2]-70, "Battery 2", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    print_bool(10,  size[2]-90, "Is on", ELEC_sys.batteries[1].switch_status)
    print_bool(200, size[2]-90, "Is on", ELEC_sys.batteries[2].switch_status)

    print_value_dec(10,  size[2]-110, "Voltage (V)", ELEC_sys.batteries[1].curr_voltage)
    print_value_dec(200, size[2]-110, "Voltage (V)", ELEC_sys.batteries[2].curr_voltage)

    print_value_dec(10,  size[2]-130, "Current (A)", ELEC_sys.batteries[1].curr_amps)
    print_value_dec(200, size[2]-130, "Current (A)", ELEC_sys.batteries[2].curr_amps)

    print_value_dec(10,  size[2]-150, "Charge (Ah)", ELEC_sys.batteries[1].curr_charge)
    print_value_dec(200, size[2]-150, "Charge (Ah)", ELEC_sys.batteries[2].curr_charge)

    print_bool(10,  size[2]-170, "Is charging", ELEC_sys.batteries[1].is_charging)
    print_bool(200, size[2]-170, "Is charging", ELEC_sys.batteries[2].is_charging)
    
    print_bool(10,  size[2]-190, "Conn. to bus", ELEC_sys.batteries[1].is_connected_to_dc_bus)
    print_bool(200, size[2]-190, "Conn. to bus", ELEC_sys.batteries[2].is_connected_to_dc_bus)

    print_bool(10,  size[2]-210, "HOT BUS pwrd", get(ELEC_sys.batteries[1].drs.hotbus) == 1)
    print_bool(200, size[2]-210, "HOT BUS pwrd", get(ELEC_sys.batteries[2].drs.hotbus) == 1)

    sasl.gl.drawFrame(5, size[2]-220, 170, 170, ECAM_WHITE)
    sasl.gl.drawFrame(195, size[2]-220, 170, 170, ECAM_WHITE)

    -- Generators status
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-260, "Generator 1", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 200, size[2]-260,"Generator 2", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 390, size[2]-410, "Generator APU", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-410,"Generator EXT", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(B612MONO_regular, 200, size[2]-410,"Generator EMER", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    print_bool(10,  size[2]-280, "Is on", ELEC_sys.generators[1].switch_status)
    print_bool(200, size[2]-280, "Is on", ELEC_sys.generators[2].switch_status)
    print_bool(390, size[2]-430, "Is on", ELEC_sys.generators[3].switch_status)
    print_bool(10,  size[2]-430, "Is on", ELEC_sys.generators[4].switch_status)
    print_bool(200, size[2]-430, "Is on", ELEC_sys.generators[5].switch_status)
    
    print_bool(10,  size[2]-300, "Engine avail", ELEC_sys.generators[1].source_status)
    print_bool(200, size[2]-300, "Engine avail", ELEC_sys.generators[2].source_status)
    print_bool(390, size[2]-450, "APU avail", ELEC_sys.generators[3].source_status)
    print_bool(10,  size[2]-450, "Extern avail", ELEC_sys.generators[4].source_status)
    print_bool(200, size[2]-450, "RAT running", ELEC_sys.generators[5].source_status)
    
    print_value_dec(10,  size[2]-320, "Voltage (V)", ELEC_sys.generators[1].curr_voltage)
    print_value_dec(200, size[2]-320, "Voltage (V)", ELEC_sys.generators[2].curr_voltage)
    print_value_dec(390, size[2]-470, "Voltage (V)", ELEC_sys.generators[3].curr_voltage)
    print_value_dec(10,  size[2]-470, "Voltage (V)", ELEC_sys.generators[4].curr_voltage)
    print_value_dec(200, size[2]-470, "Voltage (V)", ELEC_sys.generators[5].curr_voltage)

    print_value_dec(10,  size[2]-340, "Current (A)", ELEC_sys.generators[1].curr_amps)
    print_value_dec(200, size[2]-340, "Current (A)", ELEC_sys.generators[2].curr_amps)
    print_value_dec(390, size[2]-490, "Current (A)", ELEC_sys.generators[3].curr_amps)
    print_value_dec(10,  size[2]-490, "Current (A)", ELEC_sys.generators[4].curr_amps)
    print_value_dec(200, size[2]-490, "Current (A)", ELEC_sys.generators[5].curr_amps)

    print_value_dec(10,  size[2]-360, "Freq. (Hz)", ELEC_sys.generators[1].curr_hz)
    print_value_dec(200, size[2]-360, "Freq. (Hz)", ELEC_sys.generators[2].curr_hz)
    print_value_dec(390, size[2]-510, "Freq. (Hz)", ELEC_sys.generators[3].curr_hz)
    print_value_dec(10,  size[2]-510, "Freq. (Hz)", ELEC_sys.generators[4].curr_hz)
    print_value_dec(200, size[2]-510, "Freq. (Hz)", ELEC_sys.generators[5].curr_hz)
       
   
    sasl.gl.drawFrame(5, size[2]-370, 170, 125, ECAM_WHITE)
    sasl.gl.drawFrame(195, size[2]-370, 170, 125, ECAM_WHITE)
    sasl.gl.drawFrame(385, size[2]-520, 170, 125, ECAM_WHITE)
    sasl.gl.drawFrame(5, size[2]-520, 170, 125, ECAM_WHITE)
    sasl.gl.drawFrame(195, size[2]-520, 170, 125, ECAM_ORANGE)
 
    -- Bus status
    sasl.gl.drawText(B612MONO_regular, 390, size[2]-70, "Bus power status", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    print_bool(390,  size[2]-90, "HOT BUS 1", get(HOT_bus_1_pwrd) == 1)
    print_bool(390,  size[2]-110, "HOT BUS 2", get(HOT_bus_2_pwrd) == 1)
    print_bool(390,  size[2]-130, "DC BUS 1", get(DC_bus_1_pwrd) == 1)
    print_bool(390,  size[2]-150, "DC BUS 2", get(DC_bus_2_pwrd) == 1)
    print_bool(390,  size[2]-170, "DC ESS", get(DC_ess_bus_pwrd) == 1)
    print_bool(390,  size[2]-190, "DC SHED ESS", get(DC_shed_ess_pwrd) == 1)
    print_bool(390,  size[2]-210, "BAT BUS", get(DC_bat_bus_pwrd) == 1)
    print_bool(390,  size[2]-230, "AC BUS 1", get(AC_bus_1_pwrd) == 1)
    print_bool(390,  size[2]-250, "AC BUS 2", get(AC_bus_2_pwrd) == 1)
    print_bool(390,  size[2]-270, "AC ESS", get(AC_ess_bus_pwrd) == 1)
    print_bool(390,  size[2]-290, "AC SHED ESS", get(AC_ess_shed_pwrd) == 1)
    print_bool(390,  size[2]-310, "COMMERCIAL", get(Commercial_pwrd) == 1)
    print_bool(390,  size[2]-330, "GALLEY", get(Gally_pwrd) == 1)
    sasl.gl.drawFrame(385, size[2]-340, 170, 290, ECAM_BLUE)

    -- Bus internals
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-550, "Bus sources", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    print_bus_source(10, 85, size[2]-570, "AC BUS 1: ", ELEC_sys.buses.ac1_powered_by)
    print_bus_source(10, 85, size[2]-590, "AC BUS 2: ", ELEC_sys.buses.ac2_powered_by)
    print_bus_source(155, 240, size[2]-570, "AC ESS BUS: ", ELEC_sys.buses.ac_ess_powered_by)
    print_bus_source(155, 240, size[2]-590, "DC 1 BUS: ", ELEC_sys.buses.dc1_powered_by)
    print_bus_source(310, 395, size[2]-570, "DC ESS BUS: ", ELEC_sys.buses.dc_ess_powered_by)
    print_bus_source(310, 395, size[2]-590, "DC 2 BUS: ", ELEC_sys.buses.dc2_powered_by)
    print_bus_source(450, 540, size[2]-570, "BAT BUS: ", ELEC_sys.buses.dc_bat_bus_powered_by)
--    print_bus_source(200, 480, size[2]-570, "DC 1 BUS pwrd by: ", ELEC_sys.buses.dc_1_powered_by)
   

    -- INV and TR
    sasl.gl.drawText(B612MONO_regular, 580, size[2]-70, "Static Inverter", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    print_bool(580,  size[2]-90, "Is active", ELEC_sys.stat_inv.status)
    print_value_dec(580,  size[2]-110, "Voltage (V)", ELEC_sys.stat_inv.curr_voltage)
    print_value_dec(580,  size[2]-130, "Frequency (Hz)", ELEC_sys.stat_inv.curr_hz)
    print_value_dec(580,  size[2]-150, "Curr. OUT (A)", ELEC_sys.stat_inv.curr_out_amps)
    print_value_dec(580,  size[2]-170, "Curr. IN (A)", ELEC_sys.stat_inv.curr_in_amps)
    sasl.gl.drawFrame(575, size[2]-180, 190, 130, ECAM_ORANGE)
    
    sasl.gl.drawText(B612MONO_regular, 580, size[2]-220, "TR 1", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    print_bool(580,  size[2]-240, "Is active", ELEC_sys.trs[1].status)
    print_value_dec(580,  size[2]-260, "Voltage (V)", ELEC_sys.trs[1].curr_voltage)
    print_value_dec(580,  size[2]-280, "Curr. OUT (A)", ELEC_sys.trs[1].curr_out_amps)
    print_value_dec(580,  size[2]-300, "Curr. IN (A)", ELEC_sys.trs[1].curr_in_amps)
    sasl.gl.drawFrame(575, size[2]-310, 150, 110, ECAM_WHITE)

    sasl.gl.drawText(B612MONO_regular, 580, size[2]-330, "TR 2", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    print_bool(580,  size[2]-350, "Is active", ELEC_sys.trs[2].status)
    print_value_dec(580,  size[2]-370, "Voltage (V)", ELEC_sys.trs[2].curr_voltage)
    print_value_dec(580,  size[2]-390, "Curr. OUT (A)", ELEC_sys.trs[2].curr_out_amps)
    print_value_dec(580,  size[2]-410, "Curr. IN (A)", ELEC_sys.trs[2].curr_in_amps)
    sasl.gl.drawFrame(575, size[2]-420, 150, 110, ECAM_WHITE)
    
    sasl.gl.drawText(B612MONO_regular, 580, size[2]-440, "TR ESS", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    print_bool(580,  size[2]-460, "Is active", ELEC_sys.trs[3].status)
    print_value_dec(580,  size[2]-480, "Voltage (V)", ELEC_sys.trs[3].curr_voltage)
    print_value_dec(580,  size[2]-500, "Curr. OUT (A)", ELEC_sys.trs[3].curr_out_amps)
    print_value_dec(580,  size[2]-520, "Curr. IN (A)", ELEC_sys.trs[3].curr_in_amps)
    sasl.gl.drawFrame(575, size[2]-530, 150, 110, ECAM_ORANGE)
    
end
