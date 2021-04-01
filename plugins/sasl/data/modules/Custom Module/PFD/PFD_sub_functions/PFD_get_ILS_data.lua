include('libs/geo-helpers.lua')
include('DRAIMS/radio_logic.lua')

function Get_ILS_data(PFD_table)
    local update_per_sec = 10
    PFD_table.NAVDATA_update_timer = PFD_table.NAVDATA_update_timer + get(DELTA_TIME)

    if PFD_table.NAVDATA_update_timer >= 1 / update_per_sec then
        local is_ils_valid = radio_ils_is_valid()
        PFD_table.ILS_data.is_valid = is_ils_valid
        if is_ils_valid then
            PFD_table.ILS_data.frequency = radio_ils_get_freq()
            PFD_table.ILS_data.course    = radio_ils_get_crs()
            PFD_table.ILS_data.id        = DRAIMS_common.radio.ils.id
            PFD_table.ILS_data.gs_is_valid = radio_ils_is_valid() and radio_gs_is_valid()
            PFD_table.ILS_data.loc_is_valid= radio_ils_is_valid() and radio_loc_is_valid()

            PFD_table.ILS_data.gs_deviation = -radio_get_ils_deviation_v()
            PFD_table.ILS_data.loc_deviation= radio_get_ils_deviation_h()
        end
        local is_dme_valid = radio_ils_is_dme_valid()
        PFD_table.DME_data.is_valid = is_dme_valid
        if is_dme_valid then
            PFD_table.DME_data.value = radio_ils_get_dme_value()
        end
    end

end
