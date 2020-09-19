size = {900, 900}
include('constants.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function update_draw_datarefs()
    set(Ecam_elec_bat_1_status, ELEC_sys.batteries[1].switch_status and 1 or 0)
    set(Ecam_elec_bat_2_status, ELEC_sys.batteries[2].switch_status and 1 or 0)

    local is_tr_ess_activable = get(TR_1_online) == 0 and get(TR_2_online) == 0 and get(INV_online) == 0
    set(Ecam_elec_tr_ess_status, (ELEC_sys.trs[3].status and 1 or ( is_tr_ess_activable and 2 or 0 )))

    if ELEC_sys.generators[3].source_status == false then
        set(Ecam_elec_apu_gen_status, 0)
    elseif ELEC_sys.generators[3].switch_status == false then
        set(Ecam_elec_apu_gen_status, 1)
    elseif ELEC_sys.generators[3].curr_voltage > 105 and ELEC_sys.generators[3].curr_hz > 385 then
        set(Ecam_elec_apu_gen_status, 2)
    else
        set(Ecam_elec_apu_gen_status, 2)    
    end

   if ELEC_sys.generators[5].source_status == false then
        set(Ecam_elec_rat_status, 0)
    elseif ELEC_sys.generators[5].curr_voltage > 105 and ELEC_sys.generators[5].curr_hz > 385 then
        set(Ecam_elec_rat_status, 1)
    else
        set(Ecam_elec_rat_status, 2)
    end

end

function draw_elec_page()

    update_draw_datarefs()
end
