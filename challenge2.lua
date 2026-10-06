-- challenge 2
local string1 = "1c0111001f010100061a024b53535009181c"

local string2 = "686974207468652062756c6c277320657965"

local octet1 = OCTET.from_hex(string1)
local octet2 = OCTET.from_hex(string2)

local result = octet1:__bxor(octet2)

print("risultato in hex:", result:hex())

