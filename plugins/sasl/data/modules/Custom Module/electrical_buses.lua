----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_1 = 1
local GEN_2 = 2
local GEN_APU = 3
local GEN_EXT  = 4
local GEN_EMER = 5

local AC_BUS_1 = 11
local AC_BUS_2 = 12

local STATIC_INVERTER = 21

local TR_1 = 31
local TR_2 = 32
local TR_ESS = 33

local BAT_1 = 41
local BAT_2 = 42

local CROSS_TIEBAT_BUS = 98
local GEN_FAKE_BUS_TIE = 99

local BUS_SWITCH_DELAY = 0.2

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_BUS_tie,  0, function(phase) elec_bus_tie_toggle(phase) end )
sasl.registerCommandHandler (ELEC_cmd_AC_ess_feed,  0, function(phase) elec_bus_acc_ess_toggle(phase) end )

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

buses = {
    ac1_powered_by = 0,
    ac2_powered_by = 0,
    ac_ess_powered_by = 0,
    dc1_powered_by = 0,
    dc2_powered_by = 0,
    dc_ess_powered_by = 0,
    dc_bat_bus_powered_by = 0,
    
    is_ac_ess_shed_on = 0,
    is_dc_ess_shed_on = 0,
    is_stat_inv_bus_on = 0,
    
    pwr_consumption = {},       -- Used in current computation
    pwr_consumption_last = {},   -- Last
    
    bus_tie_pushbutton_status = true,
    ac_ess_bus_pushbutton_status = false -- true: alternate, false: normal
}

ELEC_sys.buses = buses

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------
function elec_bus_tie_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    buses.bus_tie_pushbutton_status = not buses.bus_tie_pushbutton_status
end

