--[[
    shitty change log

    - add replication to client

    
    --]]
    
    
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlreadyInitializedException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.AlreadyInitializedException)
local AlreadyCreatedException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.AlreadyCreatedException)
local InvalidArgumentException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.InvalidArgumentException)
local UninitializedObjectException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.UninitializedObjectException)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local Info = require(script.info)
local RunService = game:GetService("RunService")
local dump = require(ReplicatedStorage.Shared.rblx_oop.runtime.core.dump)
local Players = game:GetService('Players')
local CoreDumpsDisabledException = require(script.CoreDumpsDisabledException)

type Info = Info.Info

local function dbg(txt: string)
    if not config.global.debugCoreClass then return end
    print(`[Core/DEBUG] {txt}`)
end

type EventListenerOptions = {
    capture: boolean?,
    once: boolean?,
    passive: boolean?
}

type MappedString<V> = { [string]: V }

type EventMapping = MappedString<RBXScriptSignal>
type ConnectionMapping = MappedString<{ RBXScriptConnection }>
type ListenerMapping = MappedString<{ (...any) -> () }>
type PipeMapping = MappedString<RemoteEvent>

export type Core = {
    initialized: boolean,

    --[[ @BeginSection Events ]]
    _events: EventMapping,
    _connections: ConnectionMapping,
    _listeners: ListenerMapping,
    _pipes: PipeMapping,

    init: (
        self: Core
    ) -> Core,

    get: () -> Core,
    
    registerEvent: (
        self: Core,
        name: string,
        signal: RBXScriptSignal
    ) -> Core,

    dispatchEvent: (
        self: Core,
        event: string,
        ...any
    ) -> Core,
    
    unregisterEvent: (
        self: Core,
        name: string
    ) -> Core,

    addEventListener: (
        self: Core,
        event: string,
        listener: (any) -> (),
        options: (EventListenerOptions | boolean)? 
    ) -> Core,

    waitForEvent: (
        self: Core,
        event: string
    ) -> Core,

    registerPipe: (
        self: Core,
        name: string
    ) -> Core,

    unregisterBridge: (
        self: Core,
        name: string
    ) -> Core,

    generateDump: (
        self: Core
    ) -> dump.CoreDump,

    --[[ @EndSection Events ]]

    --[[ @BeginSection Info ]]

    info: () -> Info,

    --[[ @EndSection Info ]]

}

local _singleton: Core = {}

local g_events: EventMapping = {}
local g_connections: ConnectionMapping = {}
local g_listeners: ListenerMapping = {}
local g_pipes: PipeMapping = {}

local Core = {}
Core.__index = Core

local CoreEventPipe: RemoteEvent = nil


local function checkIfInit()
    if _singleton.initialized then
        return true
    else
        UninitializedObjectException.new("Core is not initialized!")
        return false
    end
end

local function registerDefaults(core: Core)

    dbg("register default events...")
    dbg("events to register: ")
    dbg("   game.Players.PlayerAdded            ==> playerAdded")
    dbg("   game.Players.PlayerRemoving         ==> playerRemoving")
    dbg("   UserSettings().GameSettings.Changed ==> clientGameSettings")

    core
        :registerEvent("playerAdded", Players.PlayerAdded)
        :registerEvent("playerRemoving", Players.PlayerRemoving)
        :registerEvent("clientGameSettings", UserSettings().GameSettings.Changed)

    if game:GetService('RunService'):IsServer() then
        dbg("register special server side events")
        dbg("events to register: ")
        dbg("   game.Loaded                         ==> serverLoaded")
        dbg("   #internal[serverClosing]            ==> serverClosing")

        -- special register for serverClose
        local Bindable = Instance.new("BindableEvent")
        core
            :registerEvent("serverLoaded", game.Loaded)
            :registerEvent("serverClosing", Bindable.Event)

        game:BindToClose(function()
            Bindable:Fire()
        end)
    end

    dbg(`register default pipes`)
    dbg("   PplayerAdded")
    dbg("   PplayerRemoving")
    dbg("   sendServerChatMessage")
    core
        :registerPipe("PplayerAdded")
        :registerPipe("PplayerRemoving")
        :registerPipe("sendServerChatMessage")

    core:addEventListener("playerAdded", function(plr: Player)
        -- send to pipe...
        core:dispatchEvent("PplayerAdded",plr)
    end)

    core:addEventListener("playerRemoving", function(plr: Player)
        -- send to pipe...
        core:dispatchEvent("PplayerRemoving",plr)
    end)
end

local function LENGTH(t: { [any]: any})
    local index = 0

    for _, _ in t do
        index += 1
    end

    return index
end

local dumpsGenerated = 0
local dumpsDisabled = false
function Core.generateDump(self: Core): dump.CoreDump
    dbg(`[*] a dump was just requested...`)
    --dbg(`[*] It is advised you do not generate a lot of core dumps, as they take up a lot of memory.`)
    
    if not config.global.doCoreDumps or dumpsDisabled then
        CoreDumpsDisabledException.new(
            "attempted to generate a core dump while dumping core is prohibitted! returning 'nil' dump..."
        )
        return dump.dumps["{00000000-0000-0000-0000-000000000000}"]
    end

    local GUID = HttpService:GenerateGUID(true)
    local TIME = DateTime.now():ToIsoDate()

    -- put [*] in front cause dumps are kinda important
    dbg(`[*] generating a dump at {TIME}... (guid={GUID})`)

    local DUMP: dump.CoreDump = {
        dumpGuid = GUID,
        dumpTime = TIME,

        pipesCreated = LENGTH(self._pipes),
        pipes = self._pipes,

        connectionsCreated = LENGTH(self._connections),
        connections = self._connections,

        eventsCreated = LENGTH(self._events),
        events = self._events,

        listenersCreated = LENGTH(self._listeners),
        listeners = self._listeners

    }
    dumpsGenerated += 1

    dbg(`[*] Saving this dump to the runtime dumps table...`)
    table.insert(dump.dumps,DUMP)
    dump.latestDumpGuid = GUID

    if dumpsGenerated > 5 then
        warn('[!] It is advised you stop generating dumps as they take up a lot of memory. (dumpsGenerated > 5)')
    end
    if dumpsGenerated > 25 then
        dumpsDisabled = true
        -- so the user can actually see it
        warn(`[!] ***** Dumps were just disabled to save memory. *****`)
    end

    return DUMP
end

function Core.get(): Core
    return _singleton
end

function Core.init(): Core
    if _singleton.initialized then
        AlreadyInitializedException.new("Core is already initialized!")
        return
    end
    CoreEventPipe = ReplicatedStorage.Shared.rblx_oop.runtime:FindFirstChild('CoreEventPipe') :: RemoteEvent?
    if not CoreEventPipe then
        local bridge = Instance.new("RemoteEvent")
        bridge.Name = "CoreEventPipe"
        bridge.Parent = ReplicatedStorage.Shared.rblx_oop.runtime

        CoreEventPipe = bridge
        dbg(`Created CoreEventPipe RemoteEvent...`)
    end

    _singleton = setmetatable({
        initialized = true,
        _events = g_events :: EventMapping,
        _connections = g_connections :: ConnectionMapping,
        _listeners = g_listeners :: ListenerMapping,
        _pipes = g_pipes :: PipeMapping,
    }, Core)

    dbg("initialized Core singleton")
    _singleton.initialized = true

    dbg("registering default events...")
    registerDefaults(_singleton)
    
    -- listen for events on client
    if not RunService:IsClient() then
        return _singleton
    end

    if CoreEventPipe then
        CoreEventPipe.OnClientEvent:Connect(function(ev: string, ...)
            local listeners = _singleton._listeners[ev]
            if listeners then
                for _, fn in ipairs(listeners) do
                    task.spawn(function(...)
                        local ok, err = pcall(fn,...)
                        if not ok then
                            warn(`[Core/ERROR] client event: {ev} failed: {err}`)
                        end
                    end,...)
                end
            end
            dbg(`received remote event: {ev}`)
        end)
    end


    return _singleton
end

function Core.registerPipe(self: Core, name: string)
    local remote: RemoteEvent = ReplicatedStorage.Shared.rblx_oop.runtime.core.pipes:FindFirstChild(`pipe_{name}`)

    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = `pipe_{name}`
        remote.Parent = ReplicatedStorage.Shared.rblx_oop.runtime.core.pipes
    end

    if RunService:IsServer() then
        self:registerEvent(name, remote.OnServerEvent)
    elseif RunService:IsClient() then
        self:registerEvent(name, remote.OnClientEvent)
    end

    self._pipes[name] = remote
    return self
end

function Core.registerEvent(self: Core,name: string,signal: RBXScriptSignal): Core
    if not checkIfInit() then return end

    if typeof(signal) ~= "RBXScriptSignal" then
        InvalidArgumentException.new(`registerEvent expects RBXScriptSignal, got {typeof(signal)}`,`signal`)
        return
    end

    if self._events[name] then
        AlreadyCreatedException.new(`event {name} is already registered!`)
        return
    end

    self._events[name] = signal
    self._connections[name] = {}

    dbg(`registered an event: {name}`)

    return self
end

function Core.unregisterEvent(self: Core, name: string): Core
    if not checkIfInit() then return end

    local connections = self._connections[name]
    if connections then
        for _, conn in ipairs(connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
    end

    self._events[name] = nil
    self._connections[name] = nil

    dbg(`unregistered an event: {name}`)

    return self
end

function Core.addEventListener(self: Core, event: string, listener: (any) -> (), options: (EventListenerOptions | boolean)?): Core
    if not checkIfInit() then return end

    
    local ev = self._events[event]
    if not ev then
        UninitializedObjectException.new(`tried to listen to an unregistered event: {event}`)
        return _singleton
    end

    self._listeners[event] = self._listeners[event] or {}
    table.insert(self._listeners[event],listener)

    local once = false
    if type(options) == "table" then
        once = options.once == true
    elseif type(options) == "boolean" then
        once = options
    end

    local connection
    connection = ev:Connect(function(...)
        listener(...)
        if once then
            for i, fn in ipairs(g_listeners[event]) do
                if fn == listener then
                    table.remove(g_listeners[event],i)
                    break
                end
            end
            connection:Disconnect()
        end
    end)
    
    self._connections[event] = self._connections[event] or {}
    table.insert(self._connections[event], connection)

    dbg(`new event listener for {event}`)

    return _singleton
end

function Core.dispatchEvent(self: Core,event: string, ...): Core
    if not checkIfInit() then return _singleton end

    local listeners = self._listeners[event] or {}

    for _, listener in ipairs(listeners) do
        task.spawn(function(...)
            local ok, err = pcall(listener,...)
            if not ok then
                warn(`[Core/ERROR] dispatchEvent {event}: {err}`)
            end
        end,...)
    end

    if RunService:IsServer() and CoreEventPipe then
        CoreEventPipe:FireAllClients(event,...)
    end

    dbg(`dispatched event: {event}`)

    return _singleton
end

function Core.waitForEvent(self: Core, event: string)
    if not self.initialized then
        UninitializedObjectException.new(`Core is not initialized, cannot wait for event {event}...`)
        return nil
    end

    local ev = self._events[event]
    if not ev then
        UninitializedObjectException.new(`tried to wait for an unregistered event: {event}`)
        return nil
    end

    return ev:Wait()
end

function Core.info(): Info
    return Info.new()
end

function Core._DEBUG()
    print(_singleton)
end

return Core