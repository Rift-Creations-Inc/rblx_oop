local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()

repeat
    task.wait()
until Core.initialized

local AssemblyChat = {}

--
local RbxSystem: TextChannel = game.TextChatService:WaitForChild('TextChannels'):WaitForChild('RBXSystem')

local COLOR_ERR = Color3.fromRGB(255, 85, 85):ToHex()
local COLOR_OUT = Color3.fromRGB(255, 255, 255):ToHex()
local COLOR_DBG = Color3.fromRGB(102, 102, 102):ToHex()

local function sendMessage(color: string, msg: string)
    print(`[AssemblyChat] {msg}`)
	RbxSystem:DisplaySystemMessage(`<font color="#{color}">[AssemblyChat] {msg}</font>`)
end

local function sendMessageRaw(msg: string)
    RbxSystem:DisplaySystemMessage(msg)
end

export type regs_t = {
    rax: number | string,
    rbx: number | string,
    rcx: number | string,
    rdx: number | string,
    rsi: number | string,
    rdi: number | string,
    rbp: number | string,
    rsp: number | string,
    r8:  number | string,
    r9:  number | string,
    r10: number | string,
    r11: number | string,
    r12: number | string,
    r13: number | string,
    r14: number | string,
    r15: number | string,
}

local regs: regs_t = {
    rax = 0,
    rbx = 0,
    rcx = 0,
    rdx = 0,
    rsi = 0,
    rdi = 0,
    rbp = 0,
    rsp = 0,
    
    r8 = 0,
    r9 = 0,
    r10 = 0,
    r11 = 0,
    r12 = 0,
    r13 = 0,
    r14 = 0,
    r15 = 0,
}

local function ASM_ERR(msg: string)
    sendMessage(COLOR_ERR, msg)
end

local function ASM_OUT(msg: string)
    sendMessage(COLOR_OUT, msg)
end

local function ASM_DBG(msg: string)
    sendMessage(COLOR_DBG, `debug: {msg}`)
end

-- based on syscall write

local function getRegNumber(name: string)
    local val = regs[name:lower()]
    if type(val) ~= "number" then
        ASM_ERR(`Register {name} does not contain a number!`)
        return nil
    end
    return val
end



local function parseInstruction(line: string?): (string?, {string})
	if not line or line == "" then
		return nil, {}
	end

	-- Explicitly cast to string so Luau stops complaining
	local text = (line :: string)

	-- Trim whitespace
	text = text:match("^%s*(.-)%s*$") :: string
	if text == "" then
		return nil, {}
	end

	local opcode, argstr = (text :: string):match("^(%S+)%s*(.*)$")
	if not opcode then
		return nil, {}
	end

	local args = {}
	if argstr and #argstr > 0 then
        for token in string.gmatch(argstr, "[^,]+") do
			token = token:match("^%s*(.-)%s*$") :: string
			table.insert(args, token)
		end
	end

	return opcode:upper(), args
end


local Instructions = {}

-------
-- Arithmetic
-------

function Instructions.ADD(args: {string})
    local dst, src = args[1], args[2]
    if not dst or src then
        ASM_ERR("ADD expects 2 arguments!")
        return
    end
    local dstVal = getRegNumber(dst)
    if not dstVal then return end

    local srcVal = tonumber(src) or getRegNumber(src)
    if not srcVal then
        ASM_ERR(`Unable to find number value for {src}`)
        return
    end

    regs[dst:lower()] = dstVal + srcVal
end

function Instructions.SUB(args: {string})
    local dst, src = args[1], args[2]
    if not dst or src then
        ASM_ERR("SUB expects 2 arguments!")
        return
    end
    local dstVal = getRegNumber(dst)
    if not dstVal then return end

    local srcVal = tonumber(src) or getRegNumber(src)
    if not srcVal then
        ASM_ERR(`Unable to find number value for {src}`)
        return
    end

    regs[dst:lower()] = dstVal - srcVal
end

function Instructions.MUL(args: {string})
    local dst, src = args[1], args[2]
    if not dst or src then
        ASM_ERR("ADD expects 2 arguments!")
        return
    end
    local dstVal = getRegNumber(dst)
    if not dstVal then return end

    local srcVal = tonumber(src) or getRegNumber(src)
    if not srcVal then
        ASM_ERR(`Unable to find number value for {src}`)
        return
    end

    regs[dst:lower()] = dstVal * srcVal
end

function Instructions.DIV(args: {string})
    local dst, src = args[1], args[2]
    if not dst or src then
        ASM_ERR("ADD expects 2 arguments!")
        return
    end
    local dstVal = getRegNumber(dst)
    if not dstVal then return end

    local srcVal = tonumber(src) or getRegNumber(src)
    if not srcVal then
        ASM_ERR(`Unable to find number value for {src}`)
        return
    end

    regs[dst:lower()] = dstVal / srcVal
end

function Instructions.INC(args: {string})
    local regName = args[1]
    if not regName then
        ASM_ERR("INC expects one argument!")
        return
    end

    local val = regs[regName:lower()]
    if type(val) ~= "number" then
        ASM_ERR(`Register {regName} does not contain a number!`)
        return
    end

    regs[regName:lower()] = val + 1
end

function Instructions.DEC(args: {string})
    local regName = args[1]
    if not regName then
        ASM_ERR("DEC expects one argument!")
        return
    end

    local val = regs[regName:lower()]
    if type(val) ~= "number" then
        ASM_ERR(`Register {regName} does not contain a number!`)
        return
    end

    regs[regName:lower()] = val - 1
