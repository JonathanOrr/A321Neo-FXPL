local bit = require("bit")

-- number ^= 1UL << n;
function bit_toggle(value, bitNumber)
  return bit.bxor(1, bit.lshift(value, bitNumber - 1))
end

-- number = (number & ~(1UL << n)) | (x << n);
function bit_set_to_value(value, bitNumber, setValue)
  return bit.bor(bit.band(value, bit.bnot(bit.lshift(1, bitNumber - 1))), bit.lshift(setValue, bitNumber - 1))
end
