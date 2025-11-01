local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiagnosticAnnotations = require(ReplicatedStorage.Shared.rblx_oop.lang.DiagnosticAnnotations)


return function(plr: Player,args: { string })
    DiagnosticAnnotations
        :UNUSED_PARAMATER(plr)
        :UNUSED_PARAMATER(args)
        
    print("******* ping")
    return {
        message = "got",
        success = true
    }
end