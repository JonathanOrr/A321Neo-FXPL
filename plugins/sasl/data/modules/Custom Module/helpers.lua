local bit = require("bit")

function protect(tbl)
  return setmetatable({}, {
    __index = tbl,
    __newindex = function(t, key, value)
        error("attempting to change constant " ..
               tostring(key) .. " to " .. tostring(value), 2)
  end
})
end

CONST = {
    AUTO_BUTTON_STATE = 1,
    OFF_BUTTON_STATE = 0,
    ON_BUTTON_STATE = 1,
    ON_DATAREF_STATE = 1,
    OFF_DATAREF_STATE = 0,
    AUTO_DATAREF_STATE = 1,
    BOTTOM_BIT = 1,
    UPPER_BIT = 2
}
CONST = protect(CONST)


-- number ^= 1UL << n;
function flipBitValue(value, bitNumber)
  return bit.bxor(1, bit.lshift(value, bitNumber - 1))
end

-- number = (number & ~(1UL << n)) | (x << n);
function setBitValue(value, bitNumber, setValue)
  return bit.bor(bit.band(value, bit.bnot(bit.lshift(1, bitNumber - 1))), bit.lshift(setValue, bitNumber - 1))
end

--#define BIT_CHECK(a,b) (!!((a) & (1ULL<<(b))))        // '!!' to make sure this returns 0 or 1
function checkBitValue(value, bitNumber, checkValue)
  return bit.band(value, bit.lshift(1, bitNumber - 1)) == checkValue
end

--
function datarefIsOn(df)
  return get(df) == CONST.ON_DATAREF_STATE
end


function datarefIsAuto(df)
  return get(df) == CONST.AUTO_DATAREF_STATE
end


function datarefIsOnBit(df, bitNumber )
  return checkBitValue(get(df), bitNumber,CONST.ON_DATAREF_STATE)
end


function datarefIsOffBit(df, bitNumber)
  return checkBitValue(get(df), bitNumber, CONST.OFF_DATAREF_STATE)
end


function datarefIsOff(df)
  return get(df) == CONST.OFF_DATAREF_STATE
end


function datarefSetOn(df)
  datarefSetValue(df, CONST.ON_DATAREF_STATE)
end


function datarefSetOff(df)
  datarefSetValue(df, CONST.OFF_DATAREF_STATE)
end

function datarefSetBitValue(df, bitNumber, setValue)
  set(df, setBitValue(get(df), bitNumber, setValue))
end


function datarefSetValue(df, value)
  set(df, value)
end


function datarefFlip(df)
  set(df, flipBitValue(get(df), 1))
end
