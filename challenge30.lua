-- challenge 30

-- As required, an implementation of md4 found online

local M = 0xFFFFFFFF

local function rotl(x, n)
  return ((x << n) | (x >> (32 - n))) & M
end

-- Input: string, output: hex
local function md4(msg)
  -- Padding: 0x80, zeros to 56 mod 64, then the bit length as 64-bit little-endian
  local len = #msg
  msg = msg .. "\128" .. string.rep("\0", (55 - len) % 64)
          .. string.pack("<I8", len * 8)

  local a, b, c, d = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476

  for i = 1, #msg, 64 do
    local X = { string.unpack("<" .. string.rep("I4", 16), msg, i) }
    local aa, bb, cc, dd = a, b, c, d

    -- Round 1: F(x,y,z) = (x AND y) OR (NOT x AND z)
    local function r1(p, q, r, s, k, sh)
      return rotl((p + ((q & r) | (~q & s)) + X[k + 1]) & M, sh)
    end
    for _, k in ipairs({ 0, 4, 8, 12 }) do
      a = r1(a, b, c, d, k, 3);     d = r1(d, a, b, c, k + 1, 7)
      c = r1(c, d, a, b, k + 2, 11); b = r1(b, c, d, a, k + 3, 19)
    end

    -- Round 2: G(x,y,z) = majority, constant 0x5A827999
    local function r2(p, q, r, s, k, sh)
      return rotl((p + ((q & r) | (q & s) | (r & s)) + X[k + 1] + 0x5A827999) & M, sh)
    end
    for k = 0, 3 do
      a = r2(a, b, c, d, k, 3);     d = r2(d, a, b, c, k + 4, 5)
      c = r2(c, d, a, b, k + 8, 9); b = r2(b, c, d, a, k + 12, 13)
    end

    -- Round 3: H(x,y,z) = x XOR y XOR z, constant 0x6ED9EBA1
    local function r3(p, q, r, s, k, sh)
      return rotl((p + (q ~ r ~ s) + X[k + 1] + 0x6ED9EBA1) & M, sh)
    end
    for _, k in ipairs({ 0, 2, 1, 3 }) do
      a = r3(a, b, c, d, k, 3);     d = r3(d, a, b, c, k + 8, 9)
      c = r3(c, d, a, b, k + 4, 11); b = r3(b, c, d, a, k + 12, 15)
    end

    a, b, c, d = (a + aa) & M, (b + bb) & M, (c + cc) & M, (d + dd) & M
  end

  local digest = string.pack("<I4I4I4I4", a, b, c, d)
  return (digest:gsub(".", function(ch) return string.format("%02x", ch:byte()) end))
end

-- Padding function from len 
local function MDpadding_len(len)
	
	local pad = "\128" .. string.rep("\0", (55 - len) % 64)
          .. string.pack("<I8", len * 8)

	return pad
end 

-- Mac function
local function mac(key, mess)

	local new_inp = key .. mess
	local result = md4(new_inp)
	
	return result
end

-- Modified md4 function for the attacker
local function att_md4(msg, att_a, att_b, att_c, att_d, old_len)
  -- Padding: 0x80, zeros to 56 mod 64, then the bit length as 64-bit little-endian
  local mess_len = #msg
  local len = old_len + mess_len
  msg = msg .. "\128" .. string.rep("\0", (55 - len) % 64)
          .. string.pack("<I8", len * 8)

  local a, b, c, d = att_a, att_b, att_c, att_d

  for i = 1, #msg, 64 do
    local X = { string.unpack("<" .. string.rep("I4", 16), msg, i) }
    local aa, bb, cc, dd = a, b, c, d

    -- Round 1: F(x,y,z) = (x AND y) OR (NOT x AND z)
    local function r1(p, q, r, s, k, sh)
      return rotl((p + ((q & r) | (~q & s)) + X[k + 1]) & M, sh)
    end
    for _, k in ipairs({ 0, 4, 8, 12 }) do
      a = r1(a, b, c, d, k, 3);     d = r1(d, a, b, c, k + 1, 7)
      c = r1(c, d, a, b, k + 2, 11); b = r1(b, c, d, a, k + 3, 19)
    end

    -- Round 2: G(x,y,z) = majority, constant 0x5A827999
    local function r2(p, q, r, s, k, sh)
      return rotl((p + ((q & r) | (q & s) | (r & s)) + X[k + 1] + 0x5A827999) & M, sh)
    end
    for k = 0, 3 do
      a = r2(a, b, c, d, k, 3);     d = r2(d, a, b, c, k + 4, 5)
      c = r2(c, d, a, b, k + 8, 9); b = r2(b, c, d, a, k + 12, 13)
    end

    -- Round 3: H(x,y,z) = x XOR y XOR z, constant 0x6ED9EBA1
    local function r3(p, q, r, s, k, sh)
      return rotl((p + (q ~ r ~ s) + X[k + 1] + 0x6ED9EBA1) & M, sh)
    end
    for _, k in ipairs({ 0, 2, 1, 3 }) do
      a = r3(a, b, c, d, k, 3);     d = r3(d, a, b, c, k + 8, 9)
      c = r3(c, d, a, b, k + 4, 11); b = r3(b, c, d, a, k + 12, 15)
    end

    a, b, c, d = (a + aa) & M, (b + bb) & M, (c + cc) & M, (d + dd) & M
  end

  local digest = string.pack("<I4I4I4I4", a, b, c, d)
  return (digest:gsub(".", function(ch) return string.format("%02x", ch:byte()) end))
end

-- Attack. The server computes the key and receives the message, then it computes
-- the mac. 

local oct_key = OCTET.random(32) 
local key = oct_key:string()

local mess = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
local len_mess = #mess

local last_part = ";admin=true"

local mac1 = mac(key, mess)

-- Now the attacker divides mac1 in 4 words (in hex, as required)
-- Since they are packed with string.pack, we can use string.unpack

local mac1_bin = mac1:gsub("..", function(couple) return string.char(tonumber(couple,16)) end)
local a_att, b_att, c_att, d_att = string.unpack("<I4I4I4I4", mac1_bin)

-- Max round should be adjusted if the key length changes
for i = 1, 100 do

	-- The attacker simulates the len key
	local false_len = i + len_mess
	local false_pad = MDpadding_len(false_len)
	
	local forged_message = mess .. false_pad .. last_part
	
	-- The server compute the real mac on the message 
	local server_mac = mac(key, forged_message)
	
	local false_oldlen = #false_pad + false_len
	local att_mac = att_md4(last_part, a_att, b_att, c_att, d_att, false_oldlen)
	
	if att_mac == server_mac then
		print("key len found:", i)
		print("attacker mac is:", att_mac)
		print("server mac is", server_mac)
		break
	end
end
