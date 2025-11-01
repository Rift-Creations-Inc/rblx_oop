local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local Throwable = require(script.Parent)

export type Error = Throwable.Throwable & {
    isFatal: true
}

local Error = setmetatable({}, Throwable)
Error.__index = Error
setmetatable(Error, { __index = Throwable} )

--[[ @Override ]]
function Error.printStackTrace(self: Error)
    local scr = Graphics2D.new("errorScreen")
    
    
    warn(self:toString())
    local txt: string = `{self:toString()}\n`
    for _, v in self.stacktrace:toStringArray() do
        txt ..= `\t{v}`
    end

    local text = Text.new({
        text = `{txt}`,
        textXalign = Enum.TextXAlignment.Left,
        pos = Vector2.new(.5,.5),
        size = 18,
        backgroundColor = Color3.fromRGB(0,0,0),
        richText = true,
        color = Color3.fromRGB(255, 131, 131)
    })

    scr:addDrawable(text)

    -- do this so the user can clearly see it
    task.wait(5)

    text:destroy()
    scr:destroy()

end

function Error.new(message: string) : Error
    local self: Error = Throwable.new("Error", message)
    self.isFatal = true
    return setmetatable(self, Error)
end

return Error