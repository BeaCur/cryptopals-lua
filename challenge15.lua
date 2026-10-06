-- challenge 15

function paddingPKCS7(mess, block_len)

	local str_len = #mess
	local diff = block_len - (str_len % block_len)
	
	local topad = OCTET.from_number(diff)
	local byte_topad = topad:sub(16,16)
	local rep_topad = byte_topad:fillrepeat(diff)
	local result = mess .. rep_topad
	return result

end


-- ok ora devo fare la funzione di verifica
-- INPUT= OTTETTO (perchè il padding butta fuori ottetti)
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


-- vediamo esempio
local myString = "ice ice baby"
local msOct = OCTET.from_string(myString)
local pad_cor = paddingPKCS7(msOct, 16)

--verifica
print(verPad(pad_cor))

-- provo con pad sbagliato
local wrong_pad1 = OCTET.from_hex("05050505")
local wrong_mess1 = msOct .. wrong_pad1
print(verPad(wrong_mess1))

local wrong_pad2 = OCTET.from_hex("01020304")
local wrong_mess2 = msOct .. wrong_pad2
print(verPad(wrong_mess2))

print("secondo esempio")
-- ulteriore prova
local string2 = "CryptoPals_Challenge_15_Done!"
local msOct2 = OCTET.from_string(string2)
local pad_cor2 = paddingPKCS7(msOct2, 16)
print(verPad(pad_cor2))

-- pad sbagliato
local pad_fasullo = OCTET.from_hex("000003") 
local sbagliato = string2 .. pad_fasullo
print(verPad(sbagliato))
