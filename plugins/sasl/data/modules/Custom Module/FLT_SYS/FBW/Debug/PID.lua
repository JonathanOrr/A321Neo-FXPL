local test_tbl = {
    x = 0,
    y = 0,
    w = 700,
    h = 500,
    xlim = 5, --in seconds
    ylim = {-5, 5},
    xbars = {1, 2, 3, 4},
    ybars = nil,
    data = {},
    dt = {},
}

local function Grapher_update(tbl, data_tble)
    if get(DELTA_TIME) == 0 then return end

    --sum the elapsed time
    local time = 0
    local dt_to_del = 0
    for i = 1, #tbl.dt do
        if time > tbl.xlim then
            dt_to_del = #tbl.dt - i
            break
        else
            time = time + tbl.dt[i]
        end
    end

    --initialize or add to value history
    for key, val in pairs(data_tble) do
        if not tbl.data[key] then
            tbl.data[key] = {
                color = val.color,
                graph = val.graph,
                number = val.number,
                value = {
                    val.value
                },
            }
        else
            for i = 1, dt_to_del do
                table.remove(tbl.data[key].value, 1)
            end

            table.insert(tbl.data[key].value, val.value)
        end
    end

    --process dt table
    for i = 1, dt_to_del do
        table.remove(tbl.dt, 1)
    end

    table.insert(tbl.dt, get(DELTA_TIME))
end


local function Grapher_draw_function(tbl, funcs)
    sasl.gl.setClipArea(tbl.x, tbl.y, tbl.w, tbl.h)

    local txt_drawn = 0
    for key, val in pairs(funcs) do
        for i = 1, val.sample do
            local x = Math_rescale(1, val.dom[1], val.sample, val.dom[2], i)
            local x_next = Math_rescale(1, val.dom[1], val.sample, val.dom[2], i + 1)
            local y = val.func(x)
            local y_next = val.func(x_next)

            sasl.gl.drawLine(
                Math_rescale_no_lim(val.dom[1],  tbl.x,  val.dom[2], tbl.x + tbl.w, x),
                Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, y),
                Math_rescale_no_lim(val.dom[1],  tbl.x,  val.dom[2], tbl.x + tbl.w, x_next),
                Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, y_next),
                val.color
            )
        end

        sasl.gl.drawText(Font_B612MONO_regular, tbl.x + tbl.w - 5, tbl.y + tbl.h - 15 - 15 * txt_drawn, key, 12, false, false, TEXT_ALIGN_RIGHT, val.color)
        txt_drawn = txt_drawn + 1
    end

    sasl.gl.resetClipArea()
end


local function Grapher_draw(tbl)
    sasl.gl.setClipArea(tbl.x, tbl.y, tbl.w, tbl.h)
    sasl.gl.drawRectangle(tbl.x, tbl.y, tbl.w, tbl.h, UI_DARK_GREY)

    --darw background
    sasl.gl.drawLine(
        0,
        Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, 0),
        tbl.x + tbl.w,
        Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, 0),
        ECAM_GREY
    )

    if tbl.xbars then
        for key, val in pairs(tbl.xbars) do
            sasl.gl.drawLine(Math_rescale(0, tbl.x, tbl.xlim, tbl.x + tbl.w, val), tbl.y, Math_rescale(0, tbl.x, tbl.xlim, tbl.x + tbl.w, val), tbl.y + tbl.h, ECAM_GREY)
        end
    end

    if tbl.ybars then
        for key, val in pairs(tbl.ybars) do
            sasl.gl.drawLine(tbl.x, Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val), tbl.x + tbl.w, Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val), ECAM_GREY)
        end
    end

    --draw data lins
    local txt_drawn = 0
    for key, val in pairs(tbl.data) do
        local time = 0
        for i = 1, #tbl.dt - 1 do
            if val.graph then
                sasl.gl.drawLine(
                    Math_rescale_no_lim(0,           tbl.x,    tbl.xlim, tbl.x + tbl.w,             time),
                    Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h,     val.value[i]),
                    Math_rescale_no_lim(0,           tbl.x,    tbl.xlim, tbl.x + tbl.w, time + tbl.dt[i]),
                    Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val.value[i + 1]),
                    val.color
                )
            end

            time = time + tbl.dt[i]

            if i == #tbl.dt - 1 then
                local txt = key
                if val.number then
                    txt = txt .. ": " .. Round_fill(val.value[#val.value], 4)
                end

                sasl.gl.drawText(Font_B612MONO_regular, tbl.x + 5, tbl.y + tbl.h - 15 - 15 * txt_drawn, txt, 12, false, false, TEXT_ALIGN_LEFT, val.color)
                txt_drawn = txt_drawn + 1
            end
        end
    end

    sasl.gl.resetClipArea()
end

function update()
    if not FBW_PID_debug_window:isVisible() then return end

    Grapher_update(test_tbl, {
        NX = {graph = true, number = true, color = ECAM_RED, value = FBW.vertical.dynamics.Path_Load_Factor("x")},
        NY = {graph = true, number = true, color = ECAM_GREEN, value = FBW.vertical.dynamics.Path_Load_Factor("y")},
        NZ = {graph = true, number = true, color = ECAM_BLUE, value = FBW.vertical.dynamics.Path_Load_Factor("z")},
    })
end

function draw()
    Grapher_draw(test_tbl)
    Grapher_draw_function(test_tbl, {
        --sin = {color = ECAM_MAGENTA, func = function(x) return math.sin(math.rad(x)) end, dom = {-180, 180}, sample = 50},
    })
end