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
-- File: clock.lua 
-- Short description: Clock & Chronometer instrument
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------------------------

include('constants.lua')

position= {470,1632,200,244}
size = {200, 244}
local SevenSegment = sasl.gl.loadFont("fonts/Segment7Standard.otf")

local CHRONO_STATE_RST = 2
local CHRONO_STATE_STP = 1
local CHRONO_STATE_RUN = 0
local CHRONO_SOURCE_SET = 2
local CHRONO_SOURCE_INT = 1
local CHRONO_SOURCE_GPS = 0



-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local chrono_state  = CHRONO_STATE_STP
local chrono_source = CHRONO_SOURCE_GPS

local et_time = 0 -- Elapsed time in seconds

-------------------------------------------------------------------------------
-- Commands & Handlers
-------------------------------------------------------------------------------

sasl.registerCommandHandler (Chrono_cmd_state_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_state = math.max(0,chrono_state-1) end end )
sasl.registerCommandHandler (Chrono_cmd_state_up, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then
        chrono_state = math.min(2,chrono_state+1)
    elseif phase == SASL_COMMAND_END and chrono_state == 2 then
        chrono_state = 1
    end
end )
sasl.registerCommandHandler (Chrono_cmd_source_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_source = math.max(0,chrono_source-1) end end )
sasl.registerCommandHandler (Chrono_cmd_source_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_source = math.min(2,chrono_source+1) end end )

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function update_anim()
    Set_dataref_linear_anim(Chrono_state_button, chrono_state, 0, 2, 5)
    Set_dataref_linear_anim(Chrono_source_button, chrono_source, 0, 2, 5)
end

function update_et()
    if chrono_state == CHRONO_STATE_RUN then
        et_time = et_time + get(DELTA_TIME)
    elseif chrono_state == CHRONO_STATE_RST then
        et_time = 0
    end
end

function update()
    update_anim()
    update_et()
end

function draw() 

    if get(DC_ess_bus_pwrd) == 0 then
        return
    end

    if et_time > 0 then
        local minutes = math.floor(et_time / 60) % 60
        local hours   = math.floor(et_time / 3600) % 60
        if minutes < 10 then minutes = "0" .. minutes end
        if hours < 10   then hours   = "0" .. hours end
        sasl.gl.drawText(SevenSegment, 62, 24, hours, 46, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(SevenSegment, 120, 24, minutes, 46, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, 91, 31, ":", 35, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
    sasl.gl.drawText(SevenSegment, 91, 184, "8888", 46, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(SevenSegment, 68, 102, "8888", 46, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(SevenSegment, 147, 105, "88", 36, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

end
