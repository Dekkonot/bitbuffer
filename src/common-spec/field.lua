--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeField tests")
    local readTest = try("readField tests")

    writeTest("Should accept multiple arguments", function()
        local buffer = BitBuffer()

        buffer.writeField(true, true, false)
    end).pass()

    writeTest("Should accept nil as an argument", function()
        local buffer = BitBuffer()

        buffer.writeField(nil)
    end).pass()

    writeTest("Should write falsey values to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeField(nil)
        buffer.writeField(false)

        assert(buffer.dumpBinary() == "00", "")
    end).pass()

    writeTest("Should write truthy values to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeField(1)
        buffer.writeField(true)
        buffer.writeField("true")
        buffer.writeField({})

        assert(buffer.dumpBinary() == "1111", "")
    end).pass()

    writeTest("Should write multiple arguments to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeField(true, false, 1)

        assert(buffer.dumpBinary() == "101", "")
    end).pass()

    writeTest("Should write multiple arguments with nil to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeField(true, false, nil, 1)

        assert(buffer.dumpBinary() == "1001", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeField(false, true, false)

        assert(buffer.dumpBinary() == "1010", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a bitfield", function()
        local buffer = BitBuffer()

        buffer.writeField(false, true, false)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "0101", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeField(true)

        buffer.readField({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeField(true)

        buffer.readField(math.pi)
    end).fail()

    readTest("Should require the argument be greater than 0", function()
        local buffer = BitBuffer()

        buffer.writeField(true)

        buffer.readField(0)
    end).fail()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeField(true, true, false)
        local values = buffer.readField(3)
        assert(values[1] == true, "")
        assert(values[2] == true, "")
        assert(values[3] == false, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeField(true, true, false)

        buffer.readBits(1)

        local values = buffer.readField(3)
        assert(values[1] == true, "")
        assert(values[2] == true, "")
        assert(values[3] == false, "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a bitfield", function()
        local buffer = BitBuffer()

        buffer.writeField(true, true, false)
        buffer.writeBits(1)

        buffer.readField(3)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readField(10)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests