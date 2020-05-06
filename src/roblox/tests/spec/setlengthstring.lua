local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeSetLengthString tests")
    local readTest = try("readSetLengthString tests")

    writeTest("Should require the argument be a string", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString({})
    end).fail()

    writeTest("Should allow the argument to contain \\0", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString("\0")
    end).pass()

    writeTest("Should allow the argument to be 0 characters long", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString("")
    end).pass()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString("Isaac")

        assert(buffer.dumpBinary() == "01001001 01110011 01100001 01100001 01100011", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSetLengthString("Newton")

        assert(buffer.dumpBinary() == "10100111 00110010 10111011 10111010 00110111 10110111 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a set-length string", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString("boo!")
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01100010 01101111 01101111 00100001 1", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString(":>")

        buffer.readSetLengthString({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString("i've just about lost my mind")

        buffer.readSetLengthString(math.pi)
    end).fail()

    readTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString(":>")

        buffer.readSetLengthString(-1)
    end).fail()

    readTest("Should require the argument not be 0", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString(":>")

        buffer.readSetLengthString(0)
    end).fail()

    readTest("Should read from the string correctly", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString(":>")

        assert(buffer.readSetLengthString(2) == ":>", "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSetLengthString(":>")

        buffer.readBits(1)

        assert(buffer.readSetLengthString(2) == ":>", "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a set-length string", function()
        local buffer = BitBuffer()

        buffer.writeSetLengthString(":3")
        buffer.writeBits(1)

        buffer.readSetLengthString(2)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readSetLengthString(10)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests