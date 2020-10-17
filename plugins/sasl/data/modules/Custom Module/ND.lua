position = {37, 410, 900, 900}
size = {900, 900}

include('constants.lua')

function draw()

    --sasl.gl.drawFrame(0, 0, 385, 380, {1,0,1})
    --sasl.gl.drawText(B612MONO_regular, 50, 50, "TEST", 10, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    if get(AC_ess_shed_pwrd) == 0 then   -- TODO This should be fixed when screens move around
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 0.26, 0.26)   -- 30W (just hypothesis)


end
