local log = require 'log'
local obj = require 'obj'
local urandom = require 'urandom'
local b58     = require 'base58'
local ctxlog  = require 'ctx.log'

local M = obj.class({}, 'ctx')

function M:_init(id)
	id = id or b58.encode( urandom:s( 6 ) )
	self.id = tostring(id);
	self.log = ctxlog(self.id)
end

function M:_stringify()
	return self.___name..'#'..self.___id..'/'..self.id
end

function M:suffix(sfx)
	self.log:_prefix(self.id .. '+' .. tostring(sfx))
end

return M
