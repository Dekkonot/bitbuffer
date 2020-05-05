local BitBuffer = require("bitBuffer")

local function makeTests(try)
    local writeTest = try("writeString tests")
    local readTest = try("readString tests")

    writeTest("Should require the argument be a string", function()
        local buffer = BitBuffer()

        buffer.writeString({})
    end).fail()

    writeTest("Should allow the argument to contain \\0", function()
        local buffer = BitBuffer()

        buffer.writeString("\0")
    end).pass()

    writeTest("Should allow strings be 0 characters long", function()
        local buffer = BitBuffer()

        buffer.writeString("")
    end).pass()

    writeTest("Should require strings be less than 2^24 characters long", function()
        local buffer = BitBuffer()

        buffer.writeString(string.rep("e", 2^24))
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeString("trans")

        assert(buffer.dumpBinary() == "00000000 00000000 00000101 01110100 01110010 01100001 01101110 01110011", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeString("rights")

        assert(buffer.dumpBinary() == "10000000 00000000 00000011 00111001 00110100 10110011 10110100 00111010 00111001 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a string", function()
        local buffer = BitBuffer()

        buffer.writeString("good")
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 00000000 00000100 01100111 01101111 01101111 01100100 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeString("test")

        buffer.readString()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeString("test")

        assert(buffer.readString() == "test", "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeString("test")

        buffer.readBits(1)

        assert(buffer.readString() == "test", "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a string", function()
        local buffer = BitBuffer()

        buffer.writeString("wooloo")
        buffer.writeBits(1)

        buffer.readString()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading a string that goes past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(24, 15)
        buffer.writeByte(163)

        buffer.readString()
    end).fail()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readString()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests