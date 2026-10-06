-- challenge 23
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

-- challenge

-- devo fare la funzione di untamper
local function untamper(z)

	local y = 0
	-- inverto il primo passaggio. poichè l=18
	-- spostavo y a destra di 18 quindi i primi 18 bit a sx
	-- sono a 0. cioò significa che se ho y xorato con la sua versione
	-- "spostata" i primi 18 bit sono quelli di y
	local lMask = 0xffffc000
	local partial_y = z & lMask
	-- ora y viene xorata con y>> 18. quindi gli elementi che abbiamo
	-- ci bastano, perchè abbiamo 18 elementi + 14 che non conoscoiamo
	-- quindi i 16 che non conosciamo vengono persi nello shift
	local shifted_y = partial_y >> l
	y = z  ~ shifted_y

	-- secondo passaggio da invertire: 	y = y ~ ((y << t) & c)
	local tMask = 0x00007fff
	local part_y = y & tMask
	-- ottenuti i 15 bit piu a destra, provo a ottenere quelli piu avanti
	-- ma non li otterrò tutti...
	local nc_y = (part_y << t) & c
	part_y = y ~ nc_y

	-- mancano gli ultimi 2 bit
	local final_y = (part_y << t) & c
	y = y ~ final_y

	-- 3 passaggio da invertire
	local temp_y = y 
	-- i primi 7 bit li ho gia dalla y. per trovare i successivi 7:
	temp_y = y ~ ((temp_y << s) & b)
	-- ora ho qui dentro i primi 14 bit corretti
	temp_y = y ~ ((temp_y << s) & b)
	-- cosi ottengo i successivi 7 bit, arrivo a 21
	temp_y = y ~ ((temp_y << s) & b)
	-- 28. mancano 4 bit
	y =  y ~ ((temp_y << s) & b)
	-- ora devo invertire l'ultimo passaggio che è xor shift
	-- a destra di u = 11
	-- in y ho i primi 11 bit a sx corretti
	local last_y = y
	last_y = y ~ (last_y >> u)
	-- cosi ottengo altri 11 bit, quindi 22. ne mancano 10
	y = y ~ (last_y >> u)
	return y & WMASK
end 


-- verifica
-- creo numero normalmente
local myState = mt_state()
initialize_state(myState, 123456)
	
local found_array = {}
for i = 1, 624 do
	local rnd_number = random_uint32(myState)
	found_array[i] = untamper(rnd_number)
end

local success = true
local clone_state = mt_state()
clone_state["state_array"] = found_array
clone_state["state_index"] = 1

-- verifico generando numeri con entrambi
for i = 1, 10 do
	local orig_num = random_uint32(myState)
	local clone_num = random_uint32(clone_state)
	print(string.format("Originale: %u  |  Attacco: %u", orig_num, clone_num))

	if orig_num ~= clone_num then
		success = false
	end

end 	    

if success then 
	print("passato")
else 
	print("qualcosa non va")
end
