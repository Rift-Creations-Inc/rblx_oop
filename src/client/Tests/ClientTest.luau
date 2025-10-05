local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskMgr = require(ReplicatedStorage.Shared.rblx_oop.classes.TaskMgr)
local ArithmeticException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.ArithmeticException)

local function write(str: string)
    print(`[ClientTest] {str}`)
end

local ClientTest = {}

local function say67()
    print(`say67: 67!`)
end

local function divide(a: number, b: number): number
    write(`divide: {a}/{b}`)
    if b == 0 then
        ArithmeticException.new(`cannot divide by 0!`,`{a}/{b}`)
    end

    return a/b
end

function ClientTest:TestDivide()
    write(`TestDivide...`)
    divide(5, 0)
end

local function TaskExceptionTest()
    TaskMgr.get(67)
    TaskMgr.get(9)
end

function ClientTest:TestTaskExceptionTest()
    TaskExceptionTest()
end

local function DoTests()
    say67()
    ClientTest:TestDivide()
    ClientTest:TestTaskExceptionTest()
end


function ClientTest:Run()
    write(`calling DoTests()...`)
    DoTests()
end

return ClientTest