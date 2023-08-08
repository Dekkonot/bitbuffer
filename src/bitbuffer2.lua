--!strict
-- If bitbuffer is so good, why isn't there a bitbuffer 2?

local MASKS = table.create(32)
for i = 1, 32 do
    MASKS[i] = (2 ^ i) - 1
end

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

--- Sets the internal pointer to bit number `n`.
---
--- @param n The place in bits to set the pointer to
function BitBuffer.setPointer(self: BitBuffer, n: number)
    self.pntr = n
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
    self.size += width
    self.pntr += width

    --- The current word we're writing to
    local current = buffer[pntr] or 0
    --- How many bits can we put in current word
    local remainingBits = 32 - bitsInWord
    -- Happy days, we can just stuff `word` into the current word
    if remainingBits >= width then
        buffer[pntr] = bit32.bor(current, bit32.lshift(word, remainingBits - width))
    else
        --- How many bits we're putting into the next word
        local excess = width - remainingBits
        -- Pack `remainingBits` bits of `word` into the buffer
        buffer[pntr] = bit32.bor(current, bit32.rshift(word, excess))
        -- Pack `width - remainingBits` bits of word into a new byte
        buffer[pntr + 1] = bit32.lshift(word, 32 - excess)
    end
end

--- Reads `width` bits from the buffer. If attempting to read past the end of
--- the buffer, an error will be raised.
---
--- @param width The size of the number to read from the buffer. Must be in the range [1, 32].
---
--- @return The read number
function BitBuffer.readUInt(self: BitBuffer, width: number): number
    local buffer = self.buffer
    local rawPntr = self.pntr
    -- Lua is 1 based, not 0
    local pntr = math.floor(rawPntr / 32) + 1
    self.pntr += width

    --- The word we're reading from
    local current = buffer[pntr]
    --- The number of bits from `current` that can be read
    local readable = 32 - (rawPntr % 32)
    if readable >= width then
        return bit32.rshift(bit32.band(current, MASKS[readable]), readable - width)
    else
        local excess = width - readable
        return bit32.bor(
            -- Mask out any bits more significant than what we're reading
            -- and then move them up so the second word fits
            bit32.lshift(bit32.band(current, MASKS[readable]), excess),
            -- Shift out the LSBs from the new word because they're not necessary
            bit32.rshift(buffer[pntr + 1], excess)
        )
    end
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
print("--------------------------")
b:setPointer(0)
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(24))
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(8))
printf("%08x", b:readUInt(4))
printf("%08x", b:readUInt(4))

return BitBuffer
