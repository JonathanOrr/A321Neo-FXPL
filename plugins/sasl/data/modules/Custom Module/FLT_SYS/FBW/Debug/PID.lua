local test_tbl = {
    xlim = 5, --in seconds
    ylim = 20,
    xbars = 5,
    ybars = nil,
    data = {},
    dt = {},
}

local function Grapher_update(tbl, data_tble)
    if get(DELTA_TIME) == 0 then return end

    --sum the elapsed time
    local time = 0
    for i = 1, #tbl.dt do
        time = time + tbl.dt[i]
    end

    --initialize or add to value history
    for key, val in pairs(data_tble) do
        if not tbl.data[key] then
            tbl.data[key] = {
                color = val.color,
                value = {
                    val.value
                },
            }
        else
            if time > tbl.xlim then
                table.remove(tbl.data[key].value, 1)
            end

            table.insert(tbl.data[key].value, val.value)
        end
    end

    --process dt table
    if time > tbl.xlim then
        table.remove(tbl.dt, 1)
    end

    table.insert(tbl.dt, get(DELTA_TIME))
end

local function Grapher_draw(tbl, x, y, w, h)
    for key, val in pairs(tbl.data) do
        local xscale = w / tbl.xlim
        local yscale = h / tbl.ylim

        local time = 0
        for i = 1, #tbl.dt - 1 do
            sasl.gl.drawLine(
                x + time * xscale,
                y + val.value[i] * yscale,
                x + (time + tbl.dt[i]) * xscale,
                y + val.value[i + 1] * yscale,
                val.color
            )

            time = time + tbl.dt[i]
        end
    end
end

local function hypo_r()
    local mcos = function (x) return math.cos(math.rad(x)) end
    local msin = function (x) return math.sin(math.rad(x)) end

    local nz = get(Total_vertical_g_load)--mcos(get(Vpath)) / mcos(get(Flightmodel_roll))

    local r = (get(Weather_g) / get(TAS_ms)) * (nz * msin(get(Flightmodel_roll)) * mcos(get(Flightmodel_roll)) * mcos(get(Vpath)))
    return (r / math.pi) * 180
end

local function alt_hypo_r()
    local mcos = function (x) return math.cos(math.rad(x)) end
    local msin = function (x) return math.sin(math.rad(x)) end

    local nz = get(Total_vertical_g_load)--mcos(get(Vpath)) / mcos(get(Flightmodel_roll))

    local r = (get(Weather_g) / get(TAS_ms)) * (nz * msin(get(Flightmodel_roll)) * mcos(get(Flightmodel_roll)))
    return (r / math.pi) * 180
end

function update()
    Grapher_update(test_tbl, {
        Q  = {color = ECAM_BLUE,  value = get(Flightmodel_r_deg)},
        hypo_r = {color = ECAM_GREEN, value = hypo_r()},
        alt_hypo_r = {color = ECAM_ORANGE, value = alt_hypo_r()},
    })
end

function draw()
    Grapher_draw(test_tbl, 0, 250, 700, 500)
end