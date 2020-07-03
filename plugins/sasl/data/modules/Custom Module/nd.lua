-- size = { 190, 190 }
size = { 190, 190 }

defineProperty("alt_hold", globalPropertyf("sim/cockpit2/autopilot/altitude_dial_ft"))          --We get the altitude to hold
defineProperty("altitude", globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")) --We get the altiltude we are now


local font1=sasl.gl.loadFont("fonts/B612Mono-Regular.ttf") -- from now on (in this script) we use the font1 to tell what font we want to use. Of course we can use multiple fonts and name them as we like
clRed = {1.0, 0.0, 0.0, 1.0}
clAirbusMain= { 0, 0.125, 0.357}


function draw()
  sasl.gl.drawRectangle(0, 0, 190 , 190 , clAirbusMain)
  sasl.gl.drawText(font1,0,0, "ND", 24, false, false, TEXT_ALIGN_LEFT, clRed)
end
