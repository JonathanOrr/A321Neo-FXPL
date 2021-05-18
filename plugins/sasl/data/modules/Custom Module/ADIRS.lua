-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: ADIRS.lua 
-- Short description: The code for ADR and IR components
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

include('ELEC_subcomponents/include.lua')

local TIME_TO_START_ADR       = 2 -- In seconds
local IR_TIME_TO_GET_ATTITUDE = 20 -- In seconds
local TIME_TO_ONBAT = 5 --five seconds before onbat light extinguishes if AC available

local HOT_START_GPS  = 1    -- nr. of seconds required to get GPS fix if last time active < 1 hour
local WARM_START_GPS = 20   -- nr. of seconds required to get GPS fix if last time active > 1 hour (we don't simulate cold start)

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

local gps_last_time_on =  {0,0}
local gps_start_time_point = {0,0}
local gps_1_offset = math.random() * 200 - 100
local gps_2_offset = math.random() * 200 - 100

-- The following 3 randomized values are used for generate errors on failures
local random_err = {}
random_err[1] = math.random()
random_err[2] = math.random()
random_err[3] = math.random()

while math.abs(random_err[2] - random_err[1]) < 0.1 do
    random_err[2] = math.random()
end

while math.abs(random_err[3] - random_err[1]) < 0.1
   or math.abs(random_err[3] - random_err[2]) < 0.1 do
    random_err[3] = math.random()
end

----------------------------------------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------------------------------------

local ADIRS = {
    id = 0,
    adirs_switch_status = ADIRS_CONFIG_OFF,
    is_on_bat = false,


    -- IR
    ir_status = IR_STATUS_OFF,
    ir_switch_status = true,
    ir_light_dataref = nil,
    ir_align_start_time = 0,
    ir_is_waiting_hdg = true,
    ir_is_aligning_gps = true,
    manual_hdg_offset = 0,
    
    -- ADR
    adr_status = ADR_STATUS_OFF,
    adr_switch_status = true,
    adr_light_dataref = nil,
    adr_align_start_time = 0,
    
    adr_ias_offset = 0,
    adr_alt_offset = 0,
    
    -- Electrical
    elec_bus_primary = 0,       -- AC
    elec_bus_secondary = 0,     -- DC
    
    -- Values - ADR
    ias = 0,
    ias_trend = 0,
    tas = 0,
    alt = 0,
    vs  = 0,
    wind_spd = 0,
    wind_dir = 0,
    mach = 0,
    
    -- Values - IR
    pitch = 0,
    roll = 0,
    hdg = 0,
    true_hdg = 0,
    track = 0,
    lat = 0,
    lon = 0,
    gs = 0,
    aoa = 0,
    g_load_vert = 0,
    g_load_lat  = 0,
    g_load_long = 0,
}

-- Constructor for the class
function ADIRS:create (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function ADIRS:init()
    self.adr_ias_offset = math.random() * 2 - 1   -- Max offset IAS between ADR1/2 and ADR3: +1/-1
    self.adr_alt_offset = math.random() * 20 - 10 -- Max offset Altitude between ADR1/2 and ADR3: +10/-10
end

------------------------------------------- ADR

function ADIRS:update_adr_elec()
    -- 35 W ADR https://aerospace.honeywell.com/content/dam/aero/en-us/documents/learn/products/sensors/brochures/C61-0308-000-001-AirDataComputer-bro.pdf?download=true

    self.is_on_bat = self.adirs_switch_status ~= ADIRS_CONFIG_OFF
    
    -- AC BUS
    local dr_primary = elec_const_to_dr(self.elec_bus_primary)
    if get(dr_primary) == 1 then
        ELEC_sys.add_power_consumption(self.elec_bus_primary, 0.28, 0.30)
        self.is_on_bat = self.adr_align_start_time > 0 and get(TIME) - self.adr_align_start_time < TIME_TO_ONBAT
        return true
    end
    
    -- Battery BUS
    local dr_secondary = elec_const_to_dr(self.elec_bus_secondary)
    if get(dr_secondary) == 1 and self.is_on_bat then
        ELEC_sys.add_power_consumption(self.elec_bus_secondary, 1.2, 1.25)
        return true
    end
    
    self.is_on_bat = false
    -- Damn, no power
    return false
end

function ADIRS:update_adr()

    if override_ADIRS_ok then
        -- DEBUG Override case
        self.adr_status = ADR_STATUS_ON
        return
    end

    local elec_ok = self:update_adr_elec()
    local is_faulty = get(FAILURE_ADR[self.id]) == 1
    if not elec_ok or is_faulty then
        self.adr_status = is_faulty and ADR_STATUS_FAULT or ADR_STATUS_OFF
        return
    end
    
    if not self.adr_switch_status or self.adirs_switch_status == ADIRS_CONFIG_OFF then
        -- The ADR switch is off or the main knob is to off
        self.adr_align_start_time = 0
        self.adr_status = ADR_STATUS_OFF
        return
    end

    if self.adr_align_start_time ~= 0 then
        if get(TIME) - self.adr_align_start_time > TIME_TO_START_ADR then
            self.adr_status = ADR_STATUS_ON
        end
    else
        self.adr_status = ADR_STATUS_STARTING
        self.adr_align_start_time = get(TIME)
    end

end

function ADIRS:update_adr_dr()
    pb_set(self.adr_light_dataref, not self.adr_switch_status, self.adr_status == ADR_STATUS_FAULT)
end

function ADIRS:update_adr_data()
    
    local computed_ias = get(self.ias_dataref) + self.adr_ias_offset + get(self.err_pitot_dataref) * (random_err[self.id] > 0.5 and random_err[self.id] * 50 or (random_err[self.id]-1) * 50)
    local computed_alt = get(self.baroalt_dataref) + self.adr_alt_offset + get(self.err_static_dataref) * (-10000*(random_err[self.id]+0.1))
    local computed_mach = get(self.mach_dataref) + get(self.err_pitot_dataref) * (random_err[self.id]/2)
    
    if self.adr_status == ADR_STATUS_ON then
        self.ias = computed_ias
        self.ias_trend = get(self.ias_trend_dataref) + get(self.err_pitot_dataref) * (math.random()*10)
        self.tas = get(self.tas_dataref) + self.adr_ias_offset + get(self.err_pitot_dataref) * (self.ias/10)
        self.mach = computed_mach
        self.alt = computed_alt
        self.vs  = get(self.vvi_dataref) + get(self.err_static_dataref) * ((random_err[self.id]-0.5)*1000)
        
        if self.ir_status == IR_STATUS_ALIGNED then
            self.wind_spd = get(Wind_SPD) + get(self.err_pitot_dataref) * (self.ias/10)
            self.wind_dir = get(Wind_HDG)
        end
    end
    
    if self.id == ADIRS_3 then
        set(ISIS_IAS, computed_ias)
        set(ISIS_Altitude, computed_alt)
        set(ISIS_Mach, computed_mach)
    end
end

------------------------------------------- IR

function ADIRS:update_ir_elec()
    -- 39 W https://aerospace.honeywell.com/content/dam/aero/en-us/documents/learn/products/navigation-and-radios/brochures/C61-0668-000-000-ADIRS-For-Airbus-May-2007-bro.pdf?download=true
    self.is_on_bat = self.adirs_switch_status ~= ADIRS_CONFIG_OFF

    -- AC BUS
    local dr_primary = elec_const_to_dr(self.elec_bus_primary)
    if get(dr_primary) == 1 then
        ELEC_sys.add_power_consumption(self.elec_bus_primary, 0.3, 0.33)
        self.is_on_bat = self.ir_align_start_time ~= 0 and get(TIME) - self.ir_align_start_time < TIME_TO_ONBAT
        return true
    end
    
    -- Battery BUS
    local dr_secondary = elec_const_to_dr(self.elec_bus_secondary)
    if get(dr_secondary) == 1 then
        ELEC_sys.add_power_consumption(self.elec_bus_secondary, 1.2, 1.39) 
        return true
    end
    
    self.is_on_bat = false
    -- Damn, no power
    return false
end

function ADIRS:update_ir_nav()
    if self.ir_align_start_time ~= 0 then
        local time_to_align = get(Adirs_total_time_to_align)
        if self.ir_align_start_time == -10000 or (time_to_align ~= 0 and get(TIME) - self.ir_align_start_time > time_to_align) then
            self.ir_status = IR_STATUS_ALIGNED
        end
    else
        self.ir_status = IR_STATUS_IN_ALIGN
        self.ir_align_start_time = get(TIME)
    end
end

function ADIRS:update_ir_att()
    if self.ir_align_start_time ~= 0 then
        if get(TIME) - self.ir_align_start_time > IR_TIME_TO_GET_ATTITUDE then
            self.ir_status = IR_STATUS_ATT_ALIGNED
        end
        if math.abs(get(Flightmodel_pitch)) > 10 or math.abs(get(Flightmodel_roll)) > 10 then
            self.ir_align_start_time = self.ir_align_start_time + get(DELTA_TIME)
        end
    else
        self.ir_status = IR_STATUS_IN_ALIGN
        self.ir_align_start_time = get(TIME)
    end
end

function ADIRS:update_ir()
    if override_ADIRS_ok then
        -- DEBUG Override case
        self.ir_status = IR_STATUS_ALIGNED
        return
    end
    
    if not self.ir_switch_status or self.adirs_switch_status == ADIRS_CONFIG_OFF then
        -- The ADR switch is off or the main knob is to off
        self.ir_align_start_time = 0
        self.ir_status = IR_STATUS_OFF
        return
    end

    local elec_ok = self:update_ir_elec()
    local is_faulty_1 = get(FAILURE_IR[self.id]) == 1 and self.adirs_switch_status == ADIRS_CONFIG_NAV
    local is_faulty_2 = get(FAILURE_IR_ATT[self.id]) == 1 and self.adirs_switch_status == ADIRS_CONFIG_ATT
    if not elec_ok or is_faulty_1 or is_faulty_2 then
        self.ir_status = (is_faulty_1 or is_faulty_2) and IR_STATUS_FAULT or IR_STATUS_OFF
        if self.ir_status == IR_STATUS_FAULT then
            -- We don't reset the align start time when there is no power, because we don't want
            -- to restart the alignment just for a transient of elec
            self.ir_align_start_time = 0
        end
        return
    end
    
    -- Ok IR is ON and not faulty, two cases now: it's in NAV or it's in ATT
    if self.adirs_switch_status == ADIRS_CONFIG_NAV then
        self:update_ir_nav()
    else
        -- This is ATT
        self:update_ir_att()    
    end
    
end

function ADIRS:update_ir_dr()
    local blink_start = get(TIME) - self.ir_align_start_time < 0.3
    local blink_partial_failure = get(FAILURE_IR[self.id]) == 1 and get(FAILURE_IR_ATT[self.id]) == 0 and self.adirs_switch_status == ADIRS_CONFIG_NAV
    local light_fault_condition =  (self.ir_status == IR_STATUS_FAULT and not blink_partial_failure) or blink_start or (blink_partial_failure and get(TIME) % 0.4 < 0.2)
    pb_set(self.ir_light_dataref, not self.ir_switch_status, light_fault_condition)
end

function ADIRS:update_ir_data()

    if self.ir_status == IR_STATUS_ALIGNED then
        self.track = get(self.track_dataref)
        self.lat   = get(Aircraft_lat)
        self.lon   = get(Aircraft_long)
        self.gs    = get(Ground_speed_kts)
        self.hdg   = (get(Flightmodel_mag_heading) + get(self.err_hdg_dataref) * (random_err[self.id] > 0.5 and -1 or 1) * (random_err[self.id]+0.5) * 180) % 360
        self.true_hdg = get(Flightmodel_true_heading)
        self.g_load_vert = get(Total_vertical_g_load)
        self.g_load_lat  = get(Total_lateral_g_load)
        self.g_load_long = get(Total_long_g_load)
    end

    if self.ir_status == IR_STATUS_ALIGNED or self.ir_status == IR_STATUS_ATT_ALIGNED then
        self.pitch = get(self.pitch_dataref) + get(self.err_pitch_dataref) * (random_err[self.id] > 0.5 and -1 or 1) * (random_err[self.id]+0.5) * 50
        self.roll = get(self.roll_dataref) + get(self.err_roll_dataref) * (random_err[self.id] > 0.5 and -1 or 1) * (random_err[self.id]+0.5) * 50
        self.aoa = (get(Alpha) + get(self.err_aoa_dataref)*(random_err[self.id]+0.5)*10) * (1-get(self.fail_aoa_dataref))
        if self.ir_status == IR_STATUS_ATT_ALIGNED and not self.ir_is_waiting_hdg then
            self.hdg = (get(Flightmodel_mag_heading) + self.manual_hdg_offset + get(self.err_hdg_dataref) * (random_err[self.id] > 0.5 and -1 or 1) * (random_err[self.id]+0.5) * 180) % 360
        end
    end
    
end

function ADIRS:align_instantaneously()
    self.ir_align_start_time = -10000
    self.adr_align_start_time = -10000
end

function ADIRS:reset()
    self.ir_align_start_time = 0
end


----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Custom commands (internal only, refers to cockpit_commands.lua for switch commands
----------------------------------------------------------------------------------------------------
ADIRS_cmd_instantaneous_align     = createCommand("a321neo/cockpit/ADIRS/instantaneous_align", "Move right the knob")

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ADIRS_cmd_ADR1, 0, function(phase) ADIRS_handler_toggle_ADR(phase, ADIRS_1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_ADR2, 0, function(phase) ADIRS_handler_toggle_ADR(phase, ADIRS_2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_ADR3, 0, function(phase) ADIRS_handler_toggle_ADR(phase, ADIRS_3); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR1, 0,  function(phase) ADIRS_handler_toggle_IR(phase, ADIRS_1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR2, 0,  function(phase) ADIRS_handler_toggle_IR(phase, ADIRS_2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_IR3, 0,  function(phase) ADIRS_handler_toggle_IR(phase, ADIRS_3); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_knob_1_up, 0,   function(phase) ADIRS_sys[ADIRS_1]:reset();  Knob_handler_up_int(phase, ADIRS_rotary_btn[1], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_up, 0,   function(phase) ADIRS_sys[ADIRS_2]:reset(); Knob_handler_up_int(phase, ADIRS_rotary_btn[2], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_up, 0,   function(phase) ADIRS_sys[ADIRS_3]:reset(); Knob_handler_up_int(phase, ADIRS_rotary_btn[3], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_1_down, 0, function(phase) ADIRS_sys[ADIRS_1]:reset(); Knob_handler_down_int(phase, ADIRS_rotary_btn[1], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_2_down, 0, function(phase) ADIRS_sys[ADIRS_2]:reset(); Knob_handler_down_int(phase, ADIRS_rotary_btn[2], 0, 2); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_knob_3_down, 0, function(phase) ADIRS_sys[ADIRS_3]:reset(); Knob_handler_down_int(phase, ADIRS_rotary_btn[3], 0, 2); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_up, 0,     function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_ATHDG, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_ATHDG_down, 0,   function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_ATHDG, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_up, 0,   function(phase) Knob_handler_up_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1); return 1 end )
sasl.registerCommandHandler (ADIRS_cmd_source_AIRDATA_down, 0, function(phase) Knob_handler_down_int(phase, ADIRS_source_rotary_AIRDATA, -1, 1); return 1 end )

sasl.registerCommandHandler (ADIRS_cmd_instantaneous_align, 0, function(phase) adirs_inst_align(phase); return 1 end )

sasl.registerCommandHandler (PFD_Capt_BUSS_enable, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(BUSS_Capt_man_enabled, 1 - get(BUSS_Capt_man_enabled)) end end )
sasl.registerCommandHandler (PFD_Fo_BUSS_enable, 0,   function(phase) if phase == SASL_COMMAND_BEGIN then set(BUSS_Fo_man_enabled, 1 - get(BUSS_Fo_man_enabled)) end end )

function ADIRS_handler_toggle_ADR(phase, n)
    if phase == SASL_COMMAND_BEGIN then
        ADIRS_sys[n].adr_switch_status = not ADIRS_sys[n].adr_switch_status
    end
end

function ADIRS_handler_toggle_IR(phase, n)
    if phase == SASL_COMMAND_BEGIN then
        ADIRS_sys[n].ir_switch_status = not ADIRS_sys[n].ir_switch_status
    end
end

function adirs_inst_align(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    ADIRS_sys[1]:align_instantaneously()
    ADIRS_sys[2]:align_instantaneously()
    ADIRS_sys[3]:align_instantaneously()
end

function onAirportLoaded()
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        set(ADIRS_rotary_btn[1], 1)
        set(ADIRS_rotary_btn[2], 1)
        set(ADIRS_rotary_btn[3], 1)
        ADIRS_sys[ADIRS_1].adirs_switch_status = 1
        ADIRS_sys[ADIRS_2].adirs_switch_status = 1
        ADIRS_sys[ADIRS_3].adirs_switch_status = 1

        adirs_inst_align(SASL_COMMAND_BEGIN)
    end
end

----------------------------------------------------------------------------------------------------
-- Initlization
----------------------------------------------------------------------------------------------------

local function init_adirs()

    ADIRS_sys[ADIRS_1] = ADIRS:create({
            id = ADIRS_1,
            elec_bus_primary=ELEC_BUS_AC_ESS,
            elec_bus_secondary=ELEC_BUS_HOT_BUS_2,
            adr_light_dataref = PB.ovhd.adr_1,
            ir_light_dataref = PB.ovhd.ir_1,
            ias_dataref = Capt_IAS,
            ias_trend_dataref = Capt_IAS_trend,
            tas_dataref = Capt_TAS,
            baroalt_dataref = Capt_Baro_Alt,
            vvi_dataref = Capt_VVI,
            mach_dataref = Capt_Mach,
            track_dataref = Capt_Track,
            pitch_dataref = Capt_pitch,
            roll_dataref = Capt_bank,
            fail_aoa_dataref = FAILURE_SENSOR_AOA_CAPT,
            err_aoa_dataref = FAILURE_SENSOR_AOA_CAPT_ERR,
            err_pitot_dataref = FAILURE_SENSOR_PITOT_CAPT_ERR,
            err_static_dataref = FAILURE_SENSOR_STATIC_CAPT_ERR,
            err_pitch_dataref = FAILURE_IR1_ATT_PITCH_ERR,
            err_roll_dataref  = FAILURE_IR1_ATT_ROLL_ERR,
            err_hdg_dataref = FAILURE_IR1_HDG_ERR,

            })
    ADIRS_sys[ADIRS_2] = ADIRS:create({
            id = ADIRS_2,
            elec_bus_primary=ELEC_BUS_AC_2,
            elec_bus_secondary=ELEC_BUS_HOT_BUS_2,
            adr_light_dataref = PB.ovhd.adr_2,
            ir_light_dataref = PB.ovhd.ir_2,
            ias_dataref = Fo_IAS,
            ias_trend_dataref = Fo_IAS_trend,
            tas_dataref = Fo_TAS,
            baroalt_dataref = Fo_Baro_Alt,
            vvi_dataref = Fo_VVI,
            mach_dataref = Fo_Mach,
            track_dataref = Fo_Track,
            pitch_dataref = Fo_pitch,
            roll_dataref = Fo_bank,
            fail_aoa_dataref = FAILURE_SENSOR_AOA_FO,
            err_aoa_dataref = FAILURE_SENSOR_AOA_FO_ERR,
            err_pitot_dataref = FAILURE_SENSOR_PITOT_FO_ERR,
            err_static_dataref = FAILURE_SENSOR_STATIC_FO_ERR,
            err_pitch_dataref = FAILURE_IR2_ATT_PITCH_ERR,
            err_roll_dataref  = FAILURE_IR2_ATT_ROLL_ERR,
            err_hdg_dataref = FAILURE_IR2_HDG_ERR,
            })
    ADIRS_sys[ADIRS_3] = ADIRS:create({
            id = ADIRS_3,
            elec_bus_primary=ELEC_BUS_AC_1,
            elec_bus_secondary=ELEC_BUS_HOT_BUS_1,
            adr_light_dataref = PB.ovhd.adr_3,
            ir_light_dataref = PB.ovhd.ir_3,
            ias_dataref = Stby_IAS,
            ias_trend_dataref = Fo_IAS_trend,
            tas_dataref = Fo_TAS,
            baroalt_dataref = Stby_Alt,
            vvi_dataref = Fo_VVI,
            mach_dataref = Fo_Mach,
            track_dataref = Fo_Track,
            pitch_dataref = Fo_pitch,
            roll_dataref = Fo_bank,
            fail_aoa_dataref = FAILURE_SENSOR_AOA_STBY,
            err_aoa_dataref = FAILURE_SENSOR_AOA_STBY_ERR,
            err_pitot_dataref = FAILURE_SENSOR_PITOT_STBY_ERR,
            err_static_dataref = FAILURE_SENSOR_STATIC_STBY_ERR,
            err_pitch_dataref = FAILURE_IR3_ATT_PITCH_ERR,
            err_roll_dataref  = FAILURE_IR3_ATT_ROLL_ERR,
            err_hdg_dataref = FAILURE_IR3_HDG_ERR,

            })
    
    ADIRS_sys[ADIRS_1]:init()
    ADIRS_sys[ADIRS_2]:init()
    ADIRS_sys[ADIRS_3]:init()
    
    onAirportLoaded() -- Ensure if sasl has been reboot to check the airport condition
end

init_adirs()


local function update_adrs()
    ADIRS_sys[ADIRS_1]:update_adr()
    ADIRS_sys[ADIRS_1]:update_adr_dr()
    ADIRS_sys[ADIRS_1]:update_adr_data()
    ADIRS_sys[ADIRS_2]:update_adr()
    ADIRS_sys[ADIRS_2]:update_adr_dr()
    ADIRS_sys[ADIRS_2]:update_adr_data()
    ADIRS_sys[ADIRS_3]:update_adr()
    ADIRS_sys[ADIRS_3]:update_adr_dr()
    ADIRS_sys[ADIRS_3]:update_adr_data()
end

local function update_irs()
    set(Adirs_total_time_to_align, get_time_to_align())

    ADIRS_sys[ADIRS_1]:update_ir()
    ADIRS_sys[ADIRS_1]:update_ir_dr()
    ADIRS_sys[ADIRS_1]:update_ir_data()
    ADIRS_sys[ADIRS_2]:update_ir()
    ADIRS_sys[ADIRS_2]:update_ir_dr()
    ADIRS_sys[ADIRS_2]:update_ir_data()
    ADIRS_sys[ADIRS_3]:update_ir()
    ADIRS_sys[ADIRS_3]:update_ir_dr()
    ADIRS_sys[ADIRS_3]:update_ir_data()
    
end

local function update_on_bat_light()
    -- If at least 1 IRS is on battery or annunciator test triggered, let's turn on the ON BAT light
    local ir_condition = ADIRS_sys[ADIRS_1].is_on_bat 
                      or ADIRS_sys[ADIRS_2].is_on_bat
                      or ADIRS_sys[ADIRS_3].is_on_bat
        
    if ir_condition or get(Cockpit_annnunciators_test) == 1 then
        set(ADIRS_light_onbat, 1)
    else
        set(ADIRS_light_onbat, 0)    
    end
end


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

-- It returns the time required to align the IRs
function get_time_to_align()
    --add function for linear interpolation (source: https://codea.io/talk/discussion/7448/linear-interpolation)
    function lerp(pos1, pos2, perc)
        return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
    end
    
    --set hard values for latitudes between 60 and 70.2 and 70.2 and 78.25 and interpolate for the rest
    local lat = get(Aircraft_lat)
    if lat >= 60 and lat < 70.2 then
        return 600
    elseif lat >= 70.2 and get(Aircraft_lat) <= 78.25 then
        return 1020
    elseif lat >= 0 and lat < 60  then
        return lerp(300, 600, (lat / 60))
    elseif lat <= -60 and lat > -70.2 then
        return 600
    elseif lat <= -70.2 and lat >= -78.25 then
        return 1020
    elseif lat < 0 and lat > -60 then
        return lerp(300, 600, (get(Aircraft_lat) / -60))
    else
        return 0 -- Latitude is greater than 78.25- too high for IRS alignment
    end
end

local function update_anim_knobs()

    ADIRS_sys[ADIRS_1].adirs_switch_status = get(ADIRS_rotary_btn[1])
    ADIRS_sys[ADIRS_2].adirs_switch_status = get(ADIRS_rotary_btn[2])
    ADIRS_sys[ADIRS_3].adirs_switch_status = get(ADIRS_rotary_btn[3])

    Set_dataref_linear_anim_nostop(ADIRS_source_rotary_ATHDG_anim, get(ADIRS_source_rotary_ATHDG), -1, 1, 10)
    Set_dataref_linear_anim_nostop(ADIRS_source_rotary_AIRDATA_anim, get(ADIRS_source_rotary_AIRDATA), -1, 1, 10)
    
    Set_dataref_linear_anim_nostop(ADIRS_rotary_btn_anim[1], get(ADIRS_rotary_btn[1]), 0, 2, 10)
    Set_dataref_linear_anim_nostop(ADIRS_rotary_btn_anim[2], get(ADIRS_rotary_btn[2]), 0, 2, 10)
    Set_dataref_linear_anim_nostop(ADIRS_rotary_btn_anim[3], get(ADIRS_rotary_btn[3]), 0, 2, 10)
    
end

----------------------------------------------------------------------------------------------------
-- GPS
----------------------------------------------------------------------------------------------------
local function update_gps_single(nr, power_status, not_failure_status)
    if power_status and not_failure_status then
        -- GPS is online
        if nr == 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.1, 0.1)
        else
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.1, 0.1)        
        end

        if gps_start_time_point[nr] == 0 then
            gps_start_time_point[nr] = get(TIME)
        end
        
        if get(TIME) - gps_last_time_on[nr] > 3600 or gps_last_time_on[nr] == 0 then
            -- We need a cold start
            if get(TIME) - gps_start_time_point[nr] > WARM_START_GPS then
                gps_last_time_on[nr] = get(TIME)
                return 1
            end
        else
            if get(TIME) - gps_start_time_point[nr] > HOT_START_GPS then
                gps_last_time_on[nr] = get(TIME)
                return 1
            end        
        end
    else
        gps_start_time_point[nr] = 0
    end
    return 0
end

local function update_gps()

    local roll_is_ok = math.abs(get(Flightmodel_roll)) <= 90

    if override_ADIRS_ok then
        set(GPS_1_is_available, 1)
        set(GPS_2_is_available, 1)
    else
        set(GPS_1_is_available, update_gps_single(1, get(AC_ess_bus_pwrd) == 1, get(FAILURE_GPS_1) == 0 and roll_is_ok))
        set(GPS_2_is_available, update_gps_single(2, get(AC_bus_2_pwrd) == 1,   get(FAILURE_GPS_2) == 0 and roll_is_ok))
    end

    if get(GPS_1_is_available) == 1 then
        set(GPS_1_altitude, gps_1_offset + get(Elevation_m) * 3.28084)
    end
    
    if get(GPS_2_is_available) == 1 then
        set(GPS_2_altitude, gps_2_offset + get(Elevation_m) * 3.28084)
    end
    
end

local function update_buss()
    pb_set(PB.mip.capt_buss,get(BUSS_Capt_man_enabled) == 1, false)
    pb_set(PB.mip.fo_buss,  get(BUSS_Fo_man_enabled) == 1, false)
end

----------------------------------------------------------------------------------------------------
-- update()
----------------------------------------------------------------------------------------------------
function update ()

    perf_measure_start("ADIRS:update()")
    
    update_adrs()
    update_irs()
    update_on_bat_light()
    update_anim_knobs()
    update_gps()
    update_buss()
    
    perf_measure_stop("ADIRS:update()")
    
end
