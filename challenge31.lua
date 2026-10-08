-- challenge 31

-- sha1 from challenge 28

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

-- input: key and mess as octet
blockSize = 64

-- input: key - OCTET
-- output key - OCTET
local function computeBlockSizedKey(key)

	local key_len = #key
	if key_len > blockSize then
		key = sha1(key)
	elseif key_len < blockSize then 
		return key .. OCTET.zero(blockSize - key_len)
	end 
	
	return key
end 

opad1 = OCTET.from_hex("5c")
ipad1 = OCTET.from_hex("36")
opad_block = opad1:fillrepeat(64)
ipad_block = ipad1:fillrepeat(64)
-- input: key, mess - octet
local function hmac(key, mess)
	
	local block_sized_key = computeBlockSizedKey(key)
	
	local o_key_pad = block_sized_key:xor_grow(opad_block)
	local i_key_pad = block_sized_key:xor_grow(ipad_block)
	
	local hash1 = sha1( i_key_pad .. mess)
	local result = sha1( o_key_pad .. hash1)
	
	return result
	
end 

-- Compare signature with delay 
local function insecure_compare(sign1, sign2)
	
	local arr_sign1 = sign1:array()
	local arr_sign2 = sign2:array()
	
	local result = 200
	
	for i = 1, 20 do 
		
		if arr_sign1[i] == arr_sign2[i] then 
			local start_time = os.clock()
			while (os.clock() - start_time) < 0.05 do end
		else 
			result = 500
			return result
		end
	end 
	
	return result
	
end 

local str_mess = "message"
local mess = OCTET.from_string(str_mess)

-- key length as to be at least 20 byte
local server_key = OCTET.random(20)

local att_sign = OCTET.zero(20)
local att_sign_arr = att_sign:array()

local server_sign = hmac(server_key, mess)
print("Correct signature:", server_sign:hex())

-- The attacker tries all possible values for each byte and keeps the 
-- one that takes the server longest to verify
for i = 1, 20 do

	local best_time = 0
	local best_j = 0
	
	for j = 0, 255 do
		att_sign_arr[i] = j  
				
		local att_sign = byte_toOctet(att_sign_arr)
		
		local start_time = os.clock()

		local isValid = insecure_compare(att_sign, server_sign)
		
		local interval = os.clock() - start_time
		
		if interval > best_time then
			best_time = interval
			best_j = j
		end 
	end
	
	att_sign_arr[i] = best_j
end

att_sign = byte_toOctet(att_sign_arr)
print("Attacker signature:", att_sign:hex())
