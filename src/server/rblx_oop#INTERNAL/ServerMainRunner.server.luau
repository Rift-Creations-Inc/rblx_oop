local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerMainScript = game.ServerScriptService.Server.ServerMain
local core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

repeat 
    task.wait() 
until core.initialized

local function write(txt: string)
    if not config.server.debugServerMainRunner then return end
    print(`[<internal>::ServerMainRunner] {txt}`)
end

local function _doRunServer()
    write(`requiring ServerMain at {ServerMainScript:GetFullName()}`)
    local ServerMain = require(ServerMainScript)
    
    ServerMain:Main()
end

local function RunServerMain()
    write(`calling _doRunClient...`)
    _doRunServer()
end

local function Main()
    write(`calling RunClientMain...`)
    RunServerMain()
end

local function RunRblxOopInternal(fn: () -> ())
    write(`RunRblxOopInternal: ServerMainRunner::Main()`)
    fn()
end

RunRblxOopInternal(Main)