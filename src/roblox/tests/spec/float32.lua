--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeFloat32 tests")
    local readTest = try("readFloat32 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat32({})
    end).fail()

    writeTest("Should write positive integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(1337)

        assert(buffer.dumpBinary() == "01000100 10100111 00100000 00000000", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(0.69420)

        assert(buffer.dumpBinary() == "00111111 00110001 10110111 00010111", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat32(0.69420)

        assert(buffer.dumpBinary() == "10011111 10011000 11011011 10001011 1", "")
    end).pass()

    writeTest("Should write positive mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(19.85)

        assert(buffer.dumpBinary() == "01000001 10011110 11001100 11001101", "")
    end).pass()

    writeTest("Should write positive infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(math.huge)

        assert(buffer.dumpBinary() == "01111111 10000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write positive subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(1.04074100633772725901e-38)

        assert(buffer.dumpBinary() == "00000000 01110001 01010011 10100000", "")
    end).pass()

    writeTest("Should write negative integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-1337)

        assert(buffer.dumpBinary() == "11000100 10100111 00100000 00000000", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-0.69420)

        assert(buffer.dumpBinary() == "10111111 00110001 10110111 00010111", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat32(-0.69420)

        assert(buffer.dumpBinary() == "11011111 10011000 11011011 10001011 1", "")
    end).pass()

    writeTest("Should write negative mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-19.85)

        assert(buffer.dumpBinary() == "11000001 10011110 11001100 11001101", "")
    end).pass()

    writeTest("Should write negative infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-math.huge)

        assert(buffer.dumpBinary() == "11111111 10000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write negative subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-1.04074100633772725901e-38)

        assert(buffer.dumpBinary() == "10000000 01110001 01010011 10100000", "")
    end).pass()

    writeTest("Should write NaN to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(0/0)

        assert(buffer.dumpBinary() == "01111111 11111111 11111111 11111111", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01000001 10011110 11001100 11001101 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-19.85)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11000001 10011110 11001100 11001101 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(10)

        buffer.readFloat32()
    end).pass()

    readTest("Should read positive integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(1337)

        assert(buffer.readFloat32() == 1337, "")
    end).pass()

    readTest("Should read positive fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(0.69420)

        assert(buffer.readFloat32() == 0.694199979305267333984, "")
    end).pass()

    readTest("Should read positive mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(19.85)

        assert(buffer.readFloat32() == 19.8500003814697265625, "")
    end).pass()

    readTest("Should read positive infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(math.huge)

        assert(buffer.readFloat32() == math.huge, "")
    end).pass()

    readTest("Should read negative integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-1337)

        assert(buffer.readFloat32() == -1337, "")
    end).pass()

    readTest("Should read negative fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-0.69420)

        assert(buffer.readFloat32() == -0.694199979305267333984, "")
    end).pass()

    readTest("Should read negative mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-19.85)

        assert(buffer.readFloat32() == -19.8500003814697265625, "")
    end).pass()

    readTest("Should read negative infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-math.huge)

        assert(buffer.readFloat32() == -math.huge, "")
    end).pass()

    readTest("Should read NaN from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(0/0)

        local x = buffer.readFloat32()

        assert(x ~= x, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a positive mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(19.85)
        buffer.writeBits(1)

        buffer.readFloat32()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a negative mixed number", function()
        local buffer = BitBuffer()

        buffer.writeFloat32(-19.85)
        buffer.writeBits(1)

        buffer.readFloat32()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readFloat32()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests