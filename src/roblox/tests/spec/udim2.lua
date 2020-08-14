--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeUDim2 tests")
    local readTest = try("readUDim2 tests")

    writeTest("Should require the argument be a UDim2", function()
        local buffer = BitBuffer()

        buffer.writeUDim2({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))

        assert(buffer.dumpBinary() == "00000000 00000000 00000000 00000000 00000000 00000000 00000000 01100100 00111110 00100000 00000000 00000000 11111111 11111111 11111111 10011100", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))

        assert(buffer.dumpBinary() == "10000000 00000000 00000000 00000000 00000000 00000000 00000000 00110010 00011111 00010000 00000000 00000000 01111111 11111111 11111111 11001110 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a UDim2", function()
        local buffer = BitBuffer()

        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 00000000 00000000 00000000 00000000 00000000 00000000 01100100 00111110 00100000 00000000 00000000 11111111 11111111 11111111 10011100 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))

        buffer.readUDim2()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))

        assert(buffer.readUDim2() == UDim2.new(0, 100, 0.15625, -100), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))

        buffer.readBits(1)

        assert(buffer.readUDim2() == UDim2.new(0, 100, 0.15625, -100), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a UDim2", function()
        local buffer = BitBuffer()

        buffer.writeUDim2(UDim2.new(0, 100, 0.15625, -100))
        buffer.writeBits(1)

        buffer.readUDim2()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readUDim2()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests