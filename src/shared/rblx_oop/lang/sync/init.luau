local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Safe = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Safe)
local Mutex = require(script.Mutex)
local OnceLock = require(script.OnceLock)
local RwLock = require(script.RwLock)

return Safe({
    module = "lang::sync",

    Mutex = Mutex,
    RwLock = RwLock,
    OnceLock = OnceLock
})