-- challenge5
-- riporto le frasi: \n per andare a capo
local plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
local key = "ICE"

local plain_octet = OCTET.from_string(plaintext)
local key_octet = OCTET.from_string(key)

-- ripeto la chiave fino a lunghezza testo
local repeated_key = key_octet:fillrepeat(#plain_octet)

local encrypted_octet = plain_octet ~ repeated_key

print(encrypted_octet:hex())
