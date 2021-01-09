--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeBits tests")
    local readTest = try("readBits tests")

    writeTest("Should require the arguments be numbers", function()
        local buffer = BitBuffer()

        buffer.writeBits({})
    end).fail()

    writeTest("Should require the arguments be integers", function()
        local buffer = BitBuffer()

        buffer.writeBits(math.pi)
    end).fail()

    writeTest("Should require the arguments be positive", function()
        local buffer = BitBuffer()

        buffer.writeBits(-1)
    end).fail()

    writeTest("Should require the arguments be less than two", function()
        local buffer = BitBuffer()

        buffer.writeBits(2)
    end).fail()

    writeTest("Should accept 0 as an argument", function()
        local buffer = BitBuffer()

        buffer.writeBits(0)
    end).pass()

    writeTest("Should accept 1 as an argument", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
    end).pass()

    writeTest("Should accept multiple arguments", function()
        local buffer = BitBuffer()

        buffer.writeBits(0, 1, 0, 1)
    end).pass()

    writeTest("Should write a single bit to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "1", "")
    end).pass()

    writeTest("Should write multiple bits seperately to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBits(0)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "101", "")
    end).pass()

    writeTest("Should write multiple bits to the tream properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1, 0, 1)

        assert(buffer.dumpBinary() == "101", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        buffer.readBits({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        buffer.readBits(math.pi)
    end).fail()

    readTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        buffer.readBits(-1)
    end).fail()

    readTest("Should require the argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        buffer.readBits(0)
    end).fail()

    readTest("Should one bit from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read multiple bits from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1, 0, 1)

        local bits = buffer.readBits(3)
        assert(bits[1] == 1, "")
        assert(bits[2] == 0, "")
        assert(bits[3] == 1, "")
    end).pass()

    readTest("Should read from the stream multiple times properly", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBits(0)
        buffer.writeBits(1)

        assert(buffer.readBits(1)[1] == 1, "")
        assert(buffer.readBits(1)[1] == 0, "")
        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)

        buffer.readBits(2)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests