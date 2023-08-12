local ffi = require 'ffi'
-- local uuid = require 'uuid'

local libpath = package.search and package.search('libbase58')
	or assert(package.searchpath('libbase58', package.cpath))
local lib = ffi.load(libpath, true)
local GENBUF = 256

local genbuf = ffi.new('char[?]',GENBUF)
local sz = ffi.new('size_t [1]');

ffi.cdef[[
	bool encode_base58(const char *data, size_t binsz, char *b58, size_t *b58sz);
	bool decode_base58(const char *b58, size_t b58sz, void *bin, size_t *binszp);
	char * strerror(int errnum);
]]

local function encode_base58( input )
	local newsize = math.floor(#input*3/2)+1
	-- print("newsize = ",newsize)
	local out
	if newsize > GENBUF then
		out = ffi.new('char[?]',newsize)
		sz[0] = newsize
	else
		out = genbuf
		sz[0] = GENBUF
	end
	-- local sz = 
	-- sz[0] = ffi.sizeof(out)

 	if lib.encode_base58(input, #input, out, sz) then
 		if sz[0] > 0 then
	 		return ffi.string(out, sz[0])
 		else
	 		return ""
	 	end
	else
	 	error("Failed to encode", 2)
 	end
end

local function decode_base58( input )
	local newsize = math.floor(#input*4/3+1)
	-- print("newsize = ",newsize)
	local out
	if newsize > GENBUF then
		out = ffi.new('char[?]',newsize)
		sz[0] = newsize
	else
		out = genbuf
		sz[0] = GENBUF
	end
 	if lib.decode_base58(input, #input, out, sz) then
 		if sz[0] > 0 then
	 		return ffi.string(out+ffi.sizeof(out)-sz[0], sz[0])
 		else
	 		return ""
	 	end
	else
	 	error("Failed to decode: "..ffi.string(ffi.C.strerror(ffi.errno())), 2)
 	end
end

-- print("e = ", encode_base58("09"))
-- print("d = ", decode_base58("4ER"))
-- print("e/d = ",encode_base58(decode_base58("4ER")))

local function hex2bin(str)
	return (string.gsub(str, '..', function (cc) return string.char(tonumber(cc, 16)) end))
end
local function bin2hex(str)
	return (string.gsub(str, '.', function (c) return string.format('%02x', string.byte(c)) end))
end

-- local v = "nsEZ97iJrza4gy3mk9AS55"
-- -- local v = "nsss"
-- print(v)
-- print(bin2hex(decode_base58(v)))
-- print( encode_base58(decode_base58(v)) )
-- print( "min", encode_base58("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00") )
-- print( "max", encode_base58("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff") )
-- print( "min", #decode_base58( encode_base58("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")) )
-- print( "max", #decode_base58( encode_base58("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff")) )
-- -- error("X")

return  {
	encode = encode_base58;
	decode = decode_base58;
}

