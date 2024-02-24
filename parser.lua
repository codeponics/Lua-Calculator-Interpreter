local module = {}
module.__index = module

local nodes = require(script.Parent.nodes)

function module.new(tokens) -- add tokens to parse
	local object = setmetatable({
		current_token = nil,
		current_index = nil,
		tokens = nil
	}, module)
	
	if type(tokens) == 'table' then
		if not next(tokens) then
			return -- return nil for empty tokens
		end
		return object:parse(tokens)
	elseif tokens ~= nil then
		error('Tokens must be type other than table or nil.', 2)
	end
	
	return object
end

function module:parse(tokens)
	if tokens and not self.tokens then
		self.tokens = tokens
		self.current_index = next(tokens)
		self.current_token = tokens[self.current_index]
	end
	
	if not self.current_token then
		return
	end
	
	local result = self:expression()
	if self.current_token then
		print('Extra unprocessed tokens')
		print('Tokens:', self.tokens)
		print('Remaining tokens: ')
		for i = self.current_index, #self.tokens do
			print(self.tokens[i])
		end
	end
	
	return result
end

function module:peekPrevious()
	return self.tokens[self.current_index - 1]
end

function module:next()
	self.current_token = self.tokens[next(self.tokens, self.current_index)]
	if self.current_token then
		self.current_index += 1
		return true
	end
	return false
end

function module:expression()
	local result = self:term()
	
	local c = 0
	
	while self.current_token and (self.current_token.Type == 'Plus' or self.current_token.Type == 'Minus') do
		if self.current_token.Type == 'Plus' then
			self:next()
			result = nodes.AddNode(result, self:term())
		elseif self.current_token.Type == 'Minus' then
			self:next()
			result = nodes.SubtractNode(result, self:term())
		end
	end
	
	return result
end

function module:term()
	local result = self:factor()
	
	while self.current_token and (self.current_token.Type == 'Multiply' or self.current_token.Type == 'Divide' or self.current_token.Type == 'Exponent') do
		print(self.current_token.Type..' = Type')
		if self.current_token.Type == 'Exponent' then
			self:next()
			result = nodes.ExponentNode(result, self:term())
		elseif self.current_token.Type == 'Multiply' then
			self:next()
			result = nodes.MultiplyNode(result, self:term())
		elseif self.current_token.Type == 'Divide' then
			self:next()
			result = nodes.DivideNode(result, self:term())
		end
	end
	
	return result
end

function module:factor()
	local token = self.current_token
	
	if not token then
		error('Misformed expression encountered', 2)
	end
	
	if token.Type == 'lparen' then
		self:next()
		local result = self:expression()
		
		self:next()
		return result
	elseif token.Type == 'Number' then
		self:next()
		return nodes.NumberNode(token.Value)
	elseif token.Type == 'Plus' then
		self:next()
		return nodes.PlusNode(self:factor())
	elseif token.Type == 'Minus' then
		self:next()
		return nodes.MinusNode(self:factor())
	elseif type(token.Value) == 'function' then
		self:next()
		return nodes.NumberNode(token.Value(self:factor().value))
	end
	
	-- shouldn't be anything remaining
	error('Leftover factors found, unable to parse. Current token: '..self.current_token.Type, 2)
end

return module