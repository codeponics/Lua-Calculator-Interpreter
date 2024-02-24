# Luau Calculator Interpreter
Made in April 2023

This is a port of a Python node-based recursive descent parser that I made.
It is relatively simple so it only relies on arithmetic and named functions (trigs).

The nodes created have tostring metamethods and make it easy to visualize the nodes through parentheses.
For example, a + b will be printed as ((a) + (b)). This shows what operator has precedence and how it is being read.

Currently the operator precendence in order is negation, plus sign (+1 is just set to be 1), addition, subtraction, multiplication, division, exponentiation

![](https://github.com/codeponics/Lua-Calculator-Interpreter/blob/main/parserdemo.gif)

# Note
Using Luau from Roblox (Lua 5.1 won't work)
It can be modified to work in Lua 5.1+

# License
MIT License