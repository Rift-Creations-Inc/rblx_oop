local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local function dbg(txt: string)
    if not config.client.debugGraphics then return end
    print(`[Drawable] {txt}`)
end

export type DrawableOptions = {
    pos: Vector2?,
    anchor: Vector2?,
}

export type DrawableInstance = Instance?

export type Drawable = {
    --[[ @OverrideMe ]]
    render: (
        self: Drawable, 
        parent: Instance
    ) -> Instance,

    --[[ @ImplementInSubclass ]]
    destroy: (
        self: Drawable
    ) -> (),

    position: Vector2,
    anchor: Vector2,

    id: number,

    _instance: DrawableInstance,
}

local Drawable = {}
Drawable.__index = Drawable

function Drawable.new(options: DrawableOptions?): Drawable
    local self = {} :: Drawable
    self.position = options and options.pos or Vector2.new(0,0)
    self.anchor = options and options.pos or Vector2.new(0,0)
    self._instance = nil
    self.id = math.random(50000)

    dbg(`created new Drawable... (id={self.id})`)

    return setmetatable(self, Drawable)
end

--[[ @OverrideMe ]]
function Drawable:render()
    error(`This method is marked as @OverrideMe, subclasses need to implement this. (Drawable.render)`)
end

function Drawable.destroy(self: Drawable)
    dbg(`destroying Drawable... (id={self.id})`)
    if self._instance then
        self._instance:Destroy()
        self._instance = nil
    end
end

return Drawable