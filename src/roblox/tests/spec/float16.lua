--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeFloat16 tests")
    local readTest = try("readFloat16 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat16({})
    end).fail()

    writeTest("Should write positive integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(1337)

        assert(buffer.dumpBinary() == "01100101 00111001", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(0.69420)

        assert(buffer.dumpBinary() == "00111001 10001110", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat16(0.69420)

        assert(buffer.dumpBinary() == "10011100 11000111 0", "")
    end).pass()

    writeTest("Should write positive mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(19.85)

        assert(buffer.dumpBinary() == "01001100 11110110", "")
    end).pass()

    writeTest("Should write positive infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(math.huge)

        assert(buffer.dumpBinary() == "01111100 00000000", "")
    end).pass()

    writeTest("Should write positive subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(0.000041067600250244140625)

        assert(buffer.dumpBinary() == "00000010 10110001", "")
    end).pass()

    writeTest("Should write negative integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-1337)

        assert(buffer.dumpBinary() == "11100101 00111001", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-0.69420)

        assert(buffer.dumpBinary() == "10111001 10001110", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat16(-0.69420)

        assert(buffer.dumpBinary() == "11011100 11000111 0", "")
    end).pass()

    writeTest("Should write negative mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-19.85)

        assert(buffer.dumpBinary() == "11001100 11110110", "")
    end).pass()

    writeTest("Should write negative infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-math.huge)

        assert(buffer.dumpBinary() == "11111100 00000000", "")
    end).pass()

    writeTest("Should write negative subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-0.000041067600250244140625)

        assert(buffer.dumpBinary() == "10000010 10110001", "")
    end).pass()

    writeTest("Should write NaN to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(0/0)

        assert(buffer.dumpBinary() == "01111111 11111111", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01001100 11110110 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11001100 11110110 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(10)

        buffer.readFloat16()
    end).pass()

    readTest("Should read positive integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(1337)

        assert(buffer.readFloat16() == 1337, "")
    end).pass()

    readTest("Should read positive fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(0.69420)

        assert(buffer.readFloat16() == 0.6943359375, "")
    end).pass()

    readTest("Should read positive mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(19.85)

        assert(buffer.readFloat16() == 19.84375, "")
    end).pass()

    readTest("Should read positive infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(math.huge)

        assert(buffer.readFloat16() == math.huge, "")
    end).pass()

    readTest("Should read negative integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-1337)

        assert(buffer.readFloat16() == -1337, "")
    end).pass()

    readTest("Should read negative fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-0.69420)

        assert(buffer.readFloat16() == -0.6943359375, "")
    end).pass()

    readTest("Should read negative mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-19.85)

        assert(buffer.readFloat16() == -19.84375, "")
    end).pass()

    readTest("Should read negative infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-math.huge)

        assert(buffer.readFloat16() == -math.huge, "")
    end).pass()

    readTest("Should read NaN from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(0/0)

        local x = buffer.readFloat16()

        assert(x ~= x, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(19.85)
        buffer.writeBits(1)

        buffer.readFloat16()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat16(-19.85)
        buffer.writeBits(1)

        buffer.readFloat16()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readFloat16()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests