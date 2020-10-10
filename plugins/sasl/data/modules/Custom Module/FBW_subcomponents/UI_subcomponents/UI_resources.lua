--colors
RED = {1, 0, 0}
ORANGE = {1, 0.55, 0.15}
WHITE = {1.0, 1.0, 1.0}
GREEN = {0.20, 0.98, 0.20}
LIGHT_BLUE = {0, 0.708, 1}
LIGHT_GREY = {0.2039, 0.2235, 0.247}
DARK_GREY = {0.1568, 0.1803, 0.2039}

--fonts
B612_regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
B612_bold = sasl.gl.loadFont("fonts/B612-Bold.ttf")
B612_MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
B612_MONO_bold = sasl.gl.loadFont("fonts/B612Mono-Bold.ttf")

--load textures
Aircraft_behind_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fbw_ui/ui_plane_behind.png")
Aircraft_side_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/fbw_ui/ui_right side.png")