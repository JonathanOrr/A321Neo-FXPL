-- READ
local ext_pwr_on = globalProperty("a321neo/electrical/ext_pwr_on", 0)

--  WRITE
local ext_pwr_button = createGlobalPropertyi("a321neo/electrical/ext_pwr_button", 0)

-- CMD
local command_ext_pwr_button_toggle = createCommand("a321neo/electrical/ext_pwr_button_toggle", "Toggle EXT PWR")


--  BITS: 0 bit for bottom part of the button, 1 bit is the upper part of the bottom
function on_command_ext_pwr_button_toggle (phase)
  if phase == SASL_COMMAND_BEGIN
  then
    local ext_pwr_button_value = get(ext_pwr_button)

    -- toggle the button ON bit
    -- ext_pwr_button_value = bit.lshift(bit.bxor(ext_pwr_button_value, 1), 0)
    ext_pwr_button_value = bit.bxor(1, bit.lshift(ext_pwr_button_value, 0))

      -- setting the view dataref
    set(ext_pwr_button, ext_pwr_button_value)
  end
end


function update_ext_pwr_button()
  local ext_pwr_on_value = get(ext_pwr_on)
  local ext_pwr_button_value = get(ext_pwr_button)

  -- set the button AVAIL bit
  -- number = (number & ~(1UL << n)) | (x << n);
  ext_pwr_button_value =  bit.bor(bit.band(ext_pwr_button_value, bit.bnot(bit.lshift(1, 1))), bit.lshift(ext_pwr_on_value, 1))

  -- setting the view dataref
  set(ext_pwr_button, ext_pwr_button_value)
end

function update()
  update_ext_pwr_button()
end





















sasl.registerCommandHandler(command_ext_pwr_button_toggle, 0, on_command_ext_pwr_button_toggle)
