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

export type Callback<S,T...> = (self: S, T...) -> ()
export type EventCallbacks<T> = {
    onHover: Callback<T,number,number>,
    onHoverLost: Callback<T,number,number>,
    onMouseMoved: Callback<T,number,number>
}

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


    --[[ @Callbacks ]]
    events: EventCallbacks<Drawable>?,

    doConnectEvents: (
        self: Drawable
    ) -> (),


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

function Drawable.doConnectEvents(self: Drawable)
    if not self._instance then return end
    local inst = self._instance
    local events = self.events
    if not events then return end

    dbg(`connecting default Drawable evens... (id={self.id})`)

    if inst:IsA("GuiObject") then
        if inst.MouseEnter and events.onHover then
            inst.MouseEnter:Connect(function(x,y)
                events:onHover(x or 0, y or 0)
            end)
        end

        if inst.MouseLeave and events.onHoverLost then
            inst.MouseLeave:Connect(function(x,y)
                events:onHoverLost(x or 0, y or 0)
            end)
        end

        if inst.MouseMoved and events.onMouseMoved then
            inst.MouseMoved:Connect(function(x,y)
                events:onMouseMoved(x or 0, y or 0)
            end)
        end
    end
end

--[[ @OverrideMe ]]
function Drawable:render()
    error(`This method is marked as @OverrideMe, subclasses need to implement this. (Drawable.render)`)

    -- before returning
    -- self:_connectEvents() should be caleld
end

function Drawable.destroy(self: Drawable)
    dbg(`destroying Drawable... (id={self.id})`)
    if self._instance then
        self._instance:Destroy()
        self._instance = nil
    end
end

return Drawable