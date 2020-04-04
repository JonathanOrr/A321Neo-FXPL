--sim datarefs
local elev_trim_ratio = globalProperty("sim/cockpit2/controls/elevator_trim")
local max_elev_trim_up = globalProperty("sim/aircraft/controls/acf_hstb_trim_up")
local max_elev_trim_dn = globalProperty("sim/aircraft/controls/acf_hstb_trim_dn")

--a321neo datarefs
local elev_trim_degrees = createGlobalPropertyf("a321neo/cockpit/controls/elevator_trim_degrees", 0, false, true, false)


--custom functions
function get_elev_trim_degrees()
    if get(elev_trim_ratio) == 0 then
        return 0
    elseif get(elev_trim_ratio) > 0 then
        return get(elev_trim_ratio) * get(max_elev_trim_up)
        elseif get(elev_trim_ratio) < 0 then
            return get(elev_trim_ratio) * get(max_elev_trim_dn)
        end
end

--init
set(elev_trim_degrees, 0)

function update()
    --sync and identify the elevator trim degrees
    set(elev_trim_degrees, get_elev_trim_degrees())
end