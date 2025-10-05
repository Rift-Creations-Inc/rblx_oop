local RuntimeException = require(script.Parent)

type RuntimeException = RuntimeException.RuntimeException

export type HttpException = RuntimeException & {
    statusCode: number?,
    url: string?,
    method: string,
    responseBody: string?,

    --[[ @Override ]]
    toString: (
        self: HttpException
    ) -> string
}

local HttpException = setmetatable({}, RuntimeException)
HttpException.__index = HttpException
setmetatable(HttpException, { __index = RuntimeException})

function HttpException.toString(self: HttpException): string
    local base = RuntimeException.toString(self)
    local extra = ""

    if self.statusCode then
        extra ..= ` (status={self.statusCode})`
    end
    if self.method or self.url then
        extra ..= ` [{self.method or '?'} {self.url or ''}]`
    end

    return base .. extra
end

function HttpException.new(message: string, statusCode: number?, url: string?, method: string?, responseBody: string?): HttpException
    local self: HttpException = RuntimeException.new(message) :: any
    self.name = "HttpException"
    self.statusCode = statusCode
    self.url = url
    self.method = method
    self.responseBody = responseBody
end