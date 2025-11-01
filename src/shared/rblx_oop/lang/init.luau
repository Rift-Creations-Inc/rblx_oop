local DiagnosticAnnotations = require(script.DiagnosticAnnotations)
local ResourceT = require(script.ResourceT)
local SimpleIterator = require(script.SimpleIterator)
local SimpleList = require(script.SimpleList)
local base = require(script.base)
local debugNatives = require(script.debugNatives)
local sync = require(script.sync)

local Safe = require(script.base.Safe)

return Safe({
    module = "lang",

    DiagnosticAnnotations = DiagnosticAnnotations,
    ResourceT = ResourceT,
    SimpleIterator = SimpleIterator,
    SimpleList = SimpleList,
    debugNatives = debugNatives,
    base = base,
    sync = sync
})