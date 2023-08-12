local json = require 'json'
local log = require 'log'

local http_client = require 'http.client'
local digest = require 'digest'

local M = {}

M.err = {}
M.EcodeKeyNotFound        = 100; M.err[M.EcodeKeyNotFound]       = "Key not found"
M.EcodeTestFailed         = 101; M.err[M.EcodeTestFailed]        = "Compare failed"
M.EcodeNotFile            = 102; M.err[M.EcodeNotFile]           = "Not a file"
M.EcodeNotDir             = 104; M.err[M.EcodeNotDir]            = "Not a directory"
M.EcodeNodeExist          = 105; M.err[M.EcodeNodeExist]         = "Key already exists"
M.EcodeRootROnly          = 107; M.err[M.EcodeRootROnly]         = "Root is read only"
M.EcodeDirNotEmpty        = 108; M.err[M.EcodeDirNotEmpty]       = "Directory not empty"
M.EcodePrevValueRequired  = 201; M.err[M.EcodePrevValueRequired] = "PrevValue is Required in POST form"
M.EcodeTTLNaN             = 202; M.err[M.EcodeTTLNaN]            = "The given TTL in POST form is not a number"
M.EcodeIndexNaN           = 203; M.err[M.EcodeIndexNaN]          = "The given index in POST form is not a number"
M.EcodeInvalidField       = 209; M.err[M.EcodeInvalidField]      = "Invalid field"
M.EcodeInvalidForm        = 210; M.err[M.EcodeInvalidForm]       = "Invalid POST form"
M.EcodeRaftInternal       = 300; M.err[M.EcodeRaftInternal]      = "Raft Internal Error"
M.EcodeLeaderElect        = 301; M.err[M.EcodeLeaderElect]       = "During Leader Election"
M.EcodeWatcherCleared     = 400; M.err[M.EcodeWatcherCleared]    = "watcher is cleared due to etcd recovery"
M.EcodeEventIndexCleared  = 401; M.err[M.EcodeEventIndexCleared] = "The event in requested index is outdated and cleared"

function M.errstr(code)
	return M.err[ tonumber(code) ] or string.format("Unknown error %s",code)
end

function M.new(mod,options)
	local self = setmetatable({},{__index=mod})
	self.endpoints = options.endpoints or {'http://127.0.0.1:4001','http://127.0.0.1:2379'}
	-- self.prefix    = options.prefix or ''
	self.timeout   = options.timeout or 1
	self.client    = http_client -- .new() - it fix for 1.6 also client: -> clent.
	self.boolean_auto = options.boolean_auto
	self.print_config = options.print_config
	self.discover_endpoints = options.discover_endpoints == nil and true or options.discover_endpoints
	if options.reduce_listing_quorum == true then
		self.reduce_listing_quorum = true
	end
	if options.login then
		self.authorization = "Basic "..digest.base64_encode(options.login..":"..(options.password or ""))
		self.headers = { authorization = self.authorization }
	end
	return self
end

setmetatable(M,{ __call = M.new })

function M:discovery()
	local timeout = self.timeout or 1
	local new_endpoints = {}
	local tried = {}
	for _,e in pairs(self.endpoints) do
		local uri = e .. "/v2/members"
		local x = self.client.request("GET",uri,'',{timeout = timeout; headers = self.headers})
		if x and x.status == 200 then
			if x.headers['content-type'] == 'application/json' then
				local data = json.decode( x.body )
				local hash_endpoints = {}
				for _,m in pairs(data.members) do
					-- print(yaml.encode(m))
					for _, u in pairs(m.clientURLs) do
						hash_endpoints[u] = true
					end
				end
				for k in pairs(hash_endpoints) do
					table.insert(new_endpoints,k)
				end
				if #new_endpoints > 0 then
					break
				end
			else
				table.insert(tried, e..": bad reply")
			end
		elseif x and x.status == 404 then
			table.insert(tried, e..": no /v2/members: possible run without --enable-v2?")
		else
			table.insert(tried, e..": "..(x and x.status))
		end
	end
	if #new_endpoints == 0 then
		error("Failed to discover members "..table.concat(tried,", "),2)
	end
	if self.discover_endpoints then
		self.endpoints = new_endpoints
		table.insert(self.endpoints,table.remove(self.endpoints,1))
		log.info("discovered etcd endpoints "..table.concat(self.endpoints,", "))
	else
		log.info("hardcoded etcd endpoints "..table.concat(self.endpoints,", "))
	end
	self.current = math.random(#self.endpoints)
end

function M:request(method, path, args )
	-- path must be prefixed outside
	-- TODO: auth
	local query = {}
	if args then
		for k,v in pairs(args) do
			if #query > 0 then table.insert(query,'&') end
			table.insert(query, k)
			table.insert(query, '=')
			table.insert(query, tostring(v))
		end
	end
	local qs
	if #query > 0 then qs = '?'..table.concat(query) else  qs = '' end
	local body = args and args.body or ''
	local lasterror, lastresponse

	local len = #self.endpoints
	for i = 0, len - 1 do
		local cur = self.current + i
		if cur > len then
			cur = cur % len
		end
		local uri = string.format("%s/v2/%s%s", self.endpoints[cur], path, qs )
		-- print("[debug] "..uri)
		local x = self.client.request(method,uri,body,{timeout = args.timeout or self.timeout or 1; headers = self.headers})
		lastresponse = x
		local status,reply = pcall(json.decode,x and x.body)

		-- 408 for timeout
		if x.status < 500 and x.status ~= 408 then
			if status then
				self.current = cur
				return reply, lastresponse
			else
				-- passthru
				lasterror = { errorCode = 500, message = x.reason }
			end
		else
			if status then
				lasterror = reply
			else
				lasterror = { errorCode = 500, message = x.reason }
			end
		end
	end
	return lasterror, lastresponse
end

function M:recursive_extract(cut, node, storage)
	local _storage
	if not storage then _storage = {} else _storage = storage end

	local key
	if string.sub(node.key,1,#cut) == cut then
		key = string.sub(node.key,#cut+2)
	else
		key = node.key
	end

	if node.dir then
		_storage[key] = {}
		for _,v in pairs(node.nodes) do
			self:recursive_extract(node.key, v, _storage[key])
		end
	else
		-- ex: {"createdIndex":108,"modifiedIndex":108,"key":".../cluster","value":"instance_001"}
		if self.boolean_auto then
			if node.value == 'true' then
				node.value = true
			elseif node.value == 'false' then
				node.value = false
			end
		end
		local num = tonumber(node.value)
		if num then
			_storage[ key ] = num
		else
			_storage[ key ] = node.value
		end
		-- TODO: remember index
		-- print("key",key, node.value, json.encode(node))
	end

	if not storage then return _storage[''] end
end

function M:list(keyspath)
	local res, response = self:request("GET","keys"..keyspath, { recursive = true, quorum = not self.reduce_listing_quorum })
	-- print(yaml.encode(res))
	if res.node then
		local result = self:recursive_extract(keyspath,res.node)
		-- todo: make it with metatable
		-- print(yaml.encode(result))
		return result, response
		-- for _,n in pairs(res.node) do
		-- 	print()
		-- end
	else
		error(json.encode(res),2)
	end
end

function M:wait(keyspath, args)
	args = args or {}
	local _, response = self:request("GET","keys"..keyspath, {
		wait = true,
		recursive = true,
		timeout = args.timeout,
		waitIndex = args.index,
	})
	return response.status ~= 408, response
end

return M
