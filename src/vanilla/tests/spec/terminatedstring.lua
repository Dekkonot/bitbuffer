local BitBuffer = require("bitBuffer")

local function makeTests(try)
    local writeTest = try("writeTerminatedString tests")
    local readTest = try("readTerminatedString tests")

    writeTest("Should require the argument be a string", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString({})
    end).fail()

    writeTest("Should allow strings to be 0 characters long", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString("")
    end).pass()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString("bit")

        assert(buffer.dumpBinary() == "01100010 01101001 01110100 00000000", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeTerminatedString("buffer")

        assert(buffer.dumpBinary() == "10110001 00111010 10110011 00110011 00110010 10111001 00000000 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a null-terminated string", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString("nyeh~!")
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01101110 01111001 01100101 01101000 01111110 00100001 00000000 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString("asdf")
        
        buffer.readTerminatedString()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()
        
        buffer.writeTerminatedString("qwerty")

        assert(buffer.readTerminatedString() == "qwerty", "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeTerminatedString("azerty")

        buffer.readBits(1)

        assert(buffer.readTerminatedString() == "azerty", "")
    end).pass()

    readTest("Should read a bit from the stream properly after a null-terminated string", function()
        local buffer = BitBuffer()

        buffer.writeTerminatedString("test")
        buffer.writeBits(1)

        buffer.readTerminatedString()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should exit if the end of the stream is reached without nul", function()
        local buffer = BitBuffer()

        buffer.writeByte(163)

        buffer.readTerminatedString()
    end).fail() -- In theory, readTerminatedString should throw in this case, and if that happens it successfully exits

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readTerminatedString()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests