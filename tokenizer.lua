local module = {}
module.__index = module

local operatorsEnums = {
	['+'] = 'Plus',
	['-'] = 'Minus',
	['*'] = 'Multiply',
	['/'] = 'Divide',
	['^'] = 'Exponent',
}

local words = {
	['sin'] = math.sin,
	['cos'] = math.cos,
	['tan'] = math.tan,
}

function module.checkforparen(tokens)
	local paren_stack = {}
	
	local function pop()
		table.remove(paren_stack, 1)
	end
	
	for token in tokens do
		if token.Type == 'lparen' then
			table.insert(paren_stack, true)
		elseif token.Type == 'rparen' then
			pop()
		end
	end
	
	return #paren_stack == 0
end

function module.tokenize(expression: string)
	local tokens = {}
	local expr = string.split(string.lower(expression), '') -- create table of characters
	local index = 1
	while index-1 < #expr do
		local char = expr[index]
		if string.match(char, '%s') then
			index += 1
			continue
		elseif string.match(char, '%d') then
			local num_str = char
			local dot_flag = false
			while true do
				if not next(expr, index) then
					break
				end
				index = next(expr, index)
				char = expr[index]
				if not (string.match(char, '%d') or char == '.') then
					break
				end
				if char == '.' then
					if dot_flag then
						error('Malformed number: multiple decimal points', 2)
					end
					dot_flag = true
				end
				num_str ..= char				
			end
			if index ~= #expr then
				index -= 1
			end
			if string.sub(num_str, 1, 1) == '.' then -- given only '.' or '.xxxx'
				num_str = '0'..num_str
			end
			if string.sub(num_str, 2, 2) == '.' and #num_str == 2 then -- given 'xxxx.' only
				num_str ..= '0'
			end
			table.insert(tokens, {Type = 'Number', Value = tonumber(num_str)}) -- tonumber deals with 0. and .0 cases
		elseif operatorsEnums[char] then
			table.insert(tokens, {Type = operatorsEnums[char], Value = char})
		elseif char == '(' then
			table.insert(tokens, {Type = 'lparen', Value = '('})
		elseif char == ')' then
			table.insert(tokens, {Type = 'rparen', Value = ')'})
		elseif string.match(char, '%w') then -- alphanumeric characters
			local alphanumericstr = char
			while true do
				if not next(expr, index) then
					break
				end
				index = next(expr, index)
				char = expr[index]
				if not string.match(char, '%w') then
					break
				end
				alphanumericstr ..= char
			end
			if index ~= #expr then
				index -= 1
			end
			if words[alphanumericstr] then
				table.insert(tokens, {Type = alphanumericstr, Value = words[alphanumericstr]})
			else
				table.insert(tokens, {Type = 'Word', Value = alphanumericstr})
			end
		end
		index += 1
	end
	return tokens
end

return module