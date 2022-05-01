function AOC_fetch_atis(airport, callback)
    sasl.net.setDownloadTimeout (SASL_TIMEOUT_CONNECTION , 3 )
    sasl.net.downloadFileContentsAsync ( "https://www.hoppie.nl/acars/system/connect.html?logon=dJuAfJpNLXdh&from=HKK&type=infoReq&to=SERVER&packet=vatatis+"..airport, 
    function(url, contents, isOk, error)   AOC_atis_req_callback(url, contents, isOk, error, airport) end )
end