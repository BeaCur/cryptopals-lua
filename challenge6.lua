-- challenge 6
-- tabella frequenze
freq = {
    [' '] = 13, ['e'] = 12, ['t'] = 9, ['a'] = 8, ['o'] = 8,
    ['i'] = 7,  ['n'] = 7,  ['s'] = 6, ['h'] = 5, ['r'] = 4
}

-- riporto funzione challenge 4
function score(mess, k)
    local act_score = 0
    for i = 1, #mess do
        local b = mess:byte(i)
        local sum = b ~ k
        local char = string.char(sum):lower()
        
        if freq[char] then
            act_score = act_score + freq[char]
        elseif sum < 32 or sum > 126 then 
            act_score = act_score - 10
        end 
    end
    return act_score
end  

-- distanza di hamming tra stringhe
function hammDistance(string1, string2)
   
   local dist = 0
   
    for i = 1, #string1 do
        local b1 = string1:byte(i)
        local b2 = string2:byte(i)
        local x = b1 ~ b2
        while x > 0 do
            dist = dist + (x & 1)
            x = x >> 1
        end
    end
    return dist
end

-- prova
print("esempio:", hammDistance("this is a test", "wokka wokka!!!"))

-- leggo file
local raw_data = KEYS or DATA or ""
local base64_clean = raw_data:gsub("%s+", "")
myMess_str = OCTET.from_base64(base64_clean):string()
myMess = OCTET.from_base64(base64_clean)
print("Lunghezza di myMess_str:", #myMess_str)

-- cerco la key size
local results = {}
for i = 2, 40 do
	-- numero che può variare. con 12 ottengo risultato
    local blocks_to_test = 12
	
	-- verifico se ho abbastanza caratteri
    if (blocks_to_test * i) <= #myMess_str then
        local total_dist = 0
        local count = 0
        
		-- confronto blocchi consecutivi
        for b = 1, blocks_to_test - 1, 2 do
            local start1 = ((b - 1) * i) + 1
            local end1 = b * i
            local start2 = end1 + 1
            local end2 = (b + 1) * i
            
            local s1 = myMess_str:sub(start1, end1)
            local s2 = myMess_str:sub(start2, end2)
            
			-- distanza tra i due blocchi + aggiungo al totale
            total_dist = total_dist + hammDistance(s1, s2)
            count = count + 1
        end
        
		-- trovo la distanza media + salvo
        if count > 0 then
            local norm_dist = (total_dist / count) / i
            table.insert(results, { size = i, score = norm_dist })
        end
    end
end

table.sort(results, function(a, b) return a.score < b.score end)
keySize = results[1].size
print("ho trovato la keysize:", keySize)


-- provo a estrarre la chiave
local key_table = {}

for i = 1, keySize do
    local strTable = {}
    for pos = i, #myMess_str, keySize do
        table.insert(strTable, myMess_str:sub(pos, pos))
    end 
    
    local act_string = table.concat(strTable)
    local best_score = -10000 
    local best_k = 0
    
    for k = 0, 255 do
        local myScore = score(act_string, k)
        if myScore > best_score then 
            best_score = myScore
            best_k = k
        end
    end 
    
    table.insert(key_table, string.char(best_k))
end

chiave = table.concat(key_table)
print("chiave in stringa:", chiave)

-- provo a cifrare
local plaintext_chars = {}
local key_len = #chiave

for i = 1, #myMess_str do
    local c_byte = myMess_str:byte(i)
    local k_byte = chiave:byte(((i - 1) % key_len) + 1)
    local decrypted_byte = c_byte ~ k_byte
    table.insert(plaintext_chars, string.char(decrypted_byte))
end

plaintext = table.concat(plaintext_chars)

print("messaggio cifrato", plaintext)
