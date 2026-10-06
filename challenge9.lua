-- challenge 9
-- funzione padding

function paddingPKCS7(str, block_len)
	
	-- porto la stringa in ottetto
	local oct_str = OCTET.from_string(str)
	local str_len = #oct_str
	local diff = block_len - (str_len % block_len)
	--print("ho trovato diff", diff)
	
	local topad = OCTET.from_number(diff)
	local byte_topad = topad:sub(16,16)
	local rep_topad = byte_topad:fillrepeat(diff)
	local result = oct_str .. rep_topad
	return result
	
end
		
		
myString = "yellow submarine"
prova = paddingPKCS7(myString, 20)
print(prova:hex())
