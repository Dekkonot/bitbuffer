local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeFloat tests")
    local readTest = try("readFloat tests")

    writeTest("Should require the first argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat({}, 1, 1)
    end).fail()

    writeTest("Should require the second argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, {}, 1)
    end).fail()

    writeTest("Should require the third argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, {})
    end).fail()

    writeTest("Should require the first argument be an integer", function()
        local buffer = BitBuffer()
        
        buffer.writeFloat(math.pi, 1, 1)
    end).fail()

    writeTest("Should require the second argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, math.pi, 1)
    end).fail()

    writeTest("Should require the first argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeFloat(-1, 1, 1)
    end).fail()

    writeTest("Should require the second argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, -1, 1)
    end).fail()

    writeTest("Should require the first argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeFloat(0, 1, 1)
    end).fail()

    writeTest("Should require the second argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 0, 1)
    end).fail()

    writeTest("Should require the first argument be below 65", function()
        local buffer = BitBuffer()

        buffer.writeFloat(65, 1, 1)
    end).fail()

    writeTest("Should require the second argument be below 65", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 65, 1)
    end).fail()

    writeTest("Should write positive integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1337)

        assert(buffer.dumpBinary() == "01000100 10100111 00100000 00000000", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly", function()
        local buffer = BitBuffer()
        
        buffer.writeFloat(8, 23, 0.69420)
        
        assert(buffer.dumpBinary() == "00111111 00110001 10110111 00010111", "")
    end).pass()

    writeTest("Should write positive fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()
        
        buffer.writeBits(1)
        buffer.writeFloat(8, 23, 0.69420)
        
        assert(buffer.dumpBinary() == "10011111 10011000 11011011 10001011 1", "")
    end).pass()
    
    writeTest("Should write positive mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1776.0704)

        assert(buffer.dumpBinary() == "01000100 11011110 00000010 01000001", "")
    end).pass()

    writeTest("Should write positive infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, math.huge)

        assert(buffer.dumpBinary() == "01111111 10000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write positive subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 10e-39)

        assert(buffer.dumpBinary() == "00000000 01101100 11100011 11101110", "")
    end).pass()

    writeTest("Should write negative integers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1337)

        assert(buffer.dumpBinary() == "11000100 10100111 00100000 00000000", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -0.69420)

        assert(buffer.dumpBinary() == "10111111 00110001 10110111 00010111", "")
    end).pass()

    writeTest("Should write negative fractions to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat(8, 23, -0.69420)

        assert(buffer.dumpBinary() == "11011111 10011000 11011011 10001011 1", "")
    end).pass()

    writeTest("Should write negative mixed numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1776.0704)

        assert(buffer.dumpBinary() == "11000100 11011110 00000010 01000001", "")
    end).pass()

    writeTest("Should write negative infinity to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -math.huge)

        assert(buffer.dumpBinary() == "11111111 10000000 00000000 00000000", "")
    end).pass()

    writeTest("Should write negative subnormal numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -10e-39)

        assert(buffer.dumpBinary() == "10000000 01101100 11100011 11101110", "")
    end).pass()

    writeTest("Should write NaN to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 0/0)

        assert(buffer.dumpBinary() == "01111111 10000000 00000000 00001010", "")
    end).pass()

    writeTest("Should write a mixed number as a double to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(11, 52, 1918.1111)

        assert(buffer.dumpBinary() == "01000000 10011101 11111000 01110001 11000100 00110010 11001010 01011000", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1776.0704)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01000100 11011110 00000010 01000001 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1776.0704)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11000100 11011110 00000010 01000001 1", "")
    end).pass()

    readTest("Should require the first argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat({}, 1)
    end).fail()

    readTest("Should require the second argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(1, {})
    end).fail()

    readTest("Should require the first argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(math.pi, 1)
    end).fail()

    readTest("Should require the second argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(1, math.pi)
    end).fail()

    readTest("Should require the first argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(-1, 1)
    end).fail()

    readTest("Should require the second argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(1, -1)
    end).fail()

    readTest("Should require the first argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(0, 1)
    end).fail()

    readTest("Should require the second argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeFloat(1, 1, 1)

        buffer.readFloat(1, 0)
    end).fail()

    readTest("Should read positive integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1337)

        assert(buffer.readFloat(8, 23) == 1337, "")
    end).pass()

    readTest("Should read positive fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 0.69420)

        assert(buffer.readFloat(8, 23) == 0.694199979305267333984, "")
    end).pass()

    readTest("Should read positive fractions from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat(8, 23, 0.69420)

        buffer.readBits(1)

        assert(buffer.readFloat(8, 23) == 0.694199979305267333984, "")
    end).pass()

    readTest("Should read positive mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1776.0704)

        assert(buffer.readFloat(8, 23) == 1776.0704345703125, "")
    end).pass()

    readTest("Should read positive infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, math.huge)

        assert(buffer.readFloat(8, 23) == math.huge, "")
    end).pass()

    readTest("Should read negative integers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1337)

        assert(buffer.readFloat(8, 23) == -1337, "")
    end).pass()

    readTest("Should read negative fractions from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -0.69420)

        assert(buffer.readFloat(8, 23) == -0.694199979305267333984, "")
    end).pass()

    readTest("Should read negative fractions from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeFloat(8, 23, -0.69420)

        buffer.readBits(1)

        assert(buffer.readFloat(8, 23) == -0.694199979305267333984, "")
    end).pass()

    readTest("Should read negative mixed numbers from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1776.0704)

        assert(buffer.readFloat(8, 23) == -1776.0704345703125, "")
    end).pass()

    readTest("Should read negative infinity from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -math.huge)

        assert(buffer.readFloat(8, 23) == -math.huge, "")
    end).pass()

    readTest("Should read NaN from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 0/0)

        local x = buffer.readFloat(8, 23)

        assert(x ~= x, "")
    end).pass()

    readTest("Should read doubles from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeFloat(11, 52, 1918.1111)

        assert(buffer.readFloat(11, 52) == 1918.11110000000007858, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a positive number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, 1776.0704)
        buffer.writeBits(1)

        buffer.readFloat(8, 23)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a negative number", function()
        local buffer = BitBuffer()

        buffer.writeFloat(8, 23, -1776.0704)
        buffer.writeBits(1)

        buffer.readFloat(8, 23)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readFloat(8, 23)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests