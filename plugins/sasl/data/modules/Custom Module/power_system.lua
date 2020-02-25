
local apu_running = createGlobalPropertyi("a321neo/power/apu_running", 0, false, true, true)
local eng1_running = createGlobalPropertyi("a321neo/power/eng1_running", 0, false, true, true)
local eng2_running = createGlobalPropertyi("a321neo/power/eng2_running", 0, false, true, true)

-- Simple start and stop for APU and ENG 1 and ENG 2
sasl.registerCommandHandler(createCommand("a321neo/power/apu_start", "Start APU"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOn(apu_running) end
end)

sasl.registerCommandHandler(createCommand("a321neo/power/eng1_start", "Start ENG 1"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOn(eng1_running) end
end)

sasl.registerCommandHandler(createCommand("a321neo/power/eng2_start", "Start ENG 2"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOn(eng2_running) end
end)

sasl.registerCommandHandler(createCommand("a321neo/power/apu_stop", "Stop APU"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOff(apu_running) end
end)

sasl.registerCommandHandler(createCommand("a321neo/power/eng1_cutoff", "Cutoff ENG 1"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOff(eng1_running) end
end)

sasl.registerCommandHandler(createCommand("a321neo/power/eng2_cutoff", "Cutoff ENG 2"), 0, function(phase)
  if phase == SASL_COMMAND_BEGIN then datarefSetOff(eng2_running) end
end)
