# General information
Components can be powered by AC or DC voltage. Usually a component is powered by
AC or DC, but not both (some exceptions exist, like adirs). Most all the components are
connected to buses and NOT directly to batteries/generators/etc. 

## List of buses
Each of the following datarefs has only two state: 0 - OFF, 1 - Powered. They are affected by switches, faults, etc.

| Bus name    | Type | Is powered?  (Dataref)                              | Note                                                                          |
|-------------|------|-----------------------------------------------------|-------------------------------------------------------------------------------|
| HOT 1       | DC   | a321neo/dynamics/electrical/bus/hot_1_powered       | Directly connected to BAT 1. Battery switch does not affect this bus.         |
| HOT 2       | DC   | a321neo/dynamics/electrical/bus/hot_2_powered       | Directly connected to BAT 2. Battery switch does not affect this bus.         |
| DC 1        | DC   | a321neo/dynamics/electrical/bus/dc_1_powered        |                                                                               |
| DC 2        | DC   | a321neo/dynamics/electrical/bus/dc_2_powered        |                                                                               |
| DC ESS      | DC   | a321neo/dynamics/electrical/bus/dc_ess_powered      |                                                                               |
| DC ESS SHED | DC   | a321neo/dynamics/electrical/bus/dc_ess_shed_powered | Part of the DC ESS bus that can be powered off under some failure conditions. |
| DC BAT      | DC   | a321neo/dynamics/electrical/bus/dc_bat_powered      | Battery interconnection bus. This is not necessarily powered.                 |
| AC 1        | AC   | a321neo/dynamics/electrical/bus/ac_1_powered        |                                                                               |
| AC 2        | AC   | a321neo/dynamics/electrical/bus/ac_2_powered        |                                                                               |
| AC ESS      | AC   | a321neo/dynamics/electrical/bus/ac_ess_powered      |                                                                               |
| AC ESS SHED | AC   | a321neo/dynamics/electrical/bus/ac_ess_shed_powered | Part of the AC ESS bus that can be powered off under some failure conditions. |
| Galley      | AC   | a321neo/dynamics/electrical/bus/galley_powered      | Main and secondary galley, in-seat power supply.                              |
| Commercial  | AC   | a321neo/dynamics/electrical/bus/commercial_powered  | Cabin and cargo lights, toilets, entertainment, etc.                          |

To each bus is also assigned a numerical id and a constant in `constants.lua` file:

| Bus name    | Constant name        | Constant Value |
|-------------|----------------------|----------------|
| HOT 1       | ELEC_BUS_HOT_BUS_1   | 10             |
| HOT 2       | ELEC_BUS_HOT_BUS_2   | 11             |
| DC 1        | ELEC_BUS_DC_1        | 5              |
| DC 2        | ELEC_BUS_DC_2        | 6              |
| DC ESS      | ELEC_BUS_DC_ESS      | 7              |
| DC ESS SHED | ELEC_BUS_DC_ESS_SHED | 8              |
| DC BAT      | ELEC_BUS_DC_BAT_BUS  | 9              |
| AC 1        | ELEC_BUS_AC_1        | 1              |
| AC 2        | ELEC_BUS_AC_2        | 2              |
| AC ESS      | ELEC_BUS_AC_ESS      | 3              |
| AC ESS SHED | ELEC_BUS_AC_ESS_SHED | 4              |
| Galley      | ELEC_BUS_GALLEY      | 12             |
| Commercial  | ELEC_BUS_COMMERCIAL  | 13             |

## List of generators and other devices
Each of the following datarefs has only two state: 0 - OFF, 1 - Powered. They are affected by switches, faults, etc. DO NOT use this datarefs for checking if a component (not belonging to elec system) is powered or not, use the previous datarefs!

| Bus name | Type     | Is powered?  (Dataref)                           | Note                      |
|----------|----------|--------------------------------------------------|---------------------------|
| GEN 1    | AC       | a321neo/dynamics/electrical/sources/gen_1_pwr    | Engine 1 generator        |
| GEN 2    | AC       | a321neo/dynamics/electrical/sources/gen_2_pwr    | Engine 2 generator        |
| GEN APU  | AC       | a321neo/dynamics/electrical/sources/gen_APU_pwr  | APU generator             |
| GEN EXT  | AC       | a321neo/dynamics/electrical/sources/gen_EXT_pwr  | External power supply     |
| GEN EMER | AC       | a321neo/dynamics/electrical/sources/gen_EMER_pwr | RAT generator             |
| TR 1     | AC -> DC | a321neo/dynamics/electrical/trs/tr_1_online      | Transformer Rectifier 1   |
| TR 2     | AC -> DC | a321neo/dynamics/electrical/trs/tr_2_online      | Transformer Rectifier 2   |
| TR ESS   | AC -> DC | a321neo/dynamics/electrical/trs/tr_ess_online    | Transformer Rectifier ESS |
| ST.INV   | DC -> AC | a321neo/dynamics/electrical/trs/INV_online       | Static Inverter           |


# How to connect a component

When you create a component in lua, you probably want to connect it to the power supply. To do that, you have to perform two actions:
1. Check if the bus related to the component is powered up (by using the datarefs)
2. Assign the power consumption to the bus (by using a specific function, see later)
You usually want to check at the beggining of the `update()` function, but this is not mandatory. Power consumption must be updated at every call of update().

To add the power consumption use this global function:

  `ELEC_sys.add_power_consumption(bus, min_amps, max_amps)`

where `bus` is one of the constant of the previous table on bus constants, and `min_amps`/`max_amps` are the minimum/maximum currents (elec logic will randomly select a value in this range. If you want it to be constnat, just use the same value for min and max).

If you have the power consumption in watt, remember the power formula: `Current [A] = Power [Watt] / Voltage [V]`. So, pay attention if the bus is a DC bus (Voltage=28V) o AC bus (Voltage=115V) to compute the current. 

### Example 1: Single bus

```lua
function update()
    if get(AC_ess_bus_pwrd) == 0 then
        return -- Bus is not powered on, this component cannot work
    end
    -- Otherwise, it is ON and it is consuming 3A
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 3, 3)
    
    -- You component code here...
    
end
```

### Example 2: Primary bus + Failover bus
```lua
function update()
    if get(AC_1_bus_pwrd) == 0 and get(DC_ESS_bus_pwrd) == 0 then
        return -- Both buses are not powered on, this component cannot work
    end
    -- Otherwise, it is ON and it is consuming ~30 W (this means 30/28=1.07A in DC and 30/115=0.26A in AC)
    if get(AC_1_bus_pwrd) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.26, 0.26)
    else
        ELEC_sys.add_power_consumption(ELEC_BUS_DC_ESS, 1.07, 1.07)
    end
    
    -- You component code here...

end
```
