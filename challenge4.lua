-- challenge4

-- legge i dati 
local raw_data = KEYS or DATA or ""
local myArray = {}

-- divide il testo riga per riga
for line in raw_data:gmatch("[^\r\n]+") do
    local clean = line:gsub("%s+", "")
    if #clean > 0 then
        table.insert(myArray, clean)
    end
end

-- tabella frequenze
freq = {
    [' '] = 13, ['e'] = 12, ['t'] = 9, ['a'] = 8, ['o'] = 8,
    ['i'] = 7,  ['n'] = 7,  ['s'] = 6, ['h'] = 5, ['r'] = 4
}

-- funzione per calcolare il punteggio 
function score(mess, k)
	
	local act_score = 0
	-- porto in byte
	for i = 1, #mess do
		local b = mess:byte(i)
	-- a ogni byte sommo la chiave
		local sum = b ~ k
	-- trasformo il byte in carattere
		local char = string.char(sum):lower()
		
		if freq[char] then
			act_score = act_score + freq[char]
		elseif sum < 32 or sum > 126 then 
			act_score = act_score -10
		end 
	end
	
	return act_score
	
end 

besttotal_score = -10000 
besttotal_k = 0
best_string = 0
string_number = 0

for j = 1, #myArray do
	
	-- prendo la stringa attuale
	act_string = myArray[j]
	-- in ottetto
	myMess_octet = OCTET.from_hex(act_string)
	-- in stringa 
	myMess_str = myMess_octet:string()
	
	best_score = -10000
	best_k = 0
	
	for k = 0, 255 do
		myScore = score(myMess_str, k)
		if myScore > best_score then 
			best_score = myScore
			best_k = k
		end
	end 
	
	if best_score > besttotal_score then
		besttotal_score = best_score
		besttotal_k = best_k
		best_string = act_string
		string_number = j
	end
end 
		
-- ora dovrei avere la mia stringa migliore
-- e la k con cui è stata xorata... quindi faccio
-- come prima 
myMess_octet = OCTET.from_hex(best_string)
single_byte = OCTET.from_number(besttotal_k):sub(16, 16)
message = single_byte:fillrepeat(#myMess_octet)
octetPlaintext = myMess_octet ~ message
plaintext = octetPlaintext:string()


print(besttotal_k)
print(plaintext)
print(string_number)
