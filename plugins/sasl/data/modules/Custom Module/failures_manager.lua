include('constants.lua')

local WARNING_BLINK_HZ = 4

local already_triggered_mc = false
local already_triggered_mw = false

sasl.registerCommandHandler (Failures_cancel_master_caution, 0,  function(phase) Failures_cancel_master_caution_handler(phase) end )
sasl.registerCommandHandler (Failures_cancel_master_warning, 0,  function(phase) Failures_cancel_master_warning_handler(phase) end )

function Failures_cancel_master_caution_handler(phase)
    set(MasterCaution, 0)
end

function Failures_cancel_master_warning_handler(phase)
    set(MasterWarning, 0)
    set(MasterWarningBlinking, 0)
end

function update()
    if get(ReqMasterCaution) == 1 then
        if not already_triggered_mc then
            set(MasterCaution, 1)
            already_triggered_mc = true
        end
    else
        already_triggered_mc = false
    end

    if get(ReqMasterWarning) == 1 then
        if not already_triggered_mw then
            set(MasterWarning, 1)
            already_triggered_mw = true
        end
    else
        already_triggered_mw = false
    end

    if get(MasterWarning) == 1 then
        if (math.floor(get(TIME) * WARNING_BLINK_HZ) % 2) == 0 then
            set(MasterWarningBlinking, 1)
        else
            set(MasterWarningBlinking, 0)        
        end
    end

    set(ReqMasterCaution, 0)
    set(ReqMasterWarning, 0)
end
