local Result = require(script.Parent.Result)

local Ok = Result.Ok
local Err = Result.Err

type Result<T, E> = Result.Result<T, E>

local function safefn<R, A...>(f: (A...) -> R): Result<R,string>
    local ok, ret = pcall(f)

    if not ok then
        Err(ret)
    elseif ok then
        Ok(ret)
    end
end

return safefn