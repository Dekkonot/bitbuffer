local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeInt16 tests")
    local readTest = try("readInt16 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeInt16({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeInt16(math.pi)
    end).fail()

    writeTest("Should require the argument be above -32769", function()
        local buffer = BitBuffer()

        buffer.writeInt16(-32769)
    end).fail()

    writeTest("Should require the argument be below 32768", function()
        local buffer = BitBuffer()

        buffer.writeInt16(32768)
    end).fail()

    writeTest("Should write positive numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt16(22001)

        assert(buffer.dumpBinary() == "01010101 11110001", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt16(-22001)

        assert(buffer.dumpBinary() == "10101010 00001111", "")
    end).pass()

    writeTest("Should write positive numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt16(22001)

        assert(buffer.dumpBinary() == "10101010 11111000 1", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt16(-22001)

        assert(buffer.dumpBinary() == "11010101 00000111 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt16(22001)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01010101 11110001 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt16(-22001)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "10101010 00001111 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeInt16(10)

        buffer.readInt16()
    end).pass()

    readTest("Should read positive numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt16(22001)

        assert(buffer.readInt16() == 22001, "")
    end).pass()

    readTest("Should read negative numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt16(-22001)

        assert(buffer.readInt16() == -22001, "")
    end).pass()

    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt16(22001)

        buffer.readBits(1)

        assert(buffer.readInt16() == 22001, "")
    end).pass()
    
    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt16(-22001)

        buffer.readBits(1)

        assert(buffer.readInt16() == -22001, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a positive number", function()
        local buffer = BitBuffer()

        buffer.writeInt16(22001)
        buffer.writeBits(1)

        buffer.readInt16()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a negative number", function()
        local buffer = BitBuffer()

        buffer.writeInt16(-22001)
        buffer.writeBits(1)

        buffer.readInt16()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readInt16()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests