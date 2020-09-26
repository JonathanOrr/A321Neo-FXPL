local snd_master_warning = sasl.al.loadSample("sounds/master_warning.wav")



function update()

    if get(MasterWarning) == 1 and not sasl.al.isSamplePlaying(snd_master_warning) then
        sasl.al.playSample(snd_master_warning, true)
    end
    if get(MasterWarning) == 0 and sasl.al.isSamplePlaying(snd_master_warning) then
        sasl.al.stopSample(snd_master_warning)
    end

end
