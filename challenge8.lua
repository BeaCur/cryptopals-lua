-- challenge 8

-- carico il file
local raw_data = KEYS or DATA or ""
local lines = {}
for line in raw_data:gmatch("[^\r\n]+") do
    line = line:match("^%s*(.-)%s*$")
    if #line > 0 then
        table.insert(lines, line)
    end
end

--print("Numero di stringhe caricate:", #lines)

for index, line in ipairs(lines) do

	local length = #line
	block_size = 32
	local bool = false
	
	-- divido la stringa in sottostringhe da 32 (16 byte)
	for i = 1, length - block_size, block_size do
		local act_block = line:sub(i, i + block_size - 1)
		
		-- seconda sottostringa
		for j = i + block_size,  length - block_size, block_size do
			local second_block = line:sub(j, j + block_size -1)
			
			-- controllo se sono uguali
			if act_block == second_block then
				bool = true
				print("ho trovato la stringa che è alla riga:", index)
				break
			end
		end
		if bool then
			break
		end
	end 
end
