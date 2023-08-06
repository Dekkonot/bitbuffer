--!strict
-- If bitbuffer is so good, why isn't there a bitbuffer 2?

local function printf(fmt: string, ...: any)
    print(string.format(fmt, ...))
end

local BitBuffer = {}
BitBuffer.__index = BitBuffer

type BitBuffer = typeof(setmetatable({} :: {
    buffer: { number },
    size: number,
    pntr: number,
}, BitBuffer))

--- Returns a new `BitBuffer` instance, optionally placing `source` inside of it
function BitBuffer.new(): BitBuffer
    local self = {
        --- The words stored within the bitbuffer
        buffer = { 0 },
        --- The size of the buffer in bits
        size = 0,
        --- The place (in bits) that the buffer is being written and read from
        pntr = 0,
    }

    setmetatable(self, BitBuffer)

    return self
end

--- Dumps the internal buffer as a sequence of 8-bit hexadecimal digits.
--- Useful for debugging the contents of the buffer. This does not trim
--- any excess bits from the final word, so it will not be 100% accurate
--- to the 'true' contents of the buffer.
---
--- @return A sequence of hexadecimal octets
function BitBuffer.dumpHex(self: BitBuffer): string
    local bytes = table.create(math.ceil(self.size / 32))
    for i, v in self.buffer do
        bytes[i] = string.format(
            "%02x %02x %02x %02x",
            bit32.extract(v, 24, 8),
            bit32.extract(v, 16, 8),
            bit32.extract(v, 8, 8),
            bit32.extract(v, 0, 8)
        )
    end

    -- TODO fast string concatenation
    return table.concat(bytes, " ")
end

--- Writes an unsigned number `word` to the buffer, assuming it to be `width`
--- bits in size.
---
--- @param width The size of `word` in bits. Must be in the range [1, 32].
--- @param word The value that will be written to the buffer.
function BitBuffer.writeUInt(self: BitBuffer, width: number, word: number)
    local buffer = self.buffer
    local rawPntr = self.pntr
    -- Lua is 1 based, not 0
    local pntr = math.floor(rawPntr / 32) + 1
    local bitsInWord = rawPntr % 32
    print(`raw: {rawPntr}, pntr: {pntr}, bits: {bitsInWord}`)
    printf("word: %08x, width: %d, new width: %d", word, width, bitsInWord + width)

    --- The current word we're writing to
    local current = buffer[pntr] or 0
    --- How many bits can we put in current word
    local remainingBits = 32 - bitsInWord
    -- Happy days, we can just stuff `word` into the current word
    if remainingBits >= width then
        buffer[pntr] = bit32.bor(current, bit32.lshift(word, remainingBits - width))
        printf("no new, %08x becomes %08x", current, buffer[pntr])
    else
        --- How many bits
        local excess = width - remainingBits
        -- Pack `remainingBits` bits of `word` into the buffer
        buffer[pntr] = bit32.bor(current, bit32.rshift(word, excess))
        printf(`wrote {remainingBits} to pointer, left us with {excess}`)
        -- Pack `width - remainingBits` bits of word into a new byte
        buffer[pntr + 1] = bit32.lshift(word, 32 - excess)
        printf("new, %08x becomes %08x and %08x", current, buffer[pntr], buffer[pntr + 1])
    end

    self.size += width
    self.pntr += width
end

-- Reads `width` bits from the buffer. If attempting to read past the end of
-- the buffer, an error will be raised.
function BitBuffer.readUInt(self: BitBuffer, width: number): number
    error("unimplemented", 2)
end

local b = BitBuffer.new()

b:writeUInt(8, 0x17)
b:writeUInt(8, 0x16)
b:writeUInt(8, 0x15)
b:writeUInt(24, 0x141312)
b:writeUInt(8, 0x11)
b:writeUInt(8, 0x10)
b:writeUInt(8, 0x09)
b:writeUInt(4, 0x0)
b:writeUInt(4, 0x8)
print(b:dumpHex())

return BitBuffer
