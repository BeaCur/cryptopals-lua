-- challenge 17
-- riporto AES (cbc) ----------------------------

function randomkey()
   
	local raw_key = OCTET.random(16)
    local key = {}
    
    local key_str = raw_key:string()
    for i = 1, #key_str do
       key[i] = string.byte(key_str, i)
    end
    
    return key
end


SBOX = {
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5,
    0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0,
    0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc,
    0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a,
    0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0,
    0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b,
    0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85,
    0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5,
    0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17,
    0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88,
    0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c,
    0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9,
    0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6,
    0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e,
    0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94,
    0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68,
    0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
}

INV_SBOX = {
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38,
    0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87,
    0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d,
    0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2,
    0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16,
    0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda,
    0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a,
    0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02,
    0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea,
    0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85,
    0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89,
    0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20,
    0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31,
    0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d,
    0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0,
    0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26,
    0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
}

rcon = {0x01, 0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1B,0x36}

function xtime(myByte)
	-- controllo il bit più a sinistra
	if (myByte & 128) == 0 then
        	myByte = (myByte << 1) & 0xFF
    	elseif (myByte & 128) == 128 then
        	myByte = (myByte << 1) & 0xFF
        	myByte = myByte ~ 0x1B
    	end
	return myByte
end

function mul9(x)
    local x2 = xtime(x)
    local x4 = xtime(x2)
    local x8 = xtime(x4)
    return x8 ~ x
end

function mul11(x)
    local x2 = xtime(x)
    local x4 = xtime(x2)
    local x8 = xtime(x4)
    return x8 ~ x2 ~ x
end

function mul13(x)
    local x2 = xtime(x)
    local x4 = xtime(x2)
    local x8 = xtime(x4)
    return x8 ~ x4 ~ x
end

function mul14(x)
    local x2 = xtime(x)
    local x4 = xtime(x2)
    local x8 = xtime(x4)
    return x8 ~ x4 ~ x2
end

function mul3(x)
    return xtime(x) ~ x
end

function mul2(x)
    return xtime(x)
end

function inv_mix_column(a, b, c, d)

    local new_a = mul14(a) ~ mul11(b) ~ mul13(c) ~ mul9(d)

    local new_b = mul9(a) ~ mul14(b) ~ mul11(c) ~ mul13(d)

    local new_c = mul13(a) ~ mul9(b) ~ mul14(c) ~ mul11(d)

    local new_d = mul11(a) ~ mul13(b) ~ mul9(c) ~ mul14(d)

    return new_a, new_b, new_c, new_d
end

function mix_column(a, b, c, d)

    local new_a = mul2(a) ~ mul3(b) ~ c ~ d

    local new_b = a ~ mul2(b) ~ mul3(c) ~ d

    local new_c = a ~ b ~ mul2(c) ~ mul3(d)

    local new_d = mul3(a) ~ b ~ c ~ mul2(d)

    return new_a, new_b, new_c, new_d
end

function key_expansion(key)
	local key_exp = {}
	local rcon_index = 1
	for i =1, 16 do key_exp[i] = key[i] end
	-- ora devo ottenere la parola successiva, sono altri 4 byte
	
	for i = 17, 176, 4 do
		local temp = {key_exp[i-4], key_exp[i-3], key_exp[i-2], key_exp[i-1]}
		-- solo la prima parola ha particolari operazioni quindi
		if (i-1)%16 == 0 then
			-- faccio gia la prima rotazione
			temp = {temp[2], temp[3], temp[4], temp[1]}
			-- ora dovrei applicare la S-box (attenta a +1 dato che lua indicizza da 1)
			temp[1] = SBOX[temp[1]+1]
			temp[2] = SBOX[temp[2]+1]
			temp[3] = SBOX[temp[3]+1]
			temp[4] = SBOX[temp[4]+1]
	
			-- ora devo fare lo xor tra il primo byte di temp e i byte di rcon

			temp[1] = temp[1] ~ rcon[rcon_index]
			rcon_index = rcon_index + 1
		end

		-- ora devo fare lo xor con i byte precedenti
		key_exp[i] = key_exp[i-16] ~ temp[1]
		key_exp[i+1] = key_exp[i-15] ~ temp[2]
		key_exp[i+2] = key_exp[i-14] ~ temp[3]
		key_exp[i+3] = key_exp[i-13] ~ temp[4]
	end

	-- ora creo una tabella contenente le 11 round keys
	-- inizializzo con 0 le chiavi, dato che con la chiave in input c'è  un round diverso
	round_keys = {}
	for i = 0, 10 do
		round_keys[i] = {}
		for  j = 1, 16 do
			round_keys[i][j] = key_exp[i*16 + j]
		end 
	end 

	return round_keys
end 

-- AES decifratura
function aesDecryption(ct, round_keys)

	-- facciamo per sicurezza una copia del ct
	local state = {}
	-- memo : il blocco che ci arriva come ct è lungo 128 bit quindi 16 bytes
	for i = 1, 16 do state[i] = ct[i] end
	
	-- il round zero prende in input l'ultima chiave e la si xora semplicemente
	for i = 1, 16 do state[i] = state[i]  ~ round_keys[10][i] end

	-- ora facciamo i  successivi round, si usano le chiavi dalla 9 alla 1 (anche l'ultimo è diverso)
	for i = 9, 1, -1 do
		-- prima cosa da fare è lo shift delle righe
		-- prima riga spostata di 1 a destra ecc
		-- problema: se sposto poi si sovrascrivono le entrate diverse
		-- faccio copia ma che non si modifica...
		local temp = {}
		for j = 1, 16 do temp[j] = state[j] end 
		
		state[2], state[6], state[10], state[14] = temp[14], temp[2], temp[6], temp[10]
		state[3], state[7], state[11], state[15] = temp[11], temp[15], temp[3], temp[7]
		state[4], state[8], state[12], state[16] = temp[8], temp[12], temp[16], temp[4]

		-- adesso dovrei applicare la SBOX inv: attenta +1
		for j = 1, 16 do state[j] = INV_SBOX[state[j]+1] end

		-- ora xoro la chiave
		for j = 1, 16 do state[j] = state[j] ~ round_keys[i][j] end

		-- ora devo fare il mix delle colonne, di cui ho fatto la funzione
		for j = 1, 13, 4 do 
			state[j], state[j+1], state[j+2], state[j+3] = inv_mix_column(state[j], state[j+1], state[j+2], state[j+3])
		end
	end
	-- ora devo fare l'ultimo round con l'ultima chiave (indic con 0)
	-- faccio tutto tranne mix colonne
	
	local temp = {}
	for j = 1, 16 do temp[j] = state[j] end 
		
	state[2], state[6], state[10], state[14] = temp[14], temp[2], temp[6], temp[10]
	state[3], state[7], state[11], state[15] = temp[11], temp[15], temp[3], temp[7]
	state[4], state[8], state[12], state[16] = temp[8], temp[12], temp[16], temp[4]

	-- adesso dovrei applicare la SBOX inv: attenta +1
	for j = 1, 16 do state[j] = INV_SBOX[state[j]+1] end

	-- ora xoro la chiave
	for j = 1, 16 do state[j] = state[j] ~ round_keys[0][j] end
	
	return state
end

-- AES cifratura
function aesEncryption(pt, round_keys)

	local state = {}
	for i = 1, 16 do state[i] = pt[i] end
	
	-- 1. Round iniziale: AddRoundKey con la chiave 0
	for i = 1, 16 do state[i] = state[i] ~ round_keys[0][i] end
	
	-- 2. Round intermedi (da 1 a 9)
	for i = 1, 9 do	
		-- SubBytes
		for j = 1, 16 do state[j] = SBOX[state[j]+1] end

		-- ShiftRows (cifratura: shift a sinistra)
		local temp = {}
		for j = 1, 16 do temp[j] = state[j] end 
		state[2], state[6], state[10], state[14] = temp[6], temp[10], temp[14], temp[2]
		state[3], state[7], state[11], state[15] = temp[11], temp[15], temp[3], temp[7] 
		state[4], state[8], state[12], state[16] = temp[16], temp[4], temp[8], temp[12]
		
		-- MixColumns (presente nei primi 9 round)
		for j = 1, 13, 4 do 
			state[j], state[j+1], state[j+2], state[j+3] = mix_column(state[j], state[j+1], state[j+2], state[j+3])
		end

		-- AddRoundKey (va fatto DOPO il MixColumns)
		for j = 1, 16 do
			state[j] = state[j] ~ round_keys[i][j]
		end
	end 
	
	-- 3. Ultimo round (round 10, senza MixColumns)
	for j = 1, 16 do state[j] = SBOX[state[j]+1] end
	
	local temp = {}
	for j = 1, 16 do temp[j] = state[j] end 
	state[2], state[6], state[10], state[14] = temp[6], temp[10], temp[14], temp[2]
	state[3], state[7], state[11], state[15] = temp[11], temp[15], temp[3], temp[7] 
	state[4], state[8], state[12], state[16] = temp[16], temp[4], temp[8], temp[12]
	
	-- AddRoundKey finale con la chiave 10
	for j = 1, 16 do state[j] = state[j] ~ round_keys[10][j] end

	return state
end

-- padding (migliorato)
function paddingPKCS7(mess, block_len)

	local str_len = #mess
	local diff = block_len - (str_len % block_len)
	
	local topad = OCTET.from_number(diff)
	local byte_topad = topad:sub(16,16)
	local rep_topad = byte_topad:fillrepeat(diff)
	local result = mess .. rep_topad
	return result

end

-- aggiungo anche l'unpadding
function unpaddingPKCS7(oct_mess, block_len)

    local str = oct_mess:string()
    local len = #str
    
    if len == 0 then return oct_mess end
    
    local padding_len = string.byte(str, len)
    
	-- controllo la lunghezza
    if padding_len < 1 or padding_len > block_len then
        error("padding non valido")
    end
    
	-- controllo che i byte siano uguali al padding corretto
    for i = len, len - padding_len + 1, -1 do
        if string.byte(str, i) ~= padding_len then
            error("padding non valido")
        end
    end
    
	-- tolgo il padding
    local clean_str = string.sub(str, 1, len - padding_len)
    
    return OCTET.from_string(clean_str)
end

-- riporto da challenge 12 anche cbc

-- CBC 
-- modifichiamo la funzione in modo tale che il primo blocco
-- del messaggio in output sia ora il IV
local function cbc(pt, round_keys)
	
	-- lo riscrivo con IV randomico
	local raw_iv = OCTET.random(16)
    local iv_hex = raw_iv:hex()
	local IV = {}
    for k = 1, 32, 2 do
        local byte_str = iv_hex:sub(k, k+1)
        table.insert(IV, tonumber(byte_str, 16))
    end
    
    local toxor = {}
    for j = 1, 16 do toxor[j] = IV[j] end
	
	-- preparo il pt con padding..
	pt_pad = paddingPKCS7(pt, 16)
	
	-- aggiungo fino al for
	local pt_hex = pt_pad:hex()
    local pt_bytes = {}
    for k = 1, #pt_hex, 2 do
        local byte_str = pt_hex:sub(k, k+1)
        table.insert(pt_bytes, tonumber(byte_str, 16))
    end

	local ciphertext_chars = {}

	for i = 1, #pt_bytes, 16 do
    
		-- creo il blocco 
		local block = {}
		for j = 1, 16 do 
			block[j] = pt_bytes[i + j - 1] 
		end
		
		-- nella cifratura prima devo xorare
		local xor_block = {}
		for j = 1, 16 do
			xor_block[j] = block[j] ~ toxor[j]
		end	
	
		local output_block = aesEncryption(xor_block, round_keys)
		
		-- definisco il toxor per il prossimo round
		for j = 1, 16 do 
			toxor[j] = output_block[j] 
		end

		for j = 1, 16 do 
			table.insert(ciphertext_chars, string.format("%02x", output_block[j]))
		end
	end
	-- Modifica: aggiungo IV
	local ct_octet = OCTET.from_hex(table.concat(ciphertext_chars))
	return raw_iv .. ct_octet
end

local function cbc_decrypt(ct, round_keys)
    
	-- separo iv e ct
    local raw_iv = ct:sub(1, 16)
    local raw_ct = ct:sub(17, #ct)
    
    -- converto iv
    local iv_hex = raw_iv:hex()
    local IV = {}
    for k = 1, 32, 2 do
        local byte_str = iv_hex:sub(k, k+1)
        table.insert(IV, tonumber(byte_str, 16))
    end
    
    local toxor = {}
    for j = 1, 16 do toxor[j] = IV[j] end
    
    local ct_hex = raw_ct:hex()
    local ct_bytes = {}
    for k = 1, #ct_hex, 2 do
        local byte_str = ct_hex:sub(k, k+1)
        table.insert(ct_bytes, tonumber(byte_str, 16))
    end
    
    local plaintext_bytes_hex = {}
    
    -- ciclo sui blocchi
    for i = 1, #ct_bytes, 16 do
        
        -- blocco attuale
        local block = {}
        for j = 1, 16 do 
            block[j] = ct_bytes[i + j - 1] 
        end
        
        -- decifro blocco
        local decrypted_block = aesDecryption(block, round_keys)
        
        local plaintext_block = {}
        for j = 1, 16 do
            plaintext_block[j] = decrypted_block[j] ~ toxor[j]
        end
        
		-- definisco toxor
        for j = 1, 16 do 
            toxor[j] = block[j] 
        end
        
        for j = 1, 16 do 
            table.insert(plaintext_bytes_hex, string.format("%02x", plaintext_block[j])) 
        end
    end
    
    local pt_padded_octet = OCTET.from_hex(table.concat(plaintext_bytes_hex))

	return pt_padded_octet
end

-- riporto anche il verify pad dalla challenge 15
function verPad(mess)

	result = "true"

	-- considero l'ultimo byte del mess
	local lastb = mess:sub(#mess, #mess)
	local val = string.byte(lastb:string())

	if 1 <= val and val <= 16 then 
	
		-- controllo per pad = 1...
		if val == 1 then
			return "true"
		end
		
		for i = #mess - 1, #mess - val +1 , -1 do
			local act_byte = mess:sub(i,i)
			local act_val = string.byte(act_byte:string())

			if act_val ~= val then
				result = "false"
				break

			end
		end
		
		-- abbiamo controllato tutto quindi
		return result
	else
		result = "false"
		return result
	end
end

-- FINE AES -----------------------------------

-- CHALLENGE

-- prima creo la chiave
myKey =  randomkey()
round_keys = key_expansion(myKey)

-- faccio la tabella con le 10 stringhe base64
myTable = {
	"MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=",
	"MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=",
	"MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==",
	"MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==",
	"MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl",
	"MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==",
	"MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==",
	"MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=",
	"MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=",
	"MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93"
}

-- prima funzione
local function func1()

	-- prima scelgo che stringa considerare
	local num_str = math.random(1,10)
	local myString = myTable[num_str]

	-- ora devo paddare e cifrare con cbc ma il pad lo faccio già
	-- dentro cbc 
	local oct_myString = OCTET.from_base64(myString)
	local myCt = cbc(oct_myString, round_keys)

	return myCt
	
end

-- seconda funzione
local function func2(myCt)

	-- decifro
	local myPt = cbc_decrypt(myCt, round_keys)
	local isValid = verPad(myPt)

	return isValid

end

-- esempio

provact = func1()
print(func2(provact))

-- attacco
local function attack(ct)

	local plaintext_tot = {}

	for i = #ct - 16, 17, -16 do

		-- entrati nel for devo prendere il blocco di riferimento
		local act_block = ct:sub(i+1, i+16)
		local prev_block = ct:sub(i-16+1, i)

		-- ora li porto in byte
		local act_hex = act_block:hex()
		local prev_hex = prev_block:hex()

		local act_arr = {}
		local prev_arr = {}
		local prev_copy = {}
		local byte_found = {}

		for j = 1, #act_hex, 2 do
			local act_couple = act_hex:sub(j,j+1)
			local prev_couple = prev_hex:sub(j,j+1)
			table.insert(act_arr, tonumber(act_couple, 16))
			table.insert(prev_arr, tonumber(prev_couple, 16))
			table.insert(prev_copy, tonumber(prev_couple, 16))

		end

		-- ora che ho i miei byte inizio a lavorare...
		for pos = 16, 1, -1 do

			local act_pad = 17 - pos
			
			for m = pos+1, 16 do
				prev_arr[m] = byte_found[m]  ~ act_pad
			end

			for k = 0, 255 do

				prev_arr[pos] = k

				-- ricostruisco stringa hex da array
				local hex_tab = {}
				
				for n = 1, 16 do
					table.insert(hex_tab, string.format("%02x", prev_arr[n]))
				end 
				
				local prevmod_oct = OCTET.from_hex(table.concat(hex_tab))

				local init = ""
				if i > 16 then
				    init = ct:sub(1, i-16)
				end
				
				local ct_temp = init .. prevmod_oct .. act_block

				if func2(ct_temp) == "true" then
					local secret_byte = k  ~  act_pad
					byte_found[pos] = secret_byte

					local pt_byte = secret_byte  ~  prev_copy[pos]

					table.insert(plaintext_tot, 1, string.char(pt_byte))
					break
				end
			end
		end
	end

	return table.concat(plaintext_tot)
end

-- attacco 2
local function attack2(ct)

	local plaintext_tot = {}

	for i = #ct - 16, 16, -16 do

		-- entrati nel for devo prendere il blocco di riferimento
		local act_block = ct:sub(i+1, i+16)
		local prev_block = ct:sub(i-16+1, i)

		-- ora li porto in byte
		local act_hex = act_block:hex()
		local prev_hex = prev_block:hex()

		local act_arr = {}
		local prev_arr = {}
		local prev_copy = {}
		local byte_found = {}

		for j = 1, #act_hex, 2 do
			local act_couple = act_hex:sub(j,j+1)
			local prev_couple = prev_hex:sub(j,j+1)
			table.insert(act_arr, tonumber(act_couple, 16))
			table.insert(prev_arr, tonumber(prev_couple, 16))
			table.insert(prev_copy, tonumber(prev_couple, 16))
		end

		-- ora che ho i miei byte inizio a lavorare...
		for pos = 16, 1, -1 do

			local act_pad = 17 - pos

			for k = 0, 255 do

				-- copio l'array per evitare problemi con i tentativi
				for n = 1, 16 do
					prev_arr[n] = prev_copy[n]
				end

				for m = pos+1, 16 do
					prev_arr[m] = byte_found[m]  ~ act_pad
				end

				prev_arr[pos] = k

				-- ricostruisco stringa hex da array
				local hex_tab = {}
				
				for n = 1, 16 do
					table.insert(hex_tab, string.format("%02x", prev_arr[n]))
				end 
				
				local prevmod_oct = OCTET.from_hex(table.concat(hex_tab))

				local init = ""
				if i > 16 then
				    init = ct:sub(1, i-16)
				end
				local ct_temp = init .. prevmod_oct .. act_block

				if func2(ct_temp) == "true" then
				
				    if pos == 16 then
				        -- verifico che il padding sia davvero 01
				        local test_arr = {}
				        for n = 1,16 do
				            test_arr[n] = prev_arr[n]
				        end
				
				        -- modifico il byte precedente a quello appena trovato
				        test_arr[15] = test_arr[15] ~ 1
				
				        local test_hex = {}
				        for n = 1,16 do
				            table.insert(test_hex, string.format("%02x", test_arr[n]))
				        end
				
				        local test_prev_oct = OCTET.from_hex(table.concat(test_hex))
				        local test_ct = init .. test_prev_oct .. act_block
				
				        if func2(test_ct) == "true" then
				            --print("ho trovato pos =", pos, "k =", k)
				
				            local secret_byte = k ~ act_pad
				            byte_found[pos] = secret_byte
				            local pt_byte = secret_byte ~ prev_copy[pos]
				            table.insert(plaintext_tot, 1, string.char(pt_byte))
				            break
				        end
				    else
				        local secret_byte = k ~ act_pad
				        byte_found[pos] = secret_byte
				        local pt_byte = secret_byte ~ prev_copy[pos]
				        table.insert(plaintext_tot, 1, string.char(pt_byte))
				        break
				    end
				
				end
			end
		end
	end

	return table.concat(plaintext_tot)
end



local myCt = func1()
local myPt = attack2(myCt)
print("messaggio trovato: ", myPt)
