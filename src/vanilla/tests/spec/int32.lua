local BitBuffer = require("bitBuffer")

local function makeTests(try)
    local writeTest = try("writeInt32 tests")
    local readTest = try("readInt32 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeInt32({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeInt32(math.pi)
    end).fail()

    writeTest("Should require the argument be above -2147483648", function()
        local buffer = BitBuffer()

        buffer.writeInt32(-2147483649)
    end).fail()

    writeTest("Should require the argument be below 2147483648", function()
        local buffer = BitBuffer()

        buffer.writeInt32(2147483648)
    end).fail()

    writeTest("Should write positive numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt32(1834045464)

        assert(buffer.dumpBinary() == "01101101 01010001 01010000 00011000", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt32(-1834045464)

        assert(buffer.dumpBinary() == "10010010 10101110 10101111 11101000", "")
    end).pass()

    writeTest("Should write positive numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt32(1834045464)

        assert(buffer.dumpBinary() == "10110110 10101000 10101000 00001100 0", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt32(-1834045464)

        assert(buffer.dumpBinary() == "11001001 01010111 01010111 11110100 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt32(1834045464)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01101101 01010001 01010000 00011000 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt32(-1834045464)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "10010010 10101110 10101111 11101000 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeInt32(10)

        buffer.readInt32()
    end).pass()

    readTest("Should read positive numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt32(1834045464)

        assert(buffer.readInt32() == 1834045464, "")
    end).pass()

    readTest("Should read negative numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt32(-1834045464)

        assert(buffer.readInt32() == -1834045464, "")
    end).pass()

    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt32(1834045464)

        buffer.readBits(1)

        assert(buffer.readInt32() == 1834045464, "")
    end).pass()
    
    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt32(-1834045464)

        buffer.readBits(1)

        assert(buffer.readInt32() == -1834045464, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a positive number", function()
        local buffer = BitBuffer()

        buffer.writeInt32(1834045464)
        buffer.writeBits(1)

        buffer.readInt32()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a negative number", function()
        local buffer = BitBuffer()

        buffer.writeInt32(-1834045464)
        buffer.writeBits(1)

        buffer.readInt32()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readInt32()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests