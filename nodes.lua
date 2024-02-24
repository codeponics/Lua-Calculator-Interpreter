local module = {}

local num_repr = {
	__tostring = function(t)
		return '('..tostring(t.value)..')'
	end
}

local add_repr = {
	__tostring = function(t)
		return '('..tostring(t.a)..'+'..tostring(t.b)..')'
	end,	
}

local sub_repr = {
	__tostring = function(t)
		return '('..tostring(t.a)..'-'..tostring(t.b)..')'
	end,
}

local mul_repr = {
	__tostring = function(t)
		return '('..tostring(t.a)..'*'..tostring(t.b)..')'
	end,
}

local div_repr = {
	__tostring = function(t)
		return '('..tostring(t.a)..'/'..tostring(t.b)..')'
	end,
}

local exp_repr = {
	__tostring = function(t)
		return '('..tostring(t.a)..'^'..tostring(t.b)..')'
	end,
}

local plus_repr = {
	__tostring = function(t)
		return '(+'..tostring(t.value)..')'
	end,
}

local minus_repr = {
	__tostring = function(t)
		return '(-'..tostring(t.value)..')'
	end,
}

export type node = {
	value: any | node
}

local function operator_node(node_a, node_b)
	return {
		a = node_a,
		b = node_b
	}
end

local function isNumberNode(node)
	return type(node) == 'table' and type(node.value) == 'number'
end

function module.getNodeType(node)
	local node_metatable = getmetatable(node)
	if node_metatable == num_repr then
		return 'NumberNode'
	elseif node_metatable == plus_repr then
		return 'PlusNode'
	elseif node_metatable == minus_repr then
		return 'MinusNode'
	elseif node_metatable == add_repr then
		return 'AddNode'
	elseif node_metatable == sub_repr then
		return 'SubtractNode'
	elseif node_metatable == mul_repr then
		return 'MultiplyNode'
	elseif node_metatable == div_repr then
		return 'DivideNode'
	elseif node_metatable == exp_repr then
		return 'ExponentNode'
	end
end

function module.NumberNode(value: number)
	if type(value) ~= 'number' then
		error('Expected number, got '..typeof(value), 2)
	end
	return setmetatable({
		value = value
	}, num_repr)
end

function module.PlusNode(value: number | node)
	return setmetatable({
		value = value
	}, plus_repr)
end

function module.MinusNode(value: number | node)
	return setmetatable({
		value = value
	}, minus_repr)
end

function module.AddNode(a, b)
	return setmetatable(operator_node(a, b), add_repr)
end

function module.SubtractNode(a, b)
	return setmetatable(operator_node(a, b), sub_repr)
end

function module.MultiplyNode(a, b)
	return setmetatable(operator_node(a, b), mul_repr)
end

function module.DivideNode(a, b)
	return setmetatable(operator_node(a, b), div_repr)
end

function module.ExponentNode(a, b)
	return setmetatable(operator_node(a, b), exp_repr)
end

-- for debugging only
local function removeMetatables(t)
	if type(t) ~= "table" then
		return t
	end

	local newTable = {}

	for k, v in pairs(t) do
		if type(v) == "table" then
			newTable[k] = removeMetatables(v)
		else
			newTable[k] = v
		end
	end

	setmetatable(newTable, nil)
	return newTable
end
--

function module.Visit(node) -- interpreter
	assert(node ~= nil, 'Node is nil')
	
	local node_type = module.getNodeType(node)
	
	if node_type == 'NumberNode' then
		return module.NumberNode(node.value)
	elseif node_type == 'MinusNode' then
		local current = node.value
		while true do
			if isNumberNode(current) then
				return module.NumberNode(-current.value)
			else
				current = current.value
				if isNumberNode(current) then
					return module.NumberNode(current.value)
				end
			end
		end
	elseif node_type == 'PlusNode' then
		local current = node
		while not isNumberNode(current) do
			current = current.value
		end
		return module.NumberNode(current.value)
	elseif node_type == 'AddNode' then
		return module.NumberNode(module.Visit(node.a).value + module.Visit(node.b).value)
	elseif node_type == 'SubtractNode' then
		return module.NumberNode(module.Visit(node.a).value - module.Visit(node.b).value)
	elseif node_type == 'MultiplyNode' then
		return module.NumberNode(module.Visit(node.a).value * module.Visit(node.b).value)
	elseif node_type == 'DivideNode' then
		return module.NumberNode(module.Visit(node.a).value / module.Visit(node.b).value)
	elseif node_type == 'ExponentNode' then
		print('Doing exponentiation of', module.Visit(node.a).value, module.Visit(node.b).value)
		return module.NumberNode(math.pow(module.Visit(node.a).value, module.Visit(node.b).value))
	end
end

return module