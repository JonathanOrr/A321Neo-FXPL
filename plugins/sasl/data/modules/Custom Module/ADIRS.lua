--a321neo dataref
local adirs_ir_switch_state = {} -- 0-off 1-nav 2-att
local adirs_ir_align = {} -- 0-off 1-align

local TIME_TO_ALIGN = 420 --average 420 seconds (7 min), we can do calculation based on latlon alignment delays later
local TIME_TO_ONBAT = 5 --seven seconds before onbat light extinguishes

function update ()
    set(Adirs_sys_on, 0)
    for i = 1,3 do
        if get(adirs_ir_switch_state[i]) ~= 0 then --is the ADIRS not set to OFF?
            set(Adirs_sys_on, 1) --that means the ADIRS is online.
        end
    end

    if get(Adirs_sys_on) == 1 then --ADIRS are on
        if get(adirs_time_to_align) ~= 0 then --if ADIRS are still aligning
            set(adirs_time_to_align, get(adirs_time_to_align) - get(DELTA_TIME)) --reduce their time to align
            set(adirs_time_to_onbat, get(adirs_time_to_onbat) - get(DELTA_TIME)) --reduce their time to align
        end
    else
        set(adirs_time_to_align, TIME_TO_ALIGN) --set their time to align back to max time
        set(adirs_time_to_onbat, TIME_TO_ONBAT) --set their time to align back to max time
    end

    if get(adirs_time_to_align) > 0 then
        set(adirs_align, 1)
    else
        set(adirs_align, 0)
    end
    if get(adirs_time_to_onbat) > 0 then
        set(adirs_onbat, 1)
    else
        set(adirs_onbat, 0)
    end

    --add function for linear interpolation (source: https://codea.io/talk/discussion/7448/linear-interpolation)
    function lerp(pos1, pos2, perc)
        return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
    end
--set hard values for latitudes between 60 and 70.2 and 70.2 and 78.25 and interpolate for the rest
    if get(Aircraft_lat) >= 60 and get(Aircraft_lat) < 70.2 then
        set(TIME_TO_ALIGN, 600)
    elseif get(Aircraft_lat) >= 70.2 and get(Aircraft_lat) <= 78.25 then
        set(TIME_TO_ALIGN, 1020)
    elseif get(Aircraft_lat) >= 0 and get(Aircraft_lat) < 60  then
        set(TIME_TO_ALIGN, lerp(300, 600, (get(Aircraft_lat) / 60)))
    elseif get(Aircraft_lat) <= -60 and get(Aircraft_lat) > -70.2 then
        set(TIME_TO_ALIGN, 60)
    elseif get(Aircraft_lat) <= -70.2 and get(Aircraft_lat) >= -78.25 then
        set(TIME_TO_ALIGN, 1020)
    elseif get(Aircraft_lat) < 0 and get(Aircraft_lat) > -60 then
    set(TIME_TO_ALIGN, lerp(300, 600, (get(Aircraft_lat) / -60)))
    else set(TIME_TO_ALIGN, nil)
    logInfo("Latitude is greater than 78.25- too high for IRS alignment")
    end
end
