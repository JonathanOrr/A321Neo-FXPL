function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk and string.len(inString) > 0 then
        --logInfo ( " String downloaded ! " )
        --logInfo ( inUrl )
        --logInfo ( inString )
        set(EFB_metar_string, inString)
    else
        set(EFB_metar_string, "Error: Could not obtain valid METAR report for the entered airport.")
    end
end

function fetch_atis(airport, callback)
    sasl.net.setDownloadTimeout (SASL_TIMEOUT_CONNECTION , 3 )
    if string.len(airport) == 4 then
        sasl.net.downloadFileContentsAsync ( "http://metar.vatsim.net/metar.php?id="..string.upper(airport), callback )
    end
    --print("http://metar.vatsim.net/metar.php?id="..string.upper(airport))
end


    
