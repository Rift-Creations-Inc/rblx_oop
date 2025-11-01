
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerMainScript = game.ServerScriptService.Server.ServerMain
local core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()
local ThreadException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.ThreadException)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local Thread = require(ReplicatedStorage.Shared.rblx_oop.lang.Thread.Thread)

Thread.register("rblx_oop.internal.ServerMainRunner")

repeat 
    task.wait() 
until core.initialized

local function write(txt: string)
    if not config.server.debugServerMainRunner then return end
    print(`[ServerMainRunner] {txt}`)
end

local function _doRunServer()
    write(`requiring ServerMain at {ServerMainScript:GetFullName()}`)

    Thread.Builder.new()
        :name("ServerMainThread")
        :except(function(thread: Thread.Thread,err: string)
            ThreadException.new(`unhandled exception in {thread:name()}: {err}`)
        end)
        :spawn(require(ServerMainScript).Main)
end

local function RunServerMain()
    _doRunServer()
end

local function Main()
    RunServerMain()
end

local function RunRblxOopInternal(fn: () -> ())
    write(`RunRblxOopInternal: ServerMainRunner::Main()`)
    fn()
end

local function _INTERNAL_MAIN()
    write(`Running InternalServerMain...`)
    Thread.spawn(
        require(script.Parent.InternalServerMain).Main,
        "InternalServerMain"
    )
end

_INTERNAL_MAIN()
RunRblxOopInternal(Main)