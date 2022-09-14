addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/SLAT_FLAP")

FCTL.SLAT_FLAP = {}

components = {
    SLAT_FLAP_AUG  {},
    SLAT_FLAP_STAT {},
    SLAT_FLAP_CTL  {},
}

function update()
    updateAll(components)
end