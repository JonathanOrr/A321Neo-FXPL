local pitch  = 	        globalProperty("sim/flightmodel/position/true_theta")
local roll  = 	        globalProperty("sim/flightmodel/position/true_phi")
local airspeed =        globalProperty("sim/flightmodel/position/indicated_airspeed2")
local altitude =        globalProperty("sim/flightmodel/misc/h_ind2")
local weight   =        globalProperty ("sim/flightmodel/weight/m_total")
local thrust = 0

local vs     =          globalProperty("sim/flightmodel/position/vh_ind_fpm")

---------------------------------------------
local magic_happening = false

local function save_to_file()
    file = io.open("jon_dont_open.csv", "a")
    file:write(get(pitch)..","..get(roll)..","..get(airspeed)..","..get(altitude)..","..get(weight)..","..thrust..","..get(vs).."\n")
    file:flush()
    file:close()
end

function status_indicator()
    if not magic_happening then
        sasl.gl.drawText ( Airbus_panel_font , 150 , 37 , "DO SOME MAGIC" , 25 , false , false , TEXT_ALIGN_CENTER , EFB_BLACK)
    else
        sasl.gl.drawText ( Airbus_panel_font , 150 , 37, "STOP THE MAGIC" , 25 , false , false , TEXT_ALIGN_CENTER , EFB_BLACK)
    end
end

function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        magic_happening = not magic_happening
    end
end

function update()
    thrust = get(Eng_1_N1)
    --print(get(pitch),get(roll),get(airspeed),get(weight),thrust)
    --print(magic_happening)
    if magic_happening then
        save_to_file()
    end
end

function draw()
    sasl.gl.drawRectangle ( 20 , 20 , 260 , 60 , EFB_WHITE )
    status_indicator()
end