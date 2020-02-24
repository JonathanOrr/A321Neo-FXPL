local bit = require("bit")

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
  return get(df) == 1
end


function datarefIsOnBit(df, bitNumber )
  return checkBitValue(get(df), bitNumber, 1)
end


function datarefIsOffBit(df, bitNumber)
  return checkBitValue(get(df), bitNumber, 0)
end


function datarefIsOff(df)
  return get(df) == 0
end


function datarefSetOn(df)
  return set(df, 1)
end


function datarefSetOff(df)
  return set(df, 0)
end


function datarefFlip(df)
  set(df, flipBitValue(get(df), 1))
end
