
local DiagnosticAnnotations = {}
DiagnosticAnnotations.__index = DiagnosticAnnotations

function DiagnosticAnnotations.UNUSED_PARAMATER(x: any): nil
    print(`[DiagnosticAnnotations::UNUSED_PARAMETER] unused: {tostring(x)}`)
    x = nil

    return DiagnosticAnnotations
end


return DiagnosticAnnotations