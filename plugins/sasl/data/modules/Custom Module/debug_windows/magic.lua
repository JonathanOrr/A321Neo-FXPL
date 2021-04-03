
include("networking/json.lua")

---------------------------------------------

local test_json = '[1,2,3,{"x":10}]'

function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk then
        logInfo ( " String downloaded ! " )
        x = json.decode(inString)

        print(x["fetch"]["userid"])

    else
        logInfo ( inUrl )
        logWarning ( inError )
    end
end


function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        print("hello")
        sasl.net.downloadFileContentsAsync ( "https://www.simbrief.com/api/xml.fetcher.php?username=KuChingWo&json=1" ,onContentsDownloaded)

    end
end

function update()
end

function draw()
    sasl.gl.drawRectangle ( 20 , 20 , 260 , 60 , EFB_WHITE )
end





