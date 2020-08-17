--ALL COMMANDS USED IN THE COCKPIT, e.g PUSHBUTTONS--

-- Buttons with light (check cockpit_datarefs.lua for light datarefs):
Ecam_btn_cmd_ENG   = createCommand("a321neo/cockpit/ecam/buttons/cmd_eng", "ENG pushbutton")
Ecam_btn_cmd_BLEED = createCommand("a321neo/cockpit/ecam/buttons/cmd_bleed", "BLEED pushbutton")
Ecam_btn_cmd_PRESS = createCommand("a321neo/cockpit/ecam/buttons/cmd_press", "PRESS pushbutton")
Ecam_btn_cmd_ELEC  = createCommand("a321neo/cockpit/ecam/buttons/cmd_elec", "ELEC pushbutton")
Ecam_btn_cmd_HYD   = createCommand("a321neo/cockpit/ecam/buttons/cmd_hyd", "HYD pushbutton")
Ecam_btn_cmd_FUEL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fuel", "FUEL pushbutton")
Ecam_btn_cmd_APU   = createCommand("a321neo/cockpit/ecam/buttons/cmd_apu", "APU pushbutton")
Ecam_btn_cmd_COND  = createCommand("a321neo/cockpit/ecam/buttons/cmd_cond", "COND pushbutton")
Ecam_btn_cmd_DOOR  = createCommand("a321neo/cockpit/ecam/buttons/cmd_door", "DOOR pushbutton")
Ecam_btn_cmd_WHEEL = createCommand("a321neo/cockpit/ecam/buttons/cmd_wheel", "WHEEL pushbutton")
Ecam_btn_cmd_FCTL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fctl", "FCTL pushbutton")
Ecam_btn_cmd_CLR   = createCommand("a321neo/cockpit/ecam/buttons/cmd_clr", "CLR pushbutton")
Ecam_btn_cmd_STS   = createCommand("a321neo/cockpit/ecam/buttons/cmd_sts", "STS pushbutton")

-- No light buttons:
Ecam_btn_cmd_TOCFG = createCommand("a321neo/cockpit/ecam/buttons/cmd_toconfig", "T.O CONFIG pushbutton")
Ecam_btn_cmd_EMERC = createCommand("a321neo/cockpit/ecam/buttons/cmd_emercanc", "EMER CANC pushbutton")
Ecam_btn_cmd_ALL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_all", "ALL pushbutton")
Ecam_btn_cmd_RCL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_rcl", "RCL pushbutton")

--aircond
Cockpit_temp_dial_up = createCommand("a321neo/cockpit/aircond/cockpit_temp_dial_up", "Cockpit temp dial up")
Cockpit_temp_dial_dn = createCommand("a321neo/cockpit/aircond/cockpit_temp_dial_dn", "Cockpit temp dial down")
Front_cab_temp_dial_up = createCommand("a321neo/cockpit/aircond/front_cab_temp_dial_up", "Front cab temp dia up")
Front_cab_temp_dial_dn = createCommand("a321neo/cockpit/aircond/front_cab_temp_dial_dn", "Front cab temp dial down")
Aft_cab_temp_dial_up = createCommand("a321neo/cockpit/aircond/aft_cab_temp_dial_up", "Aft cab temp dial up")
Aft_cab_temp_dial_dn = createCommand("a321neo/cockpit/aircond/aft_cab_temp_dial_dn", "Aft cab temp dial down")
Aft_cargo_temp_dial_up = createCommand("a321neo/cockpit/aircond/aft_cargo_temp_dial_up", "Aft cargo temp dial up")
Aft_cargo_temp_dial_dn = createCommand("a321neo/cockpit/aircond/aft_cargo_temp_dial_dn", "Aft cargo temp dial down")

--packs & bleed
Pack_flow_dial_up = createCommand("a321neo/cockpit/packs/pack_flow_dial_up", "Pack flow dial up")
Pack_flow_dial_dn = createCommand("a321neo/cockpit/packs/pack_flow_dial_dn", "Pack flow dial down")
X_bleed_dial_up = createCommand("a321neo/cockpit/packs/x_bleed_dial_up", "x bleed dial up")
X_bleed_dial_dn = createCommand("a321neo/cockpit/packs/x_bleed_dial_dn", "x bleed dial down")