local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeUInt16 tests")
    local readTest = try("readUInt16 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeUInt16({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(math.pi)
    end).fail()

    writeTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(-1)
    end).fail()

    writeTest("Should require the argument be below 65536", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(65536)
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(17001)

        assert(buffer.dumpBinary() == "01000010 01101001", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUInt16(17001)

        assert(buffer.dumpBinary() == "10100001 00110100 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a byte", function()
        local buffer = BitBuffer()
        
        buffer.writeUInt16(17001)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01000010 01101001 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(10)

        buffer.readUInt16()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(17001)

        assert(buffer.readUInt16() == 17001, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUInt16(17001)

        buffer.readBits(1)

        assert(buffer.readUInt16() == 17001, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeUInt16(17001)
        buffer.writeBits(1)

        buffer.readUInt16()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readUInt16()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests