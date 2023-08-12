local M = {}

-- FIXME: check file autoclose on handler destroy
if not rawget(_G,'_dev_urandom') then
	local u = assert(io.open("/dev/urandom", "rb"), "Failed to open /dev/urandom")
	rawset(_G,'_dev_urandom', u)
end

local urand = _G._dev_urandom

function M:i()
	return box.unpack('i', urand:read(4))
end

function M:l()
	return box.unpack('l', urand:read(8))
end

function M:s(len)
	if type(self) == 'number' then len = self end
	len = tonumber(len)
	assert(len > 0, 'length required')
	return urand:read(len)
end

return M