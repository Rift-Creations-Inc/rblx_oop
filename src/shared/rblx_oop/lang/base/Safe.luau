local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FailedToFindFieldException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.FailedToFindFieldException) :: any
local FailedToFindMethodException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.FailedToFindMethodException) :: any

type tbl = { [any]: any }

local function safe(t: tbl, name: string?)
    if type(t) == 'function' then
        return t
    end

    local newName = name or tostring(t)

    return setmetatable(t, {
        __index = function(_self,key)

            -- ignore closure and _ stuff
            if type(key) == "string" and key:sub(1,1) == "_" then
                return rawget(_self, key)
            end

            local val = rawget(_self, key)

            if val ~= nil then
                return val
            end

            local proxy = newproxy(true)
            local mt = getmetatable(proxy)

            function mt:__call(_)
                FailedToFindMethodException.new(
                    `{tostring(key)}() is not a valid method of {newName}`
                )
                return
            end

            function mt:__tostring()
                FailedToFindFieldException.new(
                    `{tostring(key)} is not a valid field of {newName}`
                )
            end

            return proxy
        end
    })
end

return safe