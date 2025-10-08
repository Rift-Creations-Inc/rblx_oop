local HttpService = game:GetService("HttpService")

local remotefn = game.ReplicatedStorage.Shared.rblx_oop.runtime.CommandExecutive

function getArgs(cmd: string): {string}
    local args = {}

    for match in cmd:gmatch('"(.-)"') do
		table.insert(args, match)
	end

    local noQuotes = cmd:gsub(`"(.-)"`,"")

    for match in noQuotes:gmatch("%S+") do
        table.insert(args,match)
    end

    return args
end

function onRecv(plr: Player,cmd: string)
    local args = getArgs(cmd)
    print(`{cmd} ==> {HttpService:JSONEncode(args)}`)
    for i,v in script.Commands:GetChildren() do
        if v.Name == args[1] then
            local ok, result = pcall(function()
                return require(v)(plr,args)
            end)
            if ok then
                return result
            else
                warn(`[Command Error] {result}`)
                return {
                    success = false,
                    message = "error executing command: "..tostring(result)
                }
            end
        end
    end

    return {
        success = false,
        message = "Command not found."
    }
end

remotefn.OnServerInvoke = onRecv