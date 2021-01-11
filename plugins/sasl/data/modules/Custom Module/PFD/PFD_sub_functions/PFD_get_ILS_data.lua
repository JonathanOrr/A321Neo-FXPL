function Get_ILS_data(PFD_table)
    local update_per_sec = 5
    PFD_table.NAVDATA_update_timer = PFD_table.NAVDATA_update_timer + get(DELTA_TIME)

    --collect navaid id
    PFD_table.ILS_data.Navaid_ID = sasl.findNavAid (nil, nil, get(Aircraft_lat), get(Aircraft_long), get(PFD_table.NAV_1_hz), NAV_ILS)
    PFD_table.DME_data.Navaid_ID = sasl.findNavAid (nil, nil, get(Aircraft_lat), get(Aircraft_long), get(PFD_table.NAV_1_hz), NAV_DME)

    if PFD_table.NAVDATA_update_timer >= 1 / update_per_sec then
        --update all ILS data
        PFD_table.ILS_data.NavAidType, PFD_table.ILS_data.latitude, PFD_table.ILS_data.longitude, PFD_table.ILS_data.height, PFD_table.ILS_data.frequency, PFD_table.ILS_data.heading, PFD_table.ILS_data.id, PFD_table.ILS_data.name, PFD_table.ILS_data.isInsideLoadedDSFs = sasl.getNavAidInfo(PFD_table.ILS_data.Navaid_ID)
        PFD_table.DME_data.NavAidType, PFD_table.DME_data.latitude, PFD_table.DME_data.longitude, PFD_table.DME_data.height, PFD_table.DME_data.frequency, PFD_table.DME_data.heading, PFD_table.DME_data.id, PFD_table.DME_data.name, PFD_table.DME_data.isInsideLoadedDSFs = sasl.getNavAidInfo(PFD_table.DME_data.Navaid_ID)

        --update DME distance
        if PFD_table.DME_data.latitude ~= nil and PFD_table.DME_data.longitude ~= nil then
            PFD_table.Distance_to_dme = GC_distance_kt(get(Aircraft_lat), get(Aircraft_long), PFD_table.DME_data.latitude, PFD_table.DME_data.longitude)
        end
        PFD_table.NAVDATA_update_timer = 0
    end
end