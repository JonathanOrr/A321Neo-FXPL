function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk then
        logInfo ( " String downloaded ! " )
        logInfo ( inUrl )
        logInfo ( inString )
    else
        logInfo ( inUrl )
        logWarning ( inError )
    end
end

function fetch_atis(airport, callback)
    if string.len == 4 then
        sasl.net.downloadFileContentsAsync ( "http://metar.vatsim.net/metar.php?id="..string.upper(airport), callback )
    end
end


    
