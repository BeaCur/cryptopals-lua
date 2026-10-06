-- challenge24

-- riprendo da challenge precedenti
n = 624
m = 397
w = 32
r = 31
WMASK = 0xffffffff
UMASK = 0x80000000
LMASK = 0x7fffffff
-- facendo la maschera con WMASK otteniamo solo i primi 32 bit
-- definisco direttamente queste maschere
UMASK = 0x80000000
LMASK = 0x7fffffff
a = 0x9908b0df
u = 11
s = 7
t = 15
l = 18
b = 0x9d2c5680
c = 0xefc60000
f = 1812433253

-- seed suggeriti
--mySeed = 5489
mySeed = 19650218

-- devo fare una funzione che generi lo state
local function mt_state()
	-- diamo i nomi come lo pseudocode di wiki
	-- attenzione: in C gli indici vanno da 0 in poi, quindi qui andrebbe 1
	local state = {state_array = {}, state_index = 1}
	return state
end 

-- funzione che inizializza lo state
local function initialize_state(mtState, seed)

	-- la prima riga della func in C non ci serve
	-- pongo il primo elemento del state array come seed
	local myArray = mtState["state_array"]
	-- attenzione a prendere solo i primi 32 bit
	-- funziona anche senza maschere
	myArray[1] = seed --& WMASK

	
	-- ciclo
	for i = 2, n do
		-- modifico: aggiungo maschera
		local prev_seed = myArray[i-1] --& WMASK
		-- anche qui faccio attenzione a i...
		-- modifico per aggiungere maschera
		local shifted = (prev_seed >> (w-2)) --& WMASK
		local diff = (prev_seed ~ shifted) --& WMASK
		myArray[i] = (f * diff + (i-1)) --& WMASK
	end
	
	-- rimetto a 1 index
	mtState["state_index"] = 1
	
end 	

-- funzione generazione numero
local function random_uint32(mtState)

	local myArray = mtState["state_array"]
	local k = mtState["state_index"]

	-- definisco j
	local j = k - (n-1)
	-- attenzione 1 non 0
	if j < 1 then
		j = j + n
	end 

	-- la prossima riga in C è
	-- uint32_t x = (state_array[k] & UMASK) | (state_array[j] & LMASK);
	-- aggiungo maschere...
	local val_k = myArray[k] --& WMASK
	local val_j = myArray[j] --& WMASK
	local x = ((val_k & UMASK) | (val_j & LMASK)) --& WMASK

	-- anche qui aggiungo maschera
	local xA = (x >> 1) --& WMASK
	if (x & 0x00000001) ~= 0 then
		xA = xA ~ a
	end 

	-- definisco di nuovo j
	j = k - (n-m)
	if j < 1 then
		j = j+n
	end

	-- riprendo x
	-- aggiungo maschera
	x = (myArray[j] ~ xA) --& WMASK
	myArray[k] = x
	k = k+1

	-- qua metto solo maggiore e metto dentro 1 non 0
	if k > n then
		k = 1
	end
	mtState["state_index"] = k

	-- metto anche qui un po' di maschere
	local y = x ~ ( (x >> u) & WMASK)
	y = y ~ ((y << s) & b)
	y = y ~ ((y << t) & c)
	local z = y ~ ((y >> l) & WMASK)
	return z & WMASK

end 

local function octet_toByte(oct)

    local arr = {}
    local str = oct:string()

    for i = 1, #str do
        arr[i] = string.byte(str, i)
    end

    return arr
end

function byte_toOctet(byte_array)

    local hex_parts = {}
    for i = 1, #byte_array do
		-- byte in hex
        hex_parts[i] = string.format("%02x", byte_array[i])
    end

    local hex_string = table.concat(hex_parts)
    
    return OCTET.from_hex(hex_string)
end


-- challenge

-- funzione per generare chiave
-- ottetto da 16 bit in numero 
local function keyGen()

	local myOctet = OCTET.random(2)
	local arr = octet_toByte(myOctet)
    local myKey = (arr[1] << 8) | arr[2]
	return myKey
end 

-- input mess: ottetto, chiave numero
-- ritorno ct come ottetto
local function cipher(myMess, key)

	local ct_arr = {}
	-- uso la chiave come seed
	local mySeed = key
	local myState = mt_state()
	initialize_state(myState, mySeed)

	-- mess come ottetto
	local byte_arr = {}
	byte_arr = octet_toByte(myMess)
	
	-- ora per generare il keystream, genero un numero e xoro i byte
	-- ai byte del mess
	local rnd = 0
	local b1,b2,b3,b4

	for i = 1, #byte_arr do

		if i%4 == 1 then 
			-- genero numero 
			rnd = random_uint32(myState)
			-- divido i 4 byte
			b1 = rnd & 0xff
			b2 = (rnd >> 8) & 0xff
			b3 = (rnd >> 16) & 0xff
			b4 = (rnd >> 24) & 0xff
		end
		
		if i%4 == 1 then
			ct_arr[i] = byte_arr[i] ~ b1
		elseif i%4 == 2 then
			ct_arr[i] = byte_arr[i] ~ b2
		elseif i%4 == 3 then
			ct_arr[i] = byte_arr[i] ~ b3
		elseif i%4 == 0 then
			ct_arr[i] = byte_arr[i] ~ b4
		end
	end

	return byte_toOctet(ct_arr)
end

-- verifico che funzioni cifratura e decifratura
local myMess = OCTET.from_string("AAAAAAAAAA")
local myKey = keyGen()
local myCt = cipher(myMess, myKey)
local myPt = cipher(myCt, myKey)
if myPt == myMess then
	print("risulta")
end

-- ora devo cifrare 14 A seguite da un numero random di caratteri random
-- faccio random piccolo...
local num_prefix = math.random(1,20)
local prefix = OCTET.random(num_prefix)

local A_oct = OCTET.from_string("AAAAAAAAAAAAAA")
local tot_mess = prefix .. A_oct
-- uso la chiave generata sopra...
local A_ct = cipher(tot_mess, myKey)

-- la chiave è lunga solo 2 byte.. quindi si possono provare
-- tutte in bruteforce e vedere se gli ultimi byte sono A
local found_key = 0
for i = 0, 65535 do
	local att_ct = cipher(A_ct, i)
	local string_ct = att_ct:string()
	local str_len = string.len(string_ct)
	local last_part = string.sub(string_ct, str_len -13, str_len)

	if last_part == "AAAAAAAAAAAAAA" then
		found_key = i
		break
	end
end
print("chiave originale:", myKey)
print("chiave trovata:", found_key)

-- ora devo prendere il tempo e fare un token
local myTime = os.time()
-- per non avere problemi come prima con il tempo, faccio finta
-- che siano passati un po' di secondi da quando il token è stato
-- chiesto
local passed_time = 88
local token_time = myTime - passed_time

local pass_state = mt_state()
initialize_state(pass_state, token_time)
local token = random_uint32(pass_state)
local found = false
local found_time = 0
local found_token = 0
-- supponiamo che l'attaccante usi myTime
-- proviamo fino a 1000 secondi in meno, come challenge prec.
for i = 0, 1000 do
	local act_time = myTime - i
	local att_state = mt_state()
	initialize_state(att_state, act_time)
	local att_token = random_uint32(att_state)
	if att_token == token then
		found = true
		found_time = act_time
		found_token = att_token
		break
	end 
end

if found then 
	print("token originale:", string.format("%u", token))
	print("token trovato:", string.format("%u",found_token))
end
		

	
