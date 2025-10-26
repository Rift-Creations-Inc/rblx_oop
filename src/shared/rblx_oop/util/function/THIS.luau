local BiConsumer = require(script.Parent.BiConsumer)
local BiFunction = require(script.Parent.BiFunction)
local BiPredicate = require(script.Parent.BiPredicate)
local BinaryOperator = require(script.Parent.BinaryOperator)
local Comparator = require(script.Parent.Comparator)
local Consumer = require(script.Parent.Consumer)
local Function = require(script.Parent.Function)
local Predicate = require(script.Parent.Predicate)
local Supplier = require(script.Parent.Supplier)
local UnaryOperator = require(script.Parent.UnaryOperator)
--[[
    Use 'THIS' instead of init.luau
    so we don't require 'function'
    which causes issues.
--]]

return {
    BiConsumer = BiConsumer,
    BiFunction = BiFunction,
    BiPredicate = BiPredicate,

    Comparator = Comparator,
    Supplier = Supplier,
    
    Consumer = Consumer,
    Function = Function,
    Predicate = Predicate,

    BinaryOperator = BinaryOperator,
    UnaryOperator = UnaryOperator,
}