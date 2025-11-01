local IRunnable = require(script.IRunnable)
local Result = require(script.Result)
local Safe = require(script.Safe)
local String = require(script.String)


return Safe({
    module = "lang::base",

    IRunnable = IRunnable,
    Result = Result,
    Safe = Safe,
    String = String,
})