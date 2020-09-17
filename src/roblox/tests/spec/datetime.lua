--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeDateTime tests")
    local readTest = try("readDateTime tests")

    writeTest("Should require the argument be a DateTime", function()
        local buffer = BitBuffer()

        buffer.writeDateTime({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))

        assert(buffer.dumpBinary() == "00011111 10010010 01100010 11000001 01011110 01111101 00", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))

        assert(buffer.dumpBinary() == "10001111 11001001 00110001 01100000 10101111 00111110 100", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a DateTime", function()
        local buffer = BitBuffer()

        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00011111 10010010 01100010 11000001 01011110 01111101 001", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))

        buffer.readDateTime()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))

        assert(buffer.readDateTime() == DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))

        buffer.readBits(1)

        assert(buffer.readDateTime() == DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a DateTime", function()
        local buffer = BitBuffer()

        buffer.writeDateTime(DateTime.fromUniversalTime(2020, 9, 17, 12, 5, 30, 500))
        buffer.writeBits(1)

        buffer.readDateTime()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readDateTime()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests