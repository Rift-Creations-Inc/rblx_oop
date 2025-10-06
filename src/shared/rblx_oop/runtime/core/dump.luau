local HttpService = game:GetService("HttpService")

HttpService:GenerateGUID()

type MappedString<V> = { [string]: V }

type EventMapping = MappedString<RBXScriptSignal>
type ConnectionMapping = MappedString<{ RBXScriptConnection }>
type ListenerMapping = MappedString<{ (...any) -> () }>
type PipeMapping = MappedString<string>

export type CoreDump = {
    dumpGuid: string,
    dumpTime: string,

    pipesCreated: number,
    pipes: PipeMapping,

    connectionsCreated: number,
    connections: ConnectionMapping,

    eventsCreated: number,
    events: EventMapping,

    listenersCreated: number,
    listeners: ListenerMapping
}

local DUMP: { 
    latestDumpGuid: string,
    dumps: { 
        [string]: CoreDump 
    }
} = {
    latestDumpGuid = "{00000000-0000-0000-0000-000000000000}", -- nil GUID

    dumps = {
        -- the "nil" dump is static and always exists
        ["{00000000-0000-0000-0000-000000000000}"] = {
            dumpGuid = "{00000000-0000-0000-0000-000000000000}",
            dumpTime = "",

            pipesCreated = 0,
            pipesList = nil,

            connectionsCreated = 0,
            connections = nil,

            eventsCreated = 0,
            events = nil,

            listenersCreated = 0,
            listeners = nil
        }

    },
}



return DUMP