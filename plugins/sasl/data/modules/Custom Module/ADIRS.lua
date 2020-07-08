--a321neo dataref
local adirs_ir_switch_state = {} -- 0-off 1-nav 2-att
local adirs_ir_align = {} -- 0-off 1-align

local adirs_on_bat = createGlobalPropertyi("a321neo/cockpit/adris/onbat", 0, false, true, false)

for i,3 do
  adirs_ir_switch_state[i] = createGlobalPropertyi("a321neo/cockpit/adris/ir" .. i .. "_switch_state", 0, false, true, false)
  adirs_ir_align[i] = createGlobalPropertyi("a321neo/cockpit/adris/ir" .. i .. "_align", 0, false, true, false)
end
