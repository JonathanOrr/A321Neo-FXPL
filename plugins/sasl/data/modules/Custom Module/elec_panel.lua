-- READ
local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on")

-- WRITE
-- BITS: 1 bit for bottom part of the button, 2 bit is the upper part of the bottom
-- local ext_pwr_button = globalProperty("a321neo/electrical/ext_pwr_button")
local ext_pwr_button = createGlobalPropertyi("a321neo/electrical/ext_pwr_button", 0, false, true, true)

-- CMD
local command_ext_pwr_button_toggle = createCommand("a321neo/electrical/ext_pwr_button_toggle", "Toggle EXT PWR")


function on_command_ext_pwr_button_toggle (phase)
  if phase == SASL_COMMAND_BEGIN
  then
    -- flip the button ON bit
    -- setting the view dataref
    set(ext_pwr_button, flipBitValue(get(ext_pwr_button), 1))
  end
end


function update_ext_pwr_button()
  set(ext_pwr_button, setBitValue(get(ext_pwr_button), 2, get(ext_pwr_on)))
end

function update()
  update_ext_pwr_button()
end

sasl.registerCommandHandler(command_ext_pwr_button_toggle, 0, on_command_ext_pwr_button_toggle)