end

function Instructions.MOV(args: {string})
    local dst = args[1]
    local src = args[2]
    if not dst or not src then
        ASM_ERR("MOV expects two arguments!")
        return
    end

    dst = dst:lower()

    if regs[dst] == nil then
        ASM_ERR(`Unable to find register {dst}`)
        return
    end

    -- number
    local numVal = tonumber(src)
    if numVal ~= nil then
        regs[dst] = numVal
        return
    end

    -- string in quotes
    local strVal = src:match('^"(.*)"$') or src:match("^'(.*)'$")
    if strVal then
        regs[dst] = strVal
        return
    end

    -- copy from another register
    if regs[src:lower()] ~= nil then
        regs[dst] = regs[src:lower()]
    else
        ASM_ERR(`Unable to find register or value {src}`)
    end
end

function Instructions.AND(args: {string})
    local dst, src = args[1], args[2]
    if not dst or not src then
        ASM_ERR("AND expects two arguments!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    local srcVal = tonumber(src) or tonumber(regs[src:lower()])

    if not dstVal or not srcVal then
        ASM_ERR("AND requires numeric operands!")
        return
    end

    regs[dst:lower()] = bit32.band(dstVal,srcVal)
end

-- OR dst, src
function Instructions.OR(args: {string})
    local dst, src = args[1], args[2]
    if not dst or not src then
        ASM_ERR("OR expects two arguments!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    local srcVal = tonumber(src) or tonumber(regs[src:lower()])

    if not dstVal or not srcVal then
        ASM_ERR("OR requires numeric operands!")
        return
    end

    regs[dst:lower()] = bit32.bor(dstVal,srcVal)
end

-- XOR dst, src
function Instructions.XOR(args: {string})
    local dst, src = args[1], args[2]
    if not dst or not src then
        ASM_ERR("XOR expects two arguments!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    local srcVal = tonumber(src) or tonumber(regs[src:lower()])

    if not dstVal or not srcVal then
        ASM_ERR("XOR requires numeric operands!")
        return
    end

    regs[dst:lower()] = bit32.band(dstVal,srcVal)
end

-- NOT dst
function Instructions.NOT(args: {string})
    local dst = args[1]
    if not dst then
        ASM_ERR("NOT expects one argument!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    if not dstVal then
        ASM_ERR("NOT requires a numeric operand!")
        return
    end

    regs[dst:lower()] = bit32.bnot(dstVal)
end

-- SHL dst, amount
function Instructions.SHL(args: {string})
    local dst, amt = args[1], tonumber(args[2])
    if not dst or not amt then
        ASM_ERR("SHL expects two arguments!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    if not dstVal then
        ASM_ERR("SHL requires a numeric operand!")
        return
    end

    regs[dst:lower()] = bit32.lshift(dstVal, amt)
end

-- SHR dst, amount
function Instructions.SHR(args: {string})
    local dst, amt = args[1], tonumber(args[2])
    if not dst or not amt then
        ASM_ERR("SHR expects two arguments!")
        return
    end

    local dstVal = tonumber(regs[dst:lower()])
    if not dstVal then
        ASM_ERR("SHR requires a numeric operand!")
        return
    end

    regs[dst:lower()] = bit32.rshift(dstVal, amt)
end

function Instructions.SYSCALL(_: {string})
    local function sys_write()
        local fd: number = (regs.rdi :: number)
        local buf: string = (regs.rsi :: string)
        local size: number = (regs.rdx :: number)
        
        local output = string.sub(buf, 1, size)
        
        if fd == 1 then
            sendMessageRaw(`stdout: {output}`)
            elseif fd == 2 then
                print(`tty1: {output}`)
            end
        end
        
        local function sys_exit()
            local err_code: number = (regs.rdi :: number)
            ASM_OUT(`Local player invoked SYS_EXIT. Kicking them...`)
            game:GetService('Players').LocalPlayer:Kick(`SYS_EXIT Invoked: {err_code}`)
        end
        
        -- rax=1 = SYS_WRITE
    if regs.rax == 1 then 
        ASM_DBG("Invoking SYS_WRITE....")
        sys_write() 
        return 
    end

    if regs.rax == 60 then
        ASM_DBG("Invoking SYS_EXIT...")
        sys_exit()
    end

    ASM_ERR("Unknown or unrecognized syscall: RAX="..regs.rax)
end

function Instructions._DUMPREGS(_: {string})
    for k,v in pairs(regs) do
        ASM_OUT(`_DUMPREGS: {k:upper()}: {v}`)
    end
end

function Instructions._PRINT(args: {string})
    local dst = args[1]
    if not dst then
        ASM_ERR("_PRINT expects one argument!")
        return
    end

    ASM_OUT(`_PRINT: {dst:upper()}={regs[dst:lower()]}`)
end

function Instructions.NOP(_: {string})
    return
end

function AssemblyChat:start()
    print("hi")
    ASM_OUT("Assembly chat started")
    Core:addEventListener("localPlayerChatted", function(msg: string,_)
        local opcode, args = parseInstruction(msg)
        if not opcode then return end

        local handler = Instructions[opcode]
        if handler then
            handler(args)
        else
            ASM_ERR(`Unsupported or unknown instruction: {opcode}`)
        end
    end)

    return
end

return AssemblyChat