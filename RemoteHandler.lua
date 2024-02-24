local tokenizer = require(script.Parent.tokenizer)
local parser = require(script.Parent.parser)
local nodes = require(script.Parent.nodes)

game.ReplicatedStorage.Process.OnServerInvoke = function(player: Player, expr: string)
	if type(expr) ~= 'string' or not string.match(expr, '%S') then
		return nil
	end
	local tree = parser.new(tokenizer.tokenize(expr)) 
	return tostring(tree)..' = '..tostring(nodes.Visit(tree).value)
	--[[local suc, result = pcall(function()
		return parser.new():parse(tokenizer.tokenize(expr))
	end)
	return result]]
end