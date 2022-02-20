--THIS FUNCTION NEEDS A CUSTOM CALLBACK, READ SASL MANUAL!
function fetch_metar(airport, callback)
    sasl.net.setDownloadTimeout (SASL_TIMEOUT_CONNECTION , 3 )
    if string.len(airport) == 4 then
        sasl.net.downloadFileContentsAsync ( "http://metar.vatsim.net/metar.php?id="..string.upper(airport), callback )
    end
end


    
