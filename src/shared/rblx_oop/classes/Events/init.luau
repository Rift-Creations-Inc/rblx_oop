
local Players = game:GetService('Players')
--[[ @StaticClass @FinalClass ]]
local Events = {
    Player = {
        Removing = Players.PlayerRemoving,
        Added = Players.PlayerAdded
    }
}
Events.__index = Events

return table.freeze(Events)