function elec_bus_acc_ess_toggle(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    buses.ac_ess_bus_pushbutton_status = not buses.ac_ess_bus_pushbutton_status
end


local switch_time = {}

local function delay_output_bus(output, prev_output_val, bus, max_time)

    if prev_output_val == output then
        return output
    end

    if output ~= 0 then
        if switch_time[bus] == nil then
            switch_time[bus] = get(TIME)
        elseif get(TIME) - switch_time[bus] > max_time then
            switch_time[bus] = nil
            return output
        end
    end
    return 0
end 



local function update_ac_1()

    local prev_by = buses.ac1_powered_by
    buses.ac1_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(FAILURE_ELEC_AC1_bus) == 1 then
        return  -- Not powered
    elseif get(Gen_1_pwr) == 1 then
        buses.ac1_powered_by = GEN_1
    elseif get(Gen_EXT_pwr) == 1 then
        buses.ac1_powered_by = GEN_EXT
    elseif get(Gen_APU_pwr) == 1 then
        buses.ac1_powered_by = GEN_APU
    elseif buses.bus_tie_pushbutton_status and get(AC_bus_2_pwrd) == 1 and buses.ac2_powered_by ~= GEN_FAKE_BUS_TIE then
        buses.ac1_powered_by = GEN_FAKE_BUS_TIE
    end

    buses.ac1_powered_by = delay_output_bus(buses.ac1_powered_by, prev_by, ELEC_BUS_AC_1, BUS_SWITCH_DELAY)

end



local function update_ac_2()

    local prev_by = buses.ac2_powered_by
    buses.ac2_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(FAILURE_ELEC_AC2_bus) == 1 then
        return  -- Not powered
    elseif get(Gen_2_pwr) == 1 then
        buses.ac2_powered_by = GEN_2
    elseif get(Gen_EXT_pwr) == 1 then
        buses.ac2_powered_by = GEN_EXT
    elseif get(Gen_APU_pwr) == 1 then
        buses.ac2_powered_by = GEN_APU
    elseif buses.bus_tie_pushbutton_status and get(AC_bus_1_pwrd) == 1 and buses.ac1_powered_by ~= GEN_FAKE_BUS_TIE then
        buses.ac2_powered_by = GEN_FAKE_BUS_TIE
    end

    buses.ac2_powered_by = delay_output_bus(buses.ac2_powered_by, prev_by, ELEC_BUS_AC_2, BUS_SWITCH_DELAY)
end

local function update_ac_ess()

    local prev_by = buses.ac_ess_powered_by

    buses.ac_ess_powered_by = 0
    
    if get(FAILURE_ELEC_AC_ESS_bus) == 1 then
        return
    end

    if buses.ac_ess_bus_pushbutton_status then  -- Depends on the button in the overhead panel
        buses.ac_ess_powered_by = buses.ac2_powered_by ~= 0 and AC_BUS_2 or 0
    else
        buses.ac_ess_powered_by = buses.ac1_powered_by ~= 0 and AC_BUS_1 or 0
    end
    
    if buses.ac_ess_powered_by == 0 then
        if get(Gen_EMER_pwr) == 1 then
            buses.ac_ess_powered_by = GEN_EMER
        elseif get(INV_online) == 1 and get(Ground_speed_ms) > 50 then
            buses.ac_ess_powered_by = STATIC_INVERTER
        end
    end
    
    buses.ac_ess_powered_by = delay_output_bus(buses.ac_ess_powered_by, prev_by, ELEC_BUS_AC_ESS, BUS_SWITCH_DELAY)
    
end

local function update_dc_1()

    buses.dc1_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!
    if get(FAILURE_ELEC_DC1_bus) == 1 then
        return
    elseif get(TR_1_online) == 1 then
        buses.dc1_powered_by = TR_1
    elseif buses.dc2_powered_by > 0 and buses.dc2_powered_by ~= CROSS_TIEBAT_BUS then
        buses.dc1_powered_by = CROSS_TIEBAT_BUS
    end

end

local function update_dc_2()

    buses.dc2_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!
    if get(FAILURE_ELEC_DC2_bus) == 1 then
        return
    elseif get(TR_2_online) == 1 then
        buses.dc2_powered_by = TR_2
    elseif buses.dc1_powered_by > 0 and buses.dc1_powered_by ~= CROSS_TIEBAT_BUS then
        buses.dc2_powered_by = CROSS_TIEBAT_BUS
    end

end

local function update_dc_ess()
    buses.dc_ess_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(FAILURE_ELEC_DC_ESS_bus) == 1 then
        return
    elseif get(TR_ESS_online) == 1 then
        buses.dc_ess_powered_by = TR_ESS
    elseif get(TR_1_online) == 1 then
        buses.dc_ess_powered_by = TR_1
    elseif get(HOT_bus_2_pwrd) and ELEC_sys.batteries[2].switch_status == true and get(ELEC_sys.batteries[2].drs.hotbus) == 1 then
        buses.dc_ess_powered_by = BAT_2
    end
end

local function update_dc_bat_bus()
    buses.dc_bat_bus_powered_by  = 0

    -- The order of this if-elseif matches the real source priority! Do not change it!

    if get(FAILURE_ELEC_DC_BAT_bus) == 1 then
        return
    elseif get(TR_1_online) == 1 then
        buses.dc_bat_bus_powered_by = TR_1
    elseif get(TR_2_online) == 1 then
        buses.dc_bat_bus_powered_by = TR_2
    elseif ELEC_sys.batteries[1].is_connected_to_dc_bus then
        buses.dc_bat_bus_powered_by = BAT_1     
    elseif ELEC_sys.batteries[2].is_connected_to_dc_bus then
        buses.dc_bat_bus_powered_by = BAT_2
    end
end

local function update_datarefs()

    if ovveride_ELEC_always_on then -- For DEBUG only
        set(AC_bus_1_pwrd, 1)
        set(AC_bus_2_pwrd, 1)
        set(AC_ess_bus_pwrd, 1)
        
        set(DC_bus_1_pwrd, 1)
        set(DC_bus_2_pwrd, 1)
        set(DC_ess_bus_pwrd, 1)
        set(DC_bat_bus_pwrd, 1)

        set(AC_ess_shed_pwrd, 1)
        set(DC_shed_ess_pwrd, 1)

        set(AC_STAT_INV_pwrd, 1)
    else
        set(AC_bus_1_pwrd, buses.ac1_powered_by > 0 and 1 or 0)
        set(AC_bus_2_pwrd, buses.ac2_powered_by > 0 and 1 or 0)
        set(AC_ess_bus_pwrd, buses.ac_ess_powered_by > 0 and 1 or 0)
        
        set(DC_bus_1_pwrd, buses.dc1_powered_by > 0 and 1 or 0)
        set(DC_bus_2_pwrd, buses.dc2_powered_by > 0 and 1 or 0)
        set(DC_ess_bus_pwrd, buses.dc_ess_powered_by > 0 and 1 or 0)
        set(DC_bat_bus_pwrd, buses.dc_bat_bus_powered_by > 0 and 1 or 0)

        set(AC_ess_shed_pwrd, buses.is_ac_ess_shed_on and 1 or 0)
        set(DC_shed_ess_pwrd, buses.is_dc_ess_shed_on and 1 or 0)

        set(AC_STAT_INV_pwrd, buses.is_stat_inv_bus_on and 1 or 0)
    end
    
    set(Elec_light_BUS_tie, buses.bus_tie_pushbutton_status and 0 or 1)
    set(Elec_light_AC_ess_feed, (buses.ac_ess_bus_pushbutton_status and 1 or 0) + (buses.ac_ess_powered_by>0 and 0 or 10)) 
end

local function update_shed()
    buses.is_ac_ess_shed_on = get(FAILURE_ELEC_AC_ESS_SHED_bus) == 0 and 
                              (buses.ac1_powered_by > 0 or buses.ac2_powered_by > 0
                              or buses.ac_ess_powered_by == GEN_EMER)
    buses.is_dc_ess_shed_on = get(FAILURE_ELEC_DC_ESS_SHED_bus) == 0 and
                              (buses.dc1_powered_by > 0 or buses.dc2_powered_by > 0 
                              or buses.dc_ess_powered_by == TR_ESS)
end

local function update_stat_inv()
    buses.is_stat_inv_bus_on = get(INV_online) == 1
end

function reset_pwr_consumption()
    for i=1,14 do
        buses.pwr_consumption[i] = 0
    end
end

function update_buses()
    update_ac_1()
    update_ac_2()
    update_ac_ess()
    update_dc_1()
    update_dc_2()
    update_dc_ess()
    update_dc_bat_bus()
    update_shed()
    update_stat_inv()

    update_datarefs()
    
end
