--!strict
-- If bitbuffer is so good, why isn't there a bitbuffer 2?

local MASKS = table.create(32)
local TWO_POWS = table.create(32)
for i = 1, 32 do
    MASKS[i] = (2 ^ i) - 1
    TWO_POWS[i] = 2 ^ (i - 1)
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

    -- Fast track for if we're writing for the first time in a given word
    if bitsInWord == 0 then
        if width == 32 then
            buffer[pntr] = word
        else
            buffer[pntr] = bit32.lshift(word, 32 - width)
        end
    else
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
            bit32.rshift(buffer[pntr + 1], readable)
        )
    end
end

--- Writes `word` as a signed integer that is `width` bits wide to the buffer.
---
--- @param width The size of `word` in bits. Must be in the range [1, 32].
--- @param word The value that will be written to the buffer.
function BitBuffer.writeInt(self: BitBuffer, width: number, word: number)
    if word >= 0 then
        self:writeUInt(width, word)
    else
        -- There is likely a more efficient way to do this, but I don't know it
        -- Something something (!word + 1) | 2^(width - 1)
        self:writeUInt(width, bit32.bor(TWO_POWS[width], TWO_POWS[width] + word))
    end
end

--- Reads a `width` bit signed integer from the buffer.
--- If attempting to read past the end of the buffer, an error will be raised.
---
--- @param width The size of the number to read from the buffer. Must be in the range [1, 32].
---
--- @return The read number
function BitBuffer.readInt(self: BitBuffer, width: number): number
    local n = self:readUInt(width)
    if bit32.btest(n, TWO_POWS[width]) then
        -- n is a negative number
        return -(bit32.bnot(n) + 1)
    else
        return bit32.band(n, MASKS[width - 1])
    end
end

--- Writes a standard 32-bit floating point number to the buffer.
--- Due to limitations with Luau, negative 0 is not supported and the bits
--- of NaNs are not preserved but it otherwise handes special cases as expected.
---
--- @param float The number to write to the buffer
function BitBuffer.writeFloat32(self: BitBuffer, float: number)
    -- "Welcome to the salty spatoon, how tough are ya?"
    -- "I write floats to a binary stream"
    -- "So?"
    -- "By decomposing them."
    -- "Oh uh, right this way."

    local bias = 0x7F -- 32-bit floats have a bias of 127
    local is_neg = float < 0
    float = math.abs(float)

    local mantissa, exponent = math.frexp(float)

    -- This is a raw implementation of serializing floats that works
    -- via packing the values into a 32 bit integer
    -- The initial state is only the sign bit
    local written = if is_neg then 0x8000_0000 else 0x0000_0000
    if float == math.huge then
        -- infinity with no sign bit, so that we respect the sign
        written = bit32.bor(written, 0x7F80_0000)
    elseif float ~= float then
        -- Arbitrary nan
        written = 0xFF80_1337
    elseif float == 0 then
        written = 0
    elseif exponent + bias <= 1 then
        written = bit32.bor(written, math.floor(mantissa * 2 ^ 23 + 0.5))
    else
        written = bit32.bor(written, bit32.lshift(exponent + bias - 1, 23), math.floor((mantissa - 0.5) * 2 ^ 24 + 0.5))
    end
    self:writeUInt(32, written)
end

--- Reads a 32-bit floating point number from the buffer and returns it.
--- If attempting to read past the end of the buffer, an error will be raised.
---
--- @return The float read from the buffer
function BitBuffer.readFloat32(self: BitBuffer): number
    local read = self:readUInt(32)
    local sign = bit32.btest(read, 0x8000_0000)
    local exponent = bit32.band(bit32.rshift(read, 23), MASKS[8])
    local mantissa = bit32.band(read, MASKS[23])

    local bias = 0x7F

    if exponent == 0xFF then
        -- This is either infinity or nan
        if mantissa ~= 0 then
            return 0 / 0
        else
            return sign and -math.huge or math.huge
        end
    elseif exponent == 0 then
        -- This is either 0 or a subnormal number
        if mantissa == 0 then
            return 0
        else
            return if sign then -math.ldexp(mantissa / 2 ^ 23, -bias + 1) else math.ldexp(mantissa / 2 ^ 23, -bias + 1)
        end
    else
        return if sign
            then -math.ldexp((mantissa / 2 ^ 23) + 1, exponent - bias)
            else math.ldexp((mantissa / 2 ^ 23) + 1, exponent - bias)
    end
end

function BitBuffer.writeString(self: BitBuffer, str: string)
    local len = #str
    self:writeUInt(24, len)
    local offset = 1
    local word: number
    for _ = 1, len / 4 do
        word, offset = string.unpack(">I4", str, offset)
        self:writeUInt(32, word)
    end
    if len % 4 ~= 0 then
        local accum = 0
        for i = -(len % 4), -1 do
            accum = bit32.bor(bit32.lshift(accum, 8), string.byte(str, i))
        end
        self:writeUInt((len % 4) * 8, accum)
    end
end

function BitBuffer.readString(self: BitBuffer): string
    local len = self:readUInt(24)
    local size = math.floor(len / 4)
    local bytes = table.create(size + len % 4)
    local read
    for i = 1, size do
        read = self:readUInt(32)
        bytes[i] = string.char(
            bit32.extract(read, 24, 8),
            bit32.extract(read, 16, 8),
            bit32.extract(read, 8, 8),
            bit32.extract(read, 0, 8)
        )
    end
    for i = 1, len % 4 do
        bytes[size + i] = string.char(self:readUInt(8))
    end

    return table.concat(bytes)
end

-- local b = BitBuffer.new()
-- b:writeString("12345")
-- b:writeFloat32(10)
-- print(b:dumpHex())
-- b:setPointer(0)
-- print(b:readString())
-- print(b:readFloat32())

return BitBuffer
