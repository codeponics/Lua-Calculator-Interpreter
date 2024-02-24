local runservice = game:GetService("RunService")
local tokenizer = require(script.Parent.tokenizer)
local parser = require(script.Parent.parser)
local nodes = require(script.Parent.nodes)

if runservice:IsRunMode() and runservice:IsStudio() then
	local tokens = tokenizer.tokenize('((-1))^3')
	local tree = parser.new(tokens)
	local value = nodes.Visit(tree)
	
	print(tree)
	print('value:', value)
end