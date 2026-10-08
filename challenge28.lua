-- challenge 28 

-- As required, find a sha1 IMPLEMENTATION

local sha1 = {}

function byte_toOctet(byte_array)

	local hex = ""
	for i=1, #byte_array do
		hex = hex .. string.format("%02x", byte_array[i] % 256)
	end
	
	return OCTET.from_hex(hex)
end 

-- 32-bit left bitwise rotation on numbers
local function wrotate(x, n)
    return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF
end

-- SHA-1 compression function working on a 64-byte text block
local function sha1_feed_block(H, block, W)
    -- Break the 64-byte block into sixteen 32-bit big-endian words
    for i = 0, 15 do
        local pos = i * 4 + 1
        W[i] = (string.byte(block, pos) << 24) |
               (string.byte(block, pos + 1) << 16) |
               (string.byte(block, pos + 2) << 8) |
               (string.byte(block, pos + 3))
    end

    -- Expand the sixteen 32-bit words into eighty words
    for i = 16, 79 do
        W[i] = wrotate(W[i-3] ~ W[i-8] ~ W[i-14] ~ W[i-16], 1)
    end

    -- Hash values for this iteration
    local a, b, c, d, e = H[1], H[2], H[3], H[4], H[5]

    -- Main loop
    for i = 0, 79 do
        local f, k
        if i <= 19 then
            f = (b & c) | ((~b) & d)
            k = 0x5A827999
        elseif i <= 39 then
            f = b ~ c ~ d
            k = 0x6ED9EBA1
        elseif i <= 59 then
            f = (b & c) | (b & d) | (c & d)
            k = 0x8F1BBCDC
        else
            f = b ~ c ~ d
            k = 0xCA62C1D6
        end

        local temp = (wrotate(a, 5) + f + e + k + W[i]) & 0xFFFFFFFF
        e = d
        d = c
        c = wrotate(b, 30)
        b = a
        a = temp
    end

    -- Add this block's hash to the cumulative state
    H[1] = (H[1] + a) & 0xFFFFFFFF
    H[2] = (H[2] + b) & 0xFFFFFFFF
    H[3] = (H[3] + c) & 0xFFFFFFFF
    H[4] = (H[4] + d) & 0xFFFFFFFF
    H[5] = (H[5] + e) & 0xFFFFFFFF
end

-- SHA1, input and output are octet
function sha1(msg_octet)

    local H = { 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0 }
    local W = {}

    local len = #msg_octet
    local bits_len = len * 8

    -- Append the bit 1 (byte 0x80)
    local padding_start = OCTET.from_hex("80")
    local padded_msg = msg_octet .. padding_start

    -- Compute the number of zero bytes needed to reach 56 bytes mod 64
    local current_mod = #padded_msg:string() % 64
    local pad_len = (56 - current_mod) % 64
    
    local zero_padding = OCTET.zero(pad_len)
    padded_msg = padded_msg .. zero_padding

    -- Append the 64-bit big-endian representation of the original length (
	local raw_len_octet = OCTET.from_number(bits_len)
    local len_octet = raw_len_octet:sub(9, 16)
    padded_msg = padded_msg .. len_octet

    -- Divide the message in 64-byte blocks
    local padded_str = padded_msg:string()
    for i = 1, #padded_str, 64 do
        sha1_feed_block(H, string.sub(padded_str, i, i + 63), W)
    end

    -- Convert the final 5 state registers into a 20-byte array
    local final_bytes = {
        (H[1] >> 24) & 0xFF, (H[1] >> 16) & 0xFF, (H[1] >> 8) & 0xFF, H[1] & 0xFF,
        (H[2] >> 24) & 0xFF, (H[2] >> 16) & 0xFF, (H[2] >> 8) & 0xFF, H[2] & 0xFF,
        (H[3] >> 24) & 0xFF, (H[3] >> 16) & 0xFF, (H[3] >> 8) & 0xFF, H[3] & 0xFF,
        (H[4] >> 24) & 0xFF, (H[4] >> 16) & 0xFF, (H[4] >> 8) & 0xFF, H[4] & 0xFF,
        (H[5] >> 24) & 0xFF, (H[5] >> 16) & 0xFF, (H[5] >> 8) & 0xFF, H[5] & 0xFF
    }

    return byte_toOctet(final_bytes)
end

-- challenge

-- Write a function that applies sha1 to key || message
-- the input are both octet
-- the output is a mac (octet)
local function mac(key, mess)

	local new_inp = key .. mess
	local result = sha1(new_inp)
	
	return result
end

-- If the message is tampered, the MAC is broken

local myKey = OCTET.random(16)
local mess1 = "Hi everyone"
local mess2 = "Ha everyone" -- only 1 error

local oct1 = OCTET.from_string(mess1)
local oct2 = OCTET.from_string(mess2)

local mac1 = mac(myKey, oct1)
local mac2 = mac(myKey, oct2)

-- Here we can see they are very different
print("First mac:", mac1:hex())
print("Second mac:", mac2:hex())

-- If an attacker doesn't know the key:
local att_key = OCTET.random(16)

local att_mac = mac(att_key, mess1)

print("Correct mac:", mac1:hex())
print("Attacker mac:", att_mac:hex())
