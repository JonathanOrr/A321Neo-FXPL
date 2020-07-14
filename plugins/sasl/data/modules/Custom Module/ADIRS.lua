--a321neo dataref
local adirs_ir_switch_state = {} -- 0-off 1-nav 2-att
local adirs_ir_align = {} -- 0-off 1-align

local adirs_on_bat = createGlobalPropertyi("a321neo/cockpit/adris/onbat", 0, false, true, false)
local adirs_sys_on = createGlobalPropertyi("a321neo/cockpit/adris/adirs", 0, false, true, false)
local adirs_time_to_align = createGlobalPropertyf("a321neo/cockpit/adris/timetoalign", 0, false, true, false)

for i = 1,3 do
  adirs_ir_switch_state[i] = createGlobalPropertyi("a321neo/cockpit/adris/ir" .. i .. "_switch_state", 0, false, true, false)
  adirs_ir_align[i] = createGlobalPropertyi("a321neo/cockpit/adris/ir" .. i .. "_align", 0, false, true, false)
end

local TIME_TO_ALIGN = 420 --average 420 seconds (7 min), we can do calculation based on latlon alignment delays later

function update ()
    set(adirs_sys_on, 0)
    for i = 1,3 do
        if get(adirs_ir_switch_state[i]) ~= 0 then --is the ADIRS not set to OFF?
            set(adirs_sys_on, 1) --that means the ADIRS is online.
        end
    end

    if get(adirs_sys_on) == 1 then --ADIRS are on
        if get(adirs_time_to_align) ~= 0 then --if ADIRS are still aligning
            set(adirs_time_to_align, get(adirs_time_to_align) - DELTA_TIME) --reduce their time to align
        end
    else
        set(adirs_time_to_align, TIME_TO_ALIGN) --set their time to align back to max time
    end
end
