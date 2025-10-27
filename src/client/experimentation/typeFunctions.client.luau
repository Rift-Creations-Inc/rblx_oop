local HttpService = game:GetService("HttpService")
-- Function that returns the names of component types
type function getComponents<T>(t: T): {string}
    local tbl: {string} = {}
    for _, comp in ipairs(types.copy(t):components()) do
        table.insert(tbl, types.copy(comp):name())
    end
    return tbl
end

-- Define some types
type t = {
    read r: number
}

type v = t & {
    write w: string
}

-- Use reflection
local v_names: getComponents<v> = {}

print(HttpService:JSONEncode(v_names))  -- just printing the table reference
for _, name in ipairs(v_names) do
    print(name) -- prints each component type's name
end
