
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotImplementedException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.NotImplementedException)
local Safe = require(script.Parent.Safe)
local Vec = require(script.Parent.Vec)
local u8 = require(ReplicatedStorage.Shared.rblx_oop.lang.base.primitiveTypes.u8)

local debugNatives = require(ReplicatedStorage.Shared.rblx_oop.lang.debugNatives)
local function _dbg(str: string)
    if not debugNatives then return end
    print(`[nativeTypeDebug] [lang::base::String] {str}`)
end

local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local Iterator = require(ReplicatedStorage.Shared.rblx_oop.util.Iterator)
local Consumer = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Consumer)
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

type Consumer<T> = Consumer.Consumer<T>
type Iterator<E> = Iterator.Iterator<E>
type u8 = u8.u8
type Vec<T> = Vec.Vec<T>

local String = {

    _typePath = "lang::base::String"
}
String.__index = String

export type String = {
    vec: Vec<u8>,

    intoBytes: (
        self: String
    ) -> Vec<u8>,

    asStr: (
        self: String
    ) -> string,

    pushStr: (
        self: String,
        append: String
    ) -> String,

    push: (
        self: String,
        char: string
    ) -> String,

    remove: (
        self: String,
        idx: number
    ) -> string,

    pop: (
        self: String
    ) -> String,
    
    clear: (
        self: String
    ) -> String,
    
    iterator: (
        self: String
    ) -> Iterator.Iterator<String>
    
} & IBaseFeature<"String">

function String.new(): String
    _dbg(`new {String._typePath}`)
    local vec: Vec<u8> = Vec.new()
    
    return setmetatable({
        vec = vec
    }, String)
end

function String.from(value: string): String
    _dbg(`new {String._typePath} from "{value}"`)
    local s = String.new()
    for i = 1, value:len() do
        s:push(string.byte(value,i))
    end
    return s
end

function String.withCapacity(size: number): String
    _dbg(`new {String._typePath} with capacity {tostring(size)}`)
    local vec: Vec<u8> = Vec.withCapacity(size)

    return setmetatable({
        vec = vec
    }, String)
end

function String.intoBytes(self: String): Vec<u8>
    local byteArray: Vec<u8> = Vec.new()

    for v in self.vec:iterator() do
        byteArray:push(v)
    end

    return byteArray
end

function String.asStr(self: String): string
    local str = ""

    for v in self.vec:iterator() do
        str ..= string.char(v :: number)
    end

    return str
end

function String.pushStr(self: String, append: String): String
    for v in append.vec:iterator() do
        self:push(v)
    end

    return self
end

function String.push(self: String, char: string)
    self.vec:push(char)

    return String
end

function String.remove(self: String, idx: number): string
    if idx > self.vec:size() then
        return nil
    end

    return self.vec:remove(idx)
end

function String.pop(self: String): String
    self.vec:pop()

    return self
end

function String.clear(self: String): String
    self.vec:clear()

    return String
end


function String.iterator(self: String): Iterator<String>
    local index = 0
    local items = self.vec.items

    local iter: Iterator<string> = {
        hasNext = function(): boolean
            return index < #items
        end,

        next = function(): string
            index += 1
            return items[index]
        end,

        remove = function(): never
            NotImplementedException.new("remove is not implemented")
            return
        end,

        forEachRemaining = function(action: Consumer<string>): never
            while index < #items do
                index += 1
                action:accept(items[index])
            end
        end
    }

    return iter
end

local function Normalize(x: any)
    if typeof(x) == "string" then
        x = String.from(x)
        elseif getmetatable(x) ~= String then
            x = String.from(tostring(x))
        end
        
        return x
    end
    
--[[
    =============== META ===============
--]]

local function concatRaw(a: any,b: any)
    _dbg(`  do concat`)
    a = Normalize(a)
    b = Normalize(b)

    local newString = String.new()

    newString
        :pushStr(a)
        :pushStr(b)

    return newString
end

function String.__add(a,b)
    _dbg(`concat with +`)

    return concatRaw(a,b)
end

function String.__concat(a,b)
    _dbg(`concat with ..`)

    return concatRaw(a,b)
end

function String.__tostring(self: String)
    return self:asStr()
end

Safe(String)

return String