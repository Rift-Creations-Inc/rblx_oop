local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThreadException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.ThreadException)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local ResourceT = require(ReplicatedStorage.Shared.rblx_oop.lang.ResourceT)
local Option = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Option)
local Result = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Result)
local Safe = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Safe)
local SafeFn = require(ReplicatedStorage.Shared.rblx_oop.lang.base.SafeFn)
local String = require(ReplicatedStorage.Shared.rblx_oop.lang.base.String)
local NonZero = require(ReplicatedStorage.Shared.rblx_oop.lang.base.primitiveTypes.NonZero)
local Parker = require(ReplicatedStorage.Shared.rblx_oop.lang.sync.Parker)
local SimpleRng = require(ReplicatedStorage.Shared.rblx_oop.util.SimpleRng)

local function _dbgt(x: string)
    if not config.global.debugThreads then return end
    print(`[lang::thread::Thread/DEBUG] {x}`)
end

local function _dbgb(x: string)
    if not config.global.debugThreads then return end
    print(`[lang::thread::Thread::Builder/DEBUG] {x}`)
end

local Some = Option.Some
local None = Option.None

local CountedResource = ResourceT.CountedResource.new

type NonZero<T> = NonZero.NonZero<T>
type Option<T> = Option.Option<T>
type CountedResource<T> = ResourceT.CountedResource<T>
type String = String.String
type Parker = Parker.Parker

export type ThreadId = NonZero<number>

------ Thread
export type Inner = {
    name: Option<string>,
    id: ThreadId,
    _parker: Parker,

    parker: (
        self: Parker
    ) -> Parker
}

export type Thread = {
    inner: CountedResource<Inner>,

    park: (
        self: Thread
    ) -> Thread,

    unpark: (
        self: Thread
    ) -> Thread,

    id: (
        self: Thread
    ) -> ThreadId,

    name: (
        self: Thread
    ) -> String,

    join: (
        self: Thread
    ) -> Thread
} & {
    _task: thread?,
    _result: any?
}

------ Builder
export type Builder = {
    _name: Option<String>,
    _onExcept: Option<(self: Thread,string) -> ()>,

    name: (
        self: Builder, 
        n: string
    ) -> Builder,

    spawn: (
        self: Builder,
        fn: () -> any
    ) -> Thread,

    except: (
        self: Builder,
        f: (string) -> ()
    ) -> Builder
}

------ Thread

local Builder = {
    _typeName = "lang::thread::Thread::Builder"
}
Builder.__index = Builder

local Thread = {
    _typePath = "lang::thread::Thread",
    Builder = Builder
}
Thread.__index = Thread

function Thread.new(id: ThreadId, _name: Option<String>): Thread
    local name = _name.isSome and _name:unwrap():asStr() or "unnamed"

    local inner: Inner = {
        name = Some( name ),
        id = id,
        _parker = Parker.new(),

        parker = function(self: Inner)
            return self._parker
        end
    }
    _dbgt(`new Thread: id={id}, name={name}`)

    return setmetatable({
        inner = CountedResource(inner),
        _task = nil,
        _result = nil
    },Thread)
end


function Thread.park(self: Thread): Thread
    _dbgt(`parking thread`)
    self.inner:get():parker():park()

    return self
end

function Thread.unpark(self: Thread): Thread
    _dbgt(`unparking thread`)
    self.inner:get():parker():unpark()

    return self
end

function Thread.id(self: Thread): number
    return self.inner:get().id
end

function Thread.name(self: Thread): String
    return String.from(self.inner:get().name:unwrap())
end

function Thread.join(self: Thread): Thread
    _dbgt(`joining thread...`)
    self:park()
    return self
end

------ Builder

local BuilderImpl = {}
BuilderImpl.__index = BuilderImpl


function BuilderImpl.name(self: Builder, n: string): Builder
    self._name = Some(String.from(n))
    
    return self
end

function BuilderImpl.except(self: Builder, fn: (string) -> ()): Builder
    self._onExcept = Some(fn)

    return self
end

function BuilderImpl.spawn(self: Builder, fn: () -> any): Thread
    _dbgb(`spawning new thread`)
    local _id = SimpleRng.new(1042):nextInt()
    local id = NonZero(_id)
    local thread = Thread.new(id,self._name)

    local co = coroutine.create(function()
        local ok, res = pcall(fn)
        if not ok then
            if self._onExcept.isSome then
                self._onExcept:unwrap()(thread,res)
            else
                warn(`[ThreadBuilder] raising ThreadException`)
                ThreadException.new(`ThreadBuilder: unhandled exception in Thread {self._name:unwrapOr("unnamed")}: {res}`)
            end
        else
            thread._result = Result
        end
        thread:unpark()
    end)

    thread._task = co
    task.spawn(function()
        coroutine.resume(co)
    end)

    return thread
end

function Builder.new(): Builder
    _dbgb(`new builder...`)
    return setmetatable({
        _name = None,
        _onExcept = None
    }, BuilderImpl)
end

function Thread.spawn(f: () -> (),name: string?): Thread
    name = name or "unnamed"

    return Builder.new()
        :name(name)
        :spawn(f)
end

Safe(Thread)
Safe(Builder)
Safe(BuilderImpl)

return Thread