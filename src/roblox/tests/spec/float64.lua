local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeFloat64 tests")
    local readTest = try("readFloat64 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat64({})
    end).fail()

    writeTest("Should write positive integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(1337)

        assert(buffer.dumpBinary() == "01000000 10010100 11100100 00000000 00000000 00000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(0.69420)

        assert(buffer.dumpBinary() == "00111111 11100110 00110110 11100010 11101011 00011100 01000011 00101101", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat64(0.69420)

        assert(buffer.dumpBinary() == "10011111 11110011 00011011 01110001 01110101 10001110 00100001 10010110 1", "")
    end).pass()

    writeTest("Should write positive mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(19.85)

        assert(buffer.dumpBinary() == "01000000 00110011 11011001 10011001 10011001 10011001 10011001 10011010", "")
    end).pass()

    writeTest("Should write positive infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(math.huge)

        assert(buffer.dumpBinary() == "01111111 11110000 00000000 00000000 00000000 00000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write positive subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(2.22507385850720088902e-308)

        assert(buffer.dumpBinary() == "00000000 00001111 11111111 11111111 11111111 11111111 11111111 11111111", "")
    end).pass()

    writeTest("Should write negative integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-1337)

        assert(buffer.dumpBinary() == "11000000 10010100 11100100 00000000 00000000 00000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-0.69420)

        assert(buffer.dumpBinary() == "10111111 11100110 00110110 11100010 11101011 00011100 01000011 00101101", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat64(-0.69420)

        assert(buffer.dumpBinary() == "11011111 11110011 00011011 01110001 01110101 10001110 00100001 10010110 1", "")
    end).pass()

    writeTest("Should write negative mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-19.85)

        assert(buffer.dumpBinary() == "11000000 00110011 11011001 10011001 10011001 10011001 10011001 10011010", "")
    end).pass()

    writeTest("Should write negative infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-math.huge)

        assert(buffer.dumpBinary() == "11111111 11110000 00000000 00000000 00000000 00000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write negative subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-2.22507385850720088902e-308)

        assert(buffer.dumpBinary() == "10000000 00001111 11111111 11111111 11111111 11111111 11111111 11111111", "")
    end).pass()

    writeTest("Should write NaN to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(0/0)

        assert(buffer.dumpBinary() == "01111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01000000 00110011 11011001 10011001 10011001 10011001 10011001 10011010 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11000000 00110011 11011001 10011001 10011001 10011001 10011001 10011010 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(10)

        buffer.readFloat64()
    end).pass()

    readTest("Should read positive integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(1337)

        assert(buffer.readFloat64() == 1337, "")
    end).pass()

    readTest("Should read positive fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(0.69420)

        assert(buffer.readFloat64() == 0.694200000000000039257, "")
    end).pass()

    readTest("Should read positive mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(19.85)

        assert(buffer.readFloat64() == 19.8500000000000014211, "")
    end).pass()

    readTest("Should read positive infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(math.huge)

        assert(buffer.readFloat64() == math.huge, "")
    end).pass()

    readTest("Should read negative integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-1337)

        assert(buffer.readFloat64() == -1337, "")
    end).pass()

    readTest("Should read negative fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-0.69420)

        assert(buffer.readFloat64() == -0.694200000000000039257, "")
    end).pass()

    readTest("Should read negative mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-19.85)

        assert(buffer.readFloat64() == -19.8500000000000014211, "")
    end).pass()

    readTest("Should read negative infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-math.huge)

        assert(buffer.readFloat64() == -math.huge, "")
    end).pass()

    readTest("Should read NaN from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(0/0)

        local x = buffer.readFloat64()

        assert(x ~= x, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(19.85)
        buffer.writeBits(1)

        buffer.readFloat64()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat64(-19.85)
        buffer.writeBits(1)

        buffer.readFloat64()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readFloat64()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests