-- challenge 22
--[[
-- prova del comando
local unixtime = os.time()
print(unixtime)
	
]]

-- riprendo la challenge precedente

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
mySeed = 5489
--mySeed = 19650218

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
	myArray[1] = seed & WMASK

	
	-- ciclo
	for i = 2, n do
		-- modifico: aggiungo maschera
		local prev_seed = myArray[i-1] & WMASK
		-- anche qui faccio attenzione a i...
		-- modifico per aggiungere maschera
		local shifted = (prev_seed >> (w-2)) & WMASK
		local diff = (prev_seed ~ shifted) & WMASK
		myArray[i] = (f * diff + (i-1)) & WMASK
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
	local val_k = myArray[k] & WMASK
	local val_j = myArray[j] & WMASK
	local x = ((val_k & UMASK) | (val_j & LMASK)) & WMASK

	-- anche qui aggiungo maschera
	local xA = (x >> 1) & WMASK
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
	x = (myArray[j] ~ xA) & WMASK
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

-- CHALLENGE

-- simulo il tempo
local unixtime = os.time()

-- ora dovrei aspettare un numero di secondi random tra 40 e mille
local first_int = math.random(40,1000)

-- ora sommo essendo unixtime un intero i secondi al tempo di inizio
-- questo sarà il mio seed
local myTime = unixtime + first_int
-- per sicurezza stampo il mio unixtime
print("tempo utilizzato:", myTime)

-- ora aspetto un altro numero di secondi random
local second_int = math.random(40,1000)
print("ho aggiunto:", second_int)

-- ora posso inizializzare
local myState = mt_state()
initialize_state(myState, myTime)
myRandom = random_uint32(myState)

-- ora faccio l'attacco. calcolo il mio unix time da attaccante 
-- e faccio un ciclo per arrivare fino al tempo
-- che avrà usato il sistema per calcolare il random
local att_time = myTime + second_int

local att_random = 0
local i = 1
local found_time = 0

repeat 
	found_time = att_time - i
	local att_state = mt_state()
	initialize_state(att_state, found_time)
	att_random = random_uint32(att_state)
	i = i + 1
until att_random == myRandom

-- quando esce da qui att_random è uguale a quello trovato teoricamente
-- quindi 
print("tempo usato nell'attacco:", found_time)

-- provo a stampare anche i numeri (attenta unsigned)
local myRandom_u = myRandom & 0xFFFFFFFF
local att_random_u = att_random & 0xFFFFFFFF

print(string.format("numero vero: %u", myRandom_u))
print(string.format("numero trovato: %u", att_random_u))
