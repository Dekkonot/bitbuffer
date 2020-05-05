local BASE64_CHAR_SET = { [0] =
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/",
}

local HEX_TO_BIN = {
    ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
    ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
    ["8"] = "1000", ["9"] = "1001", ["a"] = "1010", ["b"] = "1011",
    ["c"] = "1100", ["d"] = "1101", ["e"] = "1110", ["f"] = "1111",
}

local BOOL_TO_BIT = { [true] = 1, [false] = 0, }

local CRC32_POLYNOMIAL = 0xedb88320

local crc32_poly_lookup = {}
for i = 0, 255 do
    local crc = i
    for _ = 1, 8 do
        local mask = -bit32.band(crc, 1)
        crc = bit32.bxor(bit32.rshift(crc, 1), bit32.band(CRC32_POLYNOMIAL, mask))
    end
    crc32_poly_lookup[i] = crc
end

local powers_of_2 = {}
for i = 0, 64 do
    powers_of_2[i] = 2^i
end

local function bitBuffer(stream)
    if stream ~= nil then
        assert(type(stream) == "string", "argument to BitBuffer constructor must be either nil or a string")
    end
    
    -- The bit buffer works by keeping an array of bytes, a 'final' byte, and how many bits are currently in that last byte
    -- Bits are not kept track of on their own, and are instead combined to form a byte, which is stored in the last space in the array.
    -- This byte is also stored seperately, so that table operations aren't needed to read or modify its value.
    -- The byte array is called `bytes`. The last byte is stored in `lastByte`. The bit counter is stored in `bits`.

    local bits = 0 -- How many free floating bits there are.
    local bytes = {}--! -- Array of bytes currently in the buffer
    local lastByte = 0 -- The most recent byte in the buffer, made up of free floating bits

    local byteCount = 0 -- This variable keeps track of how many bytes there are total in the bit buffer.
    local bitCount = 0 -- This variable keeps track of how many bytes there are total in the bit buffer

    local pointer = 0 -- This variable keeps track of what bit the read functions start at
    local pointerByte = 1 -- This variable keeps track of what byte the pointer is at. It starts at 1 since the byte array starts at 1.

    if stream then
        byteCount = #stream
        bitCount = byteCount*8

        for i = 1, byteCount do
            bytes[i] = string.byte(stream, i, i)
        end
    end

    local function dumpBinary()
        -- This function is for debugging or analysis purposes. 
        -- It dumps the contents of the byte array and the remaining bits into a string of binary digits.
        -- Thus, bytes [97, 101] with bits [1, 1, 0] would output "01100001 01100101 110"
        local output = {}--!
        for i, v in ipairs(bytes) do
            output[i] = string.gsub(string.format("%02x", v), "%x", HEX_TO_BIN)
        end
        if bits ~= 0 then
            -- Because the last byte (where the free floating bits are stored) is in the byte array, it has to be overwritten.
            output[byteCount] = string.sub(output[byteCount], 1, bits)
        end

        return table.concat(output, " ")
    end

    local function dumpString()
        -- This function is for accessing the total contents of the bitbuffer.
        -- This function combines all the bytes, including the last byte, into a string of binary data.
        -- Thus, bytes [97, 101] and bits [1, 1, 0] would become (in hex) "0x61 0x65 0x06"
        local output = {}--!
        for i, v in ipairs(bytes) do
            output[i] = string.char(v)
        end

        return table.concat(output, "")
    end

    local function dumpHex()
        -- This function is for getting the hex of the bitbuffer's contents, should that be desired
        local output = {}--!
        for i, v in ipairs(bytes) do
            output[i] = string.format("%02x", v)
        end

        return table.concat(output, "")
    end

    local function dumpBase64()
        -- Base64 is a safe and easy way to convert binary data to be entirely printable
        -- It works on the principle that groups of 3 bytes (24 bits) can evenly be divided into 4 groups of 6
        -- And 2^6 is a mere 64, far less than the number of printable characters.
        -- If there are any missing bytes, `=` is added to the end as padding.
        -- Base64 increases the size of its input by 33%.
        local output = {}--!

        local c = 1
        for i = 1, byteCount, 3 do
            local b1, b2, b3 = bytes[i], bytes[i+1], bytes[i+2]
            local packed = bit32.lshift(b1, 16)+bit32.lshift(b2 or 0, 8)+(b3 or 0)
            
            -- This can be done with bit32.extract (and/or bit32.lshift, bit32.band, bit32.rshift)
            -- But this is more elegant in my opinion
            output[c] = BASE64_CHAR_SET[bit32.rshift(bit32.band(packed, 16515072), 18)] -- 111111000000000000000000
            output[c+1] = BASE64_CHAR_SET[bit32.rshift(bit32.band(packed, 258048), 12)] -- 000000111111000000000000
            output[c+2] = b2 and BASE64_CHAR_SET[bit32.rshift(bit32.band(packed, 4032), 6)] or "=" -- 000000000000111111000000
            output[c+3] = b3 and BASE64_CHAR_SET[bit32.band(packed, 63)] or "=" -- 000000000000000000111111

            c = c+4
        end

        return table.concat(output, "") --todo swap to fast table.concat method
    end

    local function crc32()
        local crc = 0xffffffff -- 2^32
        
        for _, v in ipairs(bytes) do
            local poly = crc32_poly_lookup[bit32.band(bit32.bxor(crc, v), 255)]
            crc = bit32.bxor(bit32.rshift(crc, 8), poly)
        end

        return bit32.bnot(crc)%0xffffffff -- 2^32
    end

    local function adler32()
        -- This is a checksum algorithm. It's used in zlib, which is likely to come up while processing binary data.

        local a = 1
        local b = 0

        -- The numbers here seem magical. They are not.
        -- The Adler-32 checksum uses the prime 65521. This is the largest prime smaller than 2^16.
        -- 5552 is the maximum number of bytes that can be processed before modulo is required.
        -- Assuming a and b are both 65520 (one less than the prime) and all the data processed has been 0xff,
        -- b will be 4294690200 (below 2^32). Another cycle and it will be well over 2^32.
        -- source: https://software.intel.com/en-us/articles/fast-computation-of-adler32-checksums
        for i = 1, byteCount, 5553 do
            for j = 0, 5552 do
                local byte = bytes[i+j]
                if not byte then
                    break
                end
                a = a+byte
                b = b+a
            end
            a = a%65521
            b = b%65521
        end

        return bit32.lshift(b, 16)+a
    end

    local function getPointer()
        -- This function gets the value of the pointer. This is self-explanatory.
        return pointer
    end

    local function setPointer(n)
        assert(type(n) == "number", "argument #1 to BitBuffer.setPointer should be a number")
        assert(n >= 0, "argument #1 to BitBuffer.setPointer should be a number")
        assert(n%1 == 0, "argument #1 to BitBuffer.setPointer should be a number")
        -- This function sets the value of pointer. This is self-explanatory.
        pointer = n
    end

    local function writeBits(...)
        -- The first of two main functions for the actual 'writing' of the bitbuffer.
        -- This function takes a vararg of 1s and 0s and writes them to the buffer.
        local bitN = select("#", ...)
        if bitN == 0 then
            return false
        end
        bitCount = bitCount+bitN
        local packed = table.pack(...)
        for _, v in ipairs(packed) do
            assert(v == 1 or v == 0, "arguments to writeBits should be either 1 or 0")
            if bits == 0 then -- If the bit count is 0, increment the byteCount
                -- This is the case at the beginning of the buffer as well as when the the buffer reaches 7 bits,
                -- so it's done at the beginning of the loop.
                byteCount = byteCount+1
            end
            lastByte = lastByte+(v == 1 and powers_of_2[7-bits] or 0) -- Add the current bit to lastByte, from right to left
            bits = bits+1
            if bits == 8 then -- If the bit count is 8, set it to 0, write lastByte to the byte list, and set lastByte to 0
                bits = 0
                bytes[byteCount] = lastByte
                lastByte = 0
            end
        end
        if bits ~= 0 then -- If there are some bits in lastByte, it has to be put into lastByte
            -- If this is done regardless of the bit count, there might be a trailing zero byte
            bytes[byteCount] = lastByte
        end
        return true
    end

    local function writeByte(n)
        assert(type(n) == "number", "argument #1 to BitBuffer.writeByte should be a number")
        assert(n >= 0 and n <= 255, "argument #1 to BitBuffer.writeByte should be in the range [0, 255]")
        assert(n%1 == 0, "argument #1 to BitBuffer.writeByte should be an integer")
        -- The second of two main functions for the actual 'writing' of the bitbuffer.
        -- This function takes a byte (an 8-bit integer) and writes it to the buffer.
        if bits == 0 then
            -- If there aren't any free-floating bits, this is easy.
            byteCount = byteCount+1
            bytes[byteCount] = n
        else
            local nibble = bit32.rshift(n, bits) -- Shift `bits` number of bits out of `n` (they go into the aether)
            bytes[byteCount] = lastByte+nibble -- Manually set the most recent byte to the lastByte + the front part of `n`
            byteCount = byteCount+1
            lastByte = bit32.band(bit32.lshift(n, 8-bits), 255) -- Shift `n` forward `8-bits` and get what remains in the first 8 bits
            bytes[byteCount] = lastByte
        end
        bitCount = bitCount+8 -- Increment the bit counter
        return true
    end

    local function writeUnsigned(width, n)
        assert(type(width) == "number", "argument #1 to BitBuffer.writeUnsigned should be a number")
        assert(width >= 1 and width <= 64, "argument #1 to BitBuffer.writeUnsigned should be in the range [1, 64]")
        assert(width%1 == 0, "argument #1 to BitBuffer.writeUnsigned should be an integer")

        assert(type(n) == "number", "argument #2 to BitBuffer.writeUnsigned should be a number")
        assert(n >= 0 and n <= powers_of_2[width]-1, "argument #2 to BitBuffer.writeUnsigned is out of range")
        assert(n%1 == 0, "argument #2 to BitBuffer.writeUnsigned should be an integer")
        -- Writes unsigned integers of arbitrary length to the buffer.
        -- This is the first function that uses other functions in the buffer to function.
        -- This is done because the space taken up would be rather large for very little performance gain.

        -- Get the number of bytes and number of floating bits in the specified width
        local bytesInN, bitsInN = math.floor(width/8), width%8
        local extractedBits = {}--!

        -- If the width is less than or equal to 32-bits, bit32 can be used without any problem.
        if width <= 32 then
            -- Counting down from the left side, the bytes are written to the buffer
            local c = width
            for _ = 1, bytesInN do
                c = c-8
                writeByte(bit32.extract(n, c, 8))
            end
            -- Any remaining bits are stored in an array
            for i = bitsInN-1, 0, -1 do
                extractedBits[bitsInN-i] = BOOL_TO_BIT[bit32.btest(n, powers_of_2[i])]
            end
            -- Said array is then used to write them to the buffer
            writeBits(table.unpack(extractedBits))

            return true
        else
            -- If the width is greater than 32, the number has to be divided up into a few 32-bit or less numbers
            local leastSignificantChunk = n%0x100000000 -- Get bits 0-31 (counting from the right side). 0x100000000 is 2^32.
            local mostSignificantChunk = math.floor(n/0x100000000) -- Get any remaining bits by manually right shifting by 32 bits

            local c = width-32 -- The number of bits in mostSignificantChunk is variable, but a counter is still needed
            for _ = 1, bytesInN-4 do -- 32 bits is 4 bytes
                c = c-8
                writeByte(bit32.extract(mostSignificantChunk, c, 8))
            end
            -- `bitsInN` is always going to be the number of spare bits in `mostSignificantChunk`
            -- which comes before `leastSignificantChunk`
            for i = bitsInN-1, 0, -1 do
                extractedBits[bitsInN-i] = BOOL_TO_BIT[bit32.btest(mostSignificantChunk, powers_of_2[i])]
            end
            writeBits(table.unpack(extractedBits))

            for i = 3, 0, -1 do -- Then of course, write all 4 bytes of leastSignificantChunk
                writeByte(bit32.extract(leastSignificantChunk, i*8, 8))
            end

            return true
        end
    end

    local function writeSigned(width, n)
        assert(type(width) == "number", "argument #1 to BitBuffer.writeSigned should be a number")
        assert(width >= 2 and width <= 64, "argument #1 to BitBuffer.writeSigned should be in the range [2, 64]")
        assert(width%1 == 0, "argument #1 to BitBuffer.writeSigned should be an integer")

        assert(type(n) == "number", "argument #2 to BitBuffer.writeSigned should be a number")
        assert(n >= -powers_of_2[width-1] and n <= powers_of_2[width-1]-1, "argument #2 to BitBuffer.writeSigned is out of range")
        assert(n%1 == 0, "argument #2 to BitBuffer.writeSigned should be an integer")
        -- Writes signed integers of arbitrary length to the buffer.
        -- These integers are stored using two's complement.
        -- Essentially, this means the first bit in the number is used to store whether it's positive or negative
        -- If the number is positive, it's stored normally.
        -- If it's negative, the number that's stored is equivalent to the max value of the width + the number
        if n >= 0 then
            writeBits(0)
            writeUnsigned(width-1, n) -- One bit is used for the sign, so the stored number's width is actually width-1
        else
            writeBits(1)
            writeUnsigned(width-1, powers_of_2[width-1]+n)
        end
        return true
    end

    local function writeFloat(exponentWidth, mantissaWidth, n)
        assert(type(exponentWidth) == "number", "argument #1 to BitBuffer.writeFloat should be a number")
        assert(exponentWidth >= 1 and exponentWidth <= 64, "argument #1 to BitBuffer.writeFloat should be in the range [1, 64]")
        assert(exponentWidth%1 == 0, "argument #1 to BitBuffer.writeFloat should be an integer")
        
        assert(type(mantissaWidth) == "number", "argument #2 to BitBuffer.writeFloat should be a number")
        assert(mantissaWidth >= 1 and mantissaWidth <= 64, "argument #2 to BitBuffer.writeFloat should be in the range [1, 64]")
        assert(mantissaWidth%1 == 0, "argument #2 to BitBuffer.writeFloat should be an integer")

        assert(type(n) == "number", "argument #3 to BitBuffer.writeFloat should be a number")

        -- Given that floating point numbers are particularly hard to grasp, this function is annotated heavily.
        -- This stackoverflow answer is a great help if you just want an overview:
        -- https://stackoverflow.com/a/7645264
        -- Essentially, floating point numbers are scientific notation in binary.
        -- Instead of expressing numbers like 10^e*m, floating points instead use 2^e*m.
        -- For the sake of this function, `e` is referred to as `exponent` and `m` is referred to as `mantissa`.

        -- Floating point numbers are stored in memory as a sequence of bitfields.
        -- Every float has a set number of bits assigned for exponent values and mantissa values, along with one bit for the sign.
        -- The order of the bits in the memory is: sign, exponent, mantissa.

        -- Given that floating points have to represent numbers less than zero as well as those above them,
        -- some parts of the exponent are set aside to be negative exponents. In the case of floats,
        -- this is about half of the values. To calculate the 'real' value of an exponent a number that's half of the max exponent
        -- is added to the exponent. More info can be found here: https://stackoverflow.com/q/2835278
        -- This number is called the 'bias'.
        local bias = powers_of_2[exponentWidth-1]-1

        local sign = n < 0 -- The sign of a number is important.
        -- In this case, since we're using a lookup table for the sign bit, we want `sign` to indicate if the number is negative or not.
        n = math.abs(n) -- But it's annoying to work with negative numbers and the sign isn't important for decomposition.

        -- Lua has a function specifically for decomposing (or taking apart) a floating point number into its pieces.
        -- These pieces, as listed above, are the mantissa and exponent.
        local mantissa, exponent = math.frexp(n)

        -- Before we go further, there are some concepts that get special treatment in the floating point format.
        -- These have to be accounted for before normal floats are written to the buffer.

        if n == math.huge then
            -- Positive and negative infinities are specifically indicated with an exponent that's all 1s
            -- and a mantissa that's all 0s.
            writeBits(BOOL_TO_BIT[sign]) -- As previously said, there's a bit for the sign
            writeUnsigned(exponentWidth, powers_of_2[exponentWidth]-1) -- Then comes the exponent
            writeUnsigned(mantissaWidth, 0) -- And finally the mantissa
            return true
        elseif n ~= n then
            -- NaN is indicated with an exponent that's all 1s and a mantissa that isn't 0.
            -- In theory, the individual bits of NaN should be maintained but Lua doesn't allow that,
            -- so the mantissa is just being set to 10 for no particular reason.
            writeBits(BOOL_TO_BIT[sign])
            writeUnsigned(exponentWidth, powers_of_2[exponentWidth]-1)
            writeUnsigned(mantissaWidth, 10)
            return true
        elseif n == 0 then
            -- Zero is represented with an exponent that's zero and a mantissa that's also zero.
            -- Lua doesn't have a signed zero, so that translates to the entire number being all 0s.
            writeUnsigned(exponentWidth+mantissaWidth+1, 0)
            return true
        elseif exponent+bias <= 1 then
            -- Subnormal numbers are an number thats exponent (when biased) is zero.
            -- Because of a quirk with the way Lua and C decompose numbers, subnormal numbers actually have an exponent of one when biased.

            -- The process behind this is explained below, so for the sake of brevity it isn't explained here.
            -- The only difference between processing subnormal and normal numbers is with the mantissa
            -- As subnormal numbers always start with a 0 (in binary), it doesn't need to be removed or shifted out
            -- so it's a simple shift and round.
            mantissa = math.floor(mantissa * powers_of_2[mantissaWidth] + 0.5)

            writeBits(BOOL_TO_BIT[sign])
            writeUnsigned(exponentWidth, 0) -- Subnormal numbers always have zero for an exponent
            writeUnsigned(mantissaWidth, mantissa)
            return true
        end

        -- In every normal case, the mantissa of a number will have a 1 directly after the decimal point (in binary).
        -- As an example, 0.15625 has a mantissa of 0.625, which is 0.101 in binary. The 1 after the decimal point is always there.
        -- That means that for the sake of space efficiency that can be left out.
        -- The bit has to be removed. This uses subtraction and multiplication to do it since bit32 is for integers only.
        -- The mantissa is then shifted up by the width of the mantissa field and rounded.
        mantissa = math.floor( (mantissa-0.5) * 2 * powers_of_2[mantissaWidth] + 0.5)
        -- (The first fraction bit is equivalent to 0.5 in decimal)

        -- After that, it's just a matter of writing to the stream:
        writeBits(BOOL_TO_BIT[sign])
        writeUnsigned(exponentWidth, exponent+bias-1) -- The bias is added to the exponent to properly offset it
        -- The extra -1 is added because Lua, for whatever reason, doesn't normalize its results
        -- This is the cause of the 'quirk' mentioned when handling subnormal number
        -- As an example, math.frexp(0.15625) = 0.625, -2
        -- This means that 0.15625 = 0.625*2^-2
        -- Or, in binary: 0.00101 = 0.101 >> 2
        -- This is a correct statement but the actual result is meant to be:
        -- 0.00101 = 1.01 >> 3, or 0.15625 = 0.625*2^-3
        -- A small but important distinction that has made writing this module frustrating because no documentation notates this.
        writeUnsigned(mantissaWidth, mantissa)
        return true
    end

    local function writeString(str)
        assert(type(str) == "string", "argument #1 to BitBuffer.writeString  should be a string")
        -- The default mode of writing strings is length-prefixed.
        -- This means that the length of the string is written before the contents of the string.
        -- For the sake of speed it has to be an even byte.
        -- One and two bytes is too few characters (255 bytes and 65535 bytes respectively), so it has to be higher.
        -- Three bytes is roughly 16.77mb, and four is roughly 4.295gb. Given this is Lua and is thus unlikely to be processing strings
        -- that large, this function uses three bytes, or 24 bits for the length

        writeUnsigned(24, #str)

        for i = 1, #str do
            writeByte(string.byte(str, i, i))
        end

        return true
    end

    local function writeTerminatedString(str)
        assert(type(str) == "string", "argument #1 to BitBuffer.writeTerminatedString should be a string")
        -- This function writes strings that are null-terminated.
        -- Null-terminated strings are strings of bytes that end in a 0 byte (\0)
        -- This isn't the default because it doesn't allow for binary data to be written cleanly.

        for i = 1, #str do
            writeByte(string.byte(str, i, i))
        end
        writeByte(0)

        return true
    end

    local function writeSetLengthString(str)
        assert(type(str) == "string", "argument #1 to BitBuffer.writeSetLengthString should be a string")
        -- This function writes strings as a pure string of bytes
        -- It doesn't store any data about the length of the string,
        -- so reading it requires knowledge of how many characters were stored

        for i = 1, #str do
            writeByte(string.byte(str, i, i))
        end

        return true
    end

    local function writeBools(...)
        -- This is equivalent to having a writeBitfield function.
        -- It combines all of the passed 'bits' into an unsigned number, then writes it.
        local field = 0
        local bools = table.pack(...)
        for i = 1, bools.n do
            field = field*2 -- Shift `field`. Equivalent to field<<1. At the beginning of the loop to avoid an extra shift.

            local v = bools[i]
            if v then
                field = field+1 -- If the bit is truthy, turn it on (it defaults to off so it's fine to not have a branch)
            end
        end

        writeUnsigned(bools.n, field)

        return true
    end

    local function readBits(n)
        assert(type(n) == "number", "argument #1 to readBits should be a number")
        assert(n > 0, "argument #1 to readBits should be greater than zero")
        assert(n%1 == 0, "argument #1 to readBits should be an integer")

        assert(pointer+n <= bitCount, "readBits cannot read past the end of the stream")

        if pointer+n > bitCount then return false end
        -- The first of two main functions for the actual 'reading' of the bitbuffer.
        -- Reads `n` bits and returns an array of their values.
        local output = {}--!
        local byte = bytes[pointerByte] -- For the sake of efficiency, the current byte that the bits are coming from is stored
        local c = pointer%8 -- A counter is set with the current position of the pointer in the byte
        for i = 1, n do
            -- Then, it's as easy as moving through the bits of the byte
            -- And getting the individiual bit values
            local pow = powers_of_2[7-c]
            output[i] = BOOL_TO_BIT[bit32.btest(byte, pow)] -- Test if a bit is on by &ing it by 2^[bit position]
            c = c+1
            if c == 8 then -- If the byte boundary is reached, increment pointerByte and store the new byte in `byte`
                pointerByte = pointerByte+1
                byte = bytes[pointerByte]
                c = 0
            end
        end
        pointer = pointer+n -- Move the pointer forward
        return output
    end

    local function readByte()
        assert(pointer+8 <= bitCount, "readByte cannot read past the end of the stream")
        -- The second of two main functions for the actual 'reading' of the bitbuffer.
        -- Reads a byte and returns it
        local c = pointer%8 -- How far into the pointerByte the pointer is
        local byte1 = bytes[pointerByte] -- The pointerByte
        pointer = pointer+8
        if c == 0 then -- Trivial if the pointer is at the beginning of the pointerByte
            pointerByte = pointerByte+1
            return byte1
        else
            pointerByte = pointerByte+1
            -- Get the remainder of the first pointerByte and add it to the part of the new pointerByte that's required
            -- Both these methods are explained in writeByte
            return bit32.band(bit32.lshift(byte1, c), 255)+bit32.rshift(bytes[pointerByte], 8-c)
        end
    end

    local function readUnsigned(width)
        assert(type(width) == "number", "argument #1 to BitBuffer.readUnsigned should be a number")
        assert(width >= 1 and width <= 64, "argument #1 to BitBuffer.readUnsigned should be in the range [1, 64]")
        assert(width%1 == 0, "argument #1 to BitBuffer.readUnsigned should be an integer")

        assert(pointer+width <= bitCount, "readUnsigned cannot read past the end of the stream")
        -- Implementing this on its own was considered because of a worry that it would be inefficient to call
        -- readByte and readBit several times, but it was decided the simplicity is worth a minor performance hit.
        local bytesInN, bitsInN = math.floor(width/8), width%8

        -- No check is required for if the width is greater than 32 because bit32 isn't used.
        local n = 0
        -- Shift and add a read byte however many times is necessary
        -- Adding after shifting is importnat - it prevents there from being 8 empty bits of space
        for _ = 1, bytesInN do
            n = n*0x100 -- 2^8; equivalent to n << 8
            n = n+readByte()
        end
        -- The bits are then read and added to the number
        if bitsInN ~= 0 then
            for _, v in ipairs(readBits(width%8)) do --todo benchmark against concat+tonumber; might be worth the code smell
                n = n*2
                n = n+v
            end
        end
        return n
    end

    local function readSigned(width)
        assert(type(width) == "number", "argument #1 to BitBuffer.readSigned should be a number")
        assert(width >= 2 and width <= 64, "argument #1 to BitBuffer.readSigned should be in the range [2, 64]")
        assert(width%1 == 0, "argument #1 to BitBuffer.readSigned should be an integer")
        
        assert(pointer+8 <= bitCount, "readSigned cannot read past the end of the stream")
        local sign = readBits(1)[1]
        local n = readUnsigned(width-1) -- Again, width-1 is because one bit is used for the sign

        -- As said in writeSigned, the written number is unmodified if the number is positive (the sign bit is 0)
        if sign == 0 then
            return n
        else
            -- And the number is equal to max value of the width + the number if the number is negative (the sign bit is 1)
            -- To reverse that, the max value is subtracted from the stored number.
            return n-powers_of_2[width-1]
        end
    end

    local function readFloat(exponentWidth, mantissaWidth)
        assert(type(exponentWidth) == "number", "argument #1 to BitBuffer.readFloat should be a number")
        assert(exponentWidth >= 1 and exponentWidth <= 64, "argument #1 to BitBuffer.readFloat should be in the range [1, 64]")
        assert(exponentWidth%1 == 0, "argument #1 to BitBuffer.readFloat should be an integer")
        
        assert(type(mantissaWidth) == "number", "argument #2 to BitBuffer.readFloat should be a number")
        assert(mantissaWidth >= 1 and mantissaWidth <= 64, "argument #2 to BitBuffer.readFloat should be in the range [1, 64]")
        assert(mantissaWidth%1 == 0, "argument #2 to BitBuffer.readFloat should be an integer")

        assert(pointer+exponentWidth+mantissaWidth+1 <= bitCount, "readFloat cannot read past the end of the stream")
        -- Recomposing floats is rather straightfoward.
        -- The bias is subtracted from the exponent, the mantissa is shifted back by mantissaWidth, one is added to the mantissa
        -- and the whole thing is recomposed with math.ldexp (this is identical to mantissa*(2^exponent)).

        local bias = powers_of_2[exponentWidth-1]-1

        local sign = readBits(1)[1]
        local exponent = readUnsigned(exponentWidth)
        local mantissa = readUnsigned(mantissaWidth)

        -- Before normal numbers are handled though, special cases and subnormal numbers are once again handled seperately
        if exponent == powers_of_2[exponentWidth]-1 then
            if mantissa ~= 0 then -- If the exponent is all 1s and the mantissa isn't zero, the number is NaN
                return 0/0
            else -- Otherwise, it's positive or negative infinity
                return sign == 0 and math.huge or -math.huge
            end
        elseif exponent == 0 then
            if mantissa == 0 then -- If the exponent and mantissa are both zero, the number is zero.
                return 0
            else -- If the exponent is zero and the mantissa is not zero, the number is subnormal

                -- Subnormal numbers are straightforward: shifting the mantissa so that it's a fraction is all that's required
                mantissa = mantissa/powers_of_2[mantissaWidth]

                -- Since the exponent is 0, it's actual value is just -bias (it would be exponent-bias)
                -- As previously touched on in writeFloat, the exponent value is off by 1 in Lua though.
                return sign == 1 and -math.ldexp(mantissa, (-bias)+1) or math.ldexp(mantissa, (-bias)+1)
            end
        end

        -- First, the mantissa is shifted back by the mantissaWidth
        -- Then, 1 is added to it to 'normalize' it.
        mantissa = (mantissa/powers_of_2[mantissaWidth])+1

        -- Because the mantissa is normalized above (the leading 1 is in the ones place), it's accurate to say exponent-bias
        return sign == 1 and -math.ldexp(mantissa, exponent-bias) or math.ldexp(mantissa, exponent-bias)
    end

    local function readString()
        assert(pointer+24 <= bitCount, "readString cannot read past the end of the stream")
        -- Reading a length-prefixed string is rather straight forward.
        -- The length is read, then that many bytes are read and put in a string.
        
        local stringLength = readUnsigned(24)
        assert(pointer+(stringLength*8) <= bitCount, "readString cannot read past the end of the stream")

        local outputCharacters = {} --!

        for i = 1, stringLength do
            outputCharacters[i] = string.char(readByte())
        end

        return table.concat(outputCharacters) --todo Use faster table.concat method
    end

    local function readTerminatedString()
        local outputCharacters = {}

        -- Bytes are read continuously until either a nul-character is reached or until the stream runs out.
        for i = 1, math.huge do -- Using a for loop gives us a convenient counter variable
            local byte = readByte()
            if not byte then -- Stream has ended
                error("BitBuffer.readTerminatedString cannot read past the end of the stream", 2)
            elseif byte == 0 then -- String has ended
                break
            else -- Add byte to string
                outputCharacters[i] = string.char(byte)
            end
        end

        return table.concat(outputCharacters) --todo Use faster table.concat method
    end

    local function readSetLengthString(length)
        assert(type(length) == "number", "argument #1 to readSetLengthString should be a number")
        assert(length > 0, "argument #1 to readSetLengthString should be above 0")
        assert(length%1 == 0, "argument #1 to readSetLengthString should be an integer")

        assert(pointer+(length*8) <= bitCount, "readSetLengthString cannot read past the end of the stream")
        -- `length` number of bytes are read and put into a string

        local outputCharacters = {} --!

        for i = 1, length do
            outputCharacters[i] = string.char(readByte())
        end

        return table.concat(outputCharacters) --todo Use faster table.concat method
    end

    local function readBools(n)
        assert(type(n) == "number", "argument #1 to readBools should be a number")
        assert(n > 0, "argument #1 to readBools should be above 0")
        assert(n%1 == 0, "argument #1 to readBools should be an integer")

        assert(pointer+n <= bitCount, "readBools cannot read past the end of the stream")
        -- Reading a bit field is again rather simple. You read the actual field, then take the bits out.
        local readInt = readUnsigned(n)
        local output = {}--!

        for i = n, 1, -1 do -- In reverse order since we're pulling bits out from lsb to msb
            output[i] = readInt%2 == 1 -- Equivalent to an extraction of the lsb
            readInt = math.floor(readInt/2) -- Equivalent to readInt>>1
        end

        return output
    end

    return {
        dumpBinary = dumpBinary,
        dumpString = dumpString,
        dumpHex = dumpHex,
        dumpBase64 = dumpBase64,
        crc32 = crc32,
        adler32 = adler32,
        getPointer = getPointer,
        setPointer = setPointer,

        writeBits = writeBits,
        writeByte = writeByte,
        writeUnsigned = writeUnsigned,
        writeSigned = writeSigned,
        writeFloat = writeFloat,
        writeString = writeString,
        writeTerminatedString = writeTerminatedString,
        writeSetLengthString = writeSetLengthString,
        writeBools = writeBools,

        readBits = readBits,
        readByte = readByte,
        readUnsigned = readUnsigned,
        readSigned = readSigned,
        readFloat = readFloat,
        readString = readString,
        readTerminatedString = readTerminatedString,
        readSetLengthString = readSetLengthString,
        readBools = readBools,
    }
end

return bitBuffer