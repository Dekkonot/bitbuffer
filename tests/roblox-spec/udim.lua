--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeUDim tests")
    local readTest = try("readUDim tests")

    writeTest("Should require the argument be a UDim", function()
        local buffer = BitBuffer()

        buffer.writeUDim({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUDim(UDim.new(0.15625, -10))

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11111111 11111111 11111111 11110110", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUDim(UDim.new(0.15625, -10))

        assert(buffer.dumpBinary() == "10011111 00010000 00000000 00000000 01111111 11111111 11111111 11111011 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a UDim", function()
        local buffer = BitBuffer()

        buffer.writeUDim(UDim.new(0.15625, -10))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11111111 11111111 11111111 11110110 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeUDim(UDim.new(0.15625, -10))

        buffer.readUDim()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUDim(UDim.new(0.15625, -10))

        assert(buffer.readUDim() == UDim.new(0.15625, -10), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUDim(UDim.new(0.15625, -10))

        buffer.readBits(1)

        assert(buffer.readUDim() == UDim.new(0.15625, -10), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a UDim", function()
        local buffer = BitBuffer()

        buffer.writeUDim(UDim.new(0.15625, -10))
        buffer.writeBits(1)

        buffer.readUDim()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readUDim()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests