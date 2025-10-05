local config = require(game:GetService('ReplicatedStorage').Shared.rblx_oop.config)

local function dbg(txt: string)
    if not config.client.debugGraphics then return end
    print(`[Graphics2D] {txt}`)
end

--[[ @Implements Drawable ]]

local Players = game:GetService('Players')
local Drawable = require(script.Parent.Drawable)
local RunService = game:GetService('RunService')

type Drawable = Drawable.Drawable
type DrawableOptions = Drawable.DrawableOptions
type DrawableInstance = Drawable.DrawableInstance

export type Graphics2D = {
    _gui: ScreenGui,
    _drawnObjects: { Drawable },

    new: (
        name: string?
    ) -> Graphics2D,

    addDrawable: (
        self: Graphics2D,
        drawable: Drawable,
        parent: Instance?
    ) -> (),

    clear: (
        self: Graphics2D
    ) -> (),

    hide: (
        self: Graphics2D
    ) -> (),

    show: (
        self: Graphics2D
    ) -> (),

    id: number
}

local Graphics2D = {}
Graphics2D.__index = Graphics2D

function Graphics2D.new(name: string?): Graphics2D
    local self = {} :: Graphics2D
    self.id = math.random(1,100)

    local gui = Instance.new("ScreenGui")
    gui.Name = `Graphics2D/{name}` or `Graphics2D/MAIN`
    gui.ResetOnSpawn = false

    dbg(`new Graphics2D, name="{gui.Name}" (id={self.id})`)

    if RunService:IsClient() then
        gui.Parent = Players.LocalPlayer:WaitForChild('PlayerGui')
    else
        gui.Parent = game:GetService('CoreGui')
    end

    self._gui = gui
    self._drawnObjects = {} :: { Drawable }

    return setmetatable(self, Graphics2D)
end

function Graphics2D.addDrawable(self: Graphics2D, drawable: Drawable, parent: Instance?)
    dbg(`adding Drawable (drawable id={drawable.id}) (id={self.id})`)

    local targetParent = parent or self._gui
    local instance = drawable:render(targetParent)
    drawable._instance = instance

    table.insert(self._drawnObjects, drawable)
end

function Graphics2D.show(self: Graphics2D)
    dbg(`showing objects inside Drawable (id={self.id})`)
    for _, obj in ipairs(self._drawnObjects) do
        obj._instance.Visible = true
    end
end

function Graphics2D.hide(self: Graphics2D)
    dbg(`hiding objects inside Drawable (id={self.id})`)
    for _, obj in ipairs(self._drawnObjects) do
        obj._instance.Visible = false
    end
end

function Graphics2D.clear(self: Graphics2D)
    dbg(`clearing out Drawable (id={self.id})`)
    for _, obj in ipairs(self._drawnObjects) do
        obj:destroy()
    end
    self._drawnObjects = {}
end

return Graphics2D