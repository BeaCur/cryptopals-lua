-- challenge 21

-- definisco le variabili 
n = 624
m = 397
w = 32
r = 31
WMASK = 0xffffffff
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

-- funzione che genera state
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
	myArray[1] = seed & WMASK

	-- ciclo
	for i = 2, n do
		local prev_seed = myArray[i-1]
		-- anche qui attenzione a i...
		myArray[i] = (f * (prev_seed ~ (prev_seed >> (w-2))) + (i-1)) & WMASK
	end
	
	-- rimetto a 1 index (no 0)
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
	local x = (myArray[k] & UMASK) | (myArray[j] & LMASK)

	local xA = x >> 1
	if (x & 0x00000001) ~= 0 then
		xA = xA ~ a
	end 

	-- definisco di nuovo j
	j = k - (n-m)
	if j < 1 then
		j = j+n
	end

	-- riprendo x
	x = myArray[j] ~ xA
	myArray[k] = x
	k = k+1

	-- qua metto solo maggiore e metto dentro 1 non 0
	if k > n then
		k = 1
	end
	mtState["state_index"] = k

	local y = x ~ ( x >> u)
	y = y ~ ((y << s) & b)
	y = y ~ ((y << t) & c)
	local z = y ~ (y >> l)
	return z & WMASK
end 


-- provo a fare una verifica con seed dato 

local myState = mt_state()
initialize_state(myState, mySeed)

-- verifico i primi 5 numeri generati
for i = 1, 5 do

    local num = random_uint32(myState)
    
    -- Lo stampiamo sia in formato Decimale sia in Esadecimale a 8 cifre
    print(string.format("Numero %d: %u", i, num))
end
	

--[[
-- provo anche con stato nuovo

local myState = mt_state()
initialize_state(myState, mySeed)

for i = 1, 624 do
	random_uint32(mioStato)
end
-- con primo e secondo elemento del nuovo stato
local num_625 = random_uint32(myState)
local num_626 = random_uint32(myState)

print(string.format("Numero 625: %u", num_625))
print(string.format("Numero 626: %u", num_626,))
]]
