-- challenge 3

local hex_message = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

-- converto in byte
local bytes = {}
for i = 1, #hex_message, 2 do
    local hex_pair = hex_message:sub(i, i + 1)
    table.insert(bytes, tonumber(hex_pair, 16))
end

-- tabella frequenze
local freq = {
    [' '] = 13, ['e'] = 12, ['t'] = 9, ['a'] = 8, ['o'] = 8,
    ['i'] = 7,  ['n'] = 7,  ['s'] = 6, ['h'] = 5, ['r'] = 4,
    ['d'] = 3,  ['l'] = 2,  ['u'] = 2
}

-- funzione che calcola punteggio
local function score_bytes(byte_array, key)

    local total_score = 0
    for i, b in ipairs(byte_array) do
	
        local xor_byte = (b ~ key)
        local char = string.char(xor_byte):lower()
        
        if freq[char] then
            total_score = total_score + freq[char]
        elseif xor_byte < 32 or xor_byte > 126 then
            -- caratteri non stampabili
            total_score = total_score - 10
        end
    end
    return total_score
end

local best_score = -9999
local best_k = 0

-- cerco la chiave
for k = 0, 255 do
    local s = score_bytes(bytes, k)
    if s > best_score then
        best_score = s
        best_k = k
    end
end

-- decodifico con chiave trovata
local decrypted = {}
for i, b in ipairs(bytes) do
    table.insert(decrypted, string.char(b ~ best_k))
end

print("chiave trovata:", best_k)
print("chiave in stringa:", string.char(best_k))
print("messaggio:", table.concat(decrypted))
	
