----------------------------------------------------------------------------------------------------
-- Miscellanea related to graphics
----------------------------------------------------------------------------------------------------

local guards = {
    {name = "IDG1"},             -- This creates a command and dataref with the same name, both `a321neo/cockpit/overhead/guards/IDG1`
    {name = "IDG2"},
    {name = "CARGO_DISCH_1"},
    {name = "CARGO_DISCH_2"},
    {name = "MASK_MAN_ON"},
    {name = "ELEC_RAT_MAN_ON"},
    {name = "EMER_GEN_TEST"},
    {name = "RAM_AIR"},
    {name = "DICTHING"},
    {name = "ENG_MAN_START_1"},
    {name = "ENG_MAN_START_2"},
    {name = "CALLS_EMER"},
    {name = "EVAC_COMMAND"},
    {name = "HYD_RAT_MAN_ON"},
    {name = "HYD_BLUE_PUMP"},
    {name = "HIGH_ALT_LANDING"},
    {name = "EMER"}

}

----------------------------------------------------------------------------------------------------
-- Command function
----------------------------------------------------------------------------------------------------
function guard_click_handler(phase, object)
    if phase == SASL_COMMAND_BEGIN then
        set(object.dataref, 1 - get(object.dataref))
    end
end

----------------------------------------------------------------------------------------------------
-- Initialization function
----------------------------------------------------------------------------------------------------
local function create_drs(object)
    object.dataref = createGlobalPropertyi("a321neo/cockpit/overhead/guards/" .. object.name, 0, false, true, false)
    object.command = createCommand("a321neo/cockpit/overhead/guards/" .. object.name, "GUARD - " .. object.name .. " pushbutton")
    sasl.registerCommandHandler (object.command, 0,  function(phase) guard_click_handler(phase, object); return 1 end )
end

local function init_drs(array)
    for i,x in ipairs(guards) do
        create_drs(x)
    end
end

init_drs(guards)


