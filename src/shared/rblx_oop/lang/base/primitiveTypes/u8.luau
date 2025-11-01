
export type u8 = number & {
    _check: (
        self: u8
    ) -> never
}

local function isU8(n: number): boolean
    return type(n) == "number" and n >= 0 and n <= 255 and math.floor(n) == n
end

local function new(value: number): u8
    assert(isU8(value),`Value {value} is not a valid u8 (0-255 integer)`)
    local ret: u8 = value
    function ret._check(self: u8)
        if isU8(self) then return end

        error(`u8 is not u8!`)
    end
    return 
end

return new