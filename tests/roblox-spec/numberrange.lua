--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeNumberRange tests")
    local readTest = try("readNumberRange tests")

    writeTest("Should require the argument be a NumberRange", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 01000000 01001000 11110101 11000011", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))

        assert(buffer.dumpBinary() == "10011111 00010000 00000000 00000000 00100000 00100100 01111010 11100001 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a NumberRange", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 01000000 01001000 11110101 11000011 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))

        buffer.readNumberRange()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))

        assert(buffer.readNumberRange() == NumberRange.new(0.15625, 3.14), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))

        buffer.readBits(1)

        assert(buffer.readNumberRange() == NumberRange.new(0.15625, 3.14), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a NumberRange", function()
        local buffer = BitBuffer()

        buffer.writeNumberRange(NumberRange.new(0.15625, 3.14))
        buffer.writeBits(1)

        buffer.readNumberRange()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readNumberRange()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests