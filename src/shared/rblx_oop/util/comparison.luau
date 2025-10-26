local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Predicate = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Predicate)


local isEven = Predicate(function(x: number)
    return x % 2 == 0
end)

local isPositive = Predicate(function(x: number)
    return x > 0
end)

local isNegative = Predicate(function(x: number)
    return isPositive:negate():test(x)
end)

return {
    isEven = isEven,
    isPositive = isPositive,
    isNegative = isNegative
}