LED7Seg = {}


--creates a 7 seg LED object. the segments spin clockwise from the top as A to G in the center, and lastly the decimal point
--the datarefs for show and hide will be as follows:
--drPrefix/digit1 ... -> ... digitn/A ... -> ... drPrefix/digit1 ... -> ... digitn/dp
--drPrefix/decimal1 ... -> ... decimaln/A ... -> ... drPrefix/decimal1 ... -> ... decimaln/dp
function LED7Seg:new(o, drPrefix, digits, decimals)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.digits = digits
    self.decimals = decimals or 0

    local segs = { "A", "B", "C", "D", "E", "F", "G", "dp" }

    self.digitsDR = {}
    self.decimalsDR = {}

    for digit = 1, digits do
        self.digitsDR[digit] = {}
        for _, suffix in pairs(segs) do
            self.digitsDR[digit][suffix] = createGlobalPropertyi(drPrefix .. "/digit" .. digit .. "/" .. suffix, 0, false,
                true, false)
        end
    end

    for decimal = 1, decimals do
        self.decimalsDR[decimal] = {}
        for _, suffix in pairs(segs) do
            self.decimalsDR[decimal][suffix] = createGlobalPropertyi(drPrefix .. "/decimal" .. decimal .. "/" .. suffix,
                0, false, true, false)
        end
    end

    return o
end

--clear the display to blank
function LED7Seg:clear()
    -- reset to blank
    for _, digit in pairs(self.digitsDR) do
        for _, segment in pairs(digit) do
            set(segment, 0)
        end
    end
    for _, decimal in pairs(self.decimalsDR) do
        for _, segment in pairs(decimal) do
            set(segment, 0)
        end
    end
end

--use the segments to show a number (clear the display first)
function LED7Seg:display(number)
    local NUMSEGS = {
        [0] = {
            "A", "B", "C", "D", "E", "F",
        },
        [1] = {
            "A", "B", "C",
        },
        [2] = {
            "A", "B", "D", "E", "G",
        },
        [3] = {
            "A", "B", "C", "D", "G",
        },
        [4] = {
            "B", "C", "F", "G",
        },
        [5] = {
            "A", "C", "D", "F", "G",
        },
        [6] = {
            "A", "C", "D", "E", "F", "G",
        },
        [7] = {
            "A", "B", "C",
        },
        [8] = {
            "A", "B", "C", "D", "E", "F", "G"
        },
        [9] = {
            "A", "B", "C", "D", "F", "G",
        },
    }

    -- show digits
    for digit = 1, self.digits do
        for _, segment in pairs(NUMSEGS[math.floor(number / (10 ^ (digit - 1))) % 10]) do
            set(self.digitsDR[digit][segment], 1)
        end
    end

    -- show decimals
    if self.decimals <= 0 then
        return
    end

    set(self.digitsDR[1]["dp"], 1)
    for decimal = 1, self.decimals do
        for _, segment in pairs(NUMSEGS[math.floor((number * (10 ^ decimal))) % 10]) do
            set(self.decimalsDR[decimal][segment], 1)
        end
    end
end
