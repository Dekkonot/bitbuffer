--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeByte tests")
    local readTest = try("readByte tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeByte({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeByte(math.pi)
    end).fail()

    writeTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeByte(-1)
    end).fail()

    writeTest("Should require the argument be below 256", function()
        local buffer = BitBuffer()

        buffer.writeByte(256)
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeByte(163)

        assert(buffer.dumpBinary() == "10100011", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeByte(163)

        assert(buffer.dumpBinary() == "11010001 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeByte(163)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "10100011 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeByte(10)

        buffer.readByte()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeByte(163)

        assert(buffer.readByte() == 163, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeByte(163)

        buffer.readBits(1)

        assert(buffer.readByte() == 163, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeByte(163)
        buffer.writeBits(1)

        buffer.readByte()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readByte()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests