
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerMainScript = game.ServerScriptService.Server.ServerMain
local core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

repeat 
    task.wait() 
until core.initialized

local function write(txt: string)
    if not config.server.debugServerMainRunner then return end
    print(`[ServerMainRunner] {txt}`)
end

local function _doRunServer()
    write(`requiring ServerMain at {ServerMainScript:GetFullName()}`)

    task.spawn(function()
        local ServerMain = require(ServerMainScript)
        
        ServerMain:Main()
    end)
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

local function _INTERNAL_MAIN()
    write(`Running InternalServerMain...`)
    task.spawn(function()
        require(script.Parent.InternalServerMain):Main()
    end)
end

_INTERNAL_MAIN()
RunRblxOopInternal(Main)