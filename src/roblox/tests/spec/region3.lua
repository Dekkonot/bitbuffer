local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeRegion3 tests")
    local readTest = try("readRegion3 tests")

    writeTest("Should require the argument be a Region3", function()
        local buffer = BitBuffer()

        buffer.writeRegion3({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 9001)))

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11000001 00100000 00000000 00000000 01000000 01001000 11110000 00000000 00000000 00000000 00000000 00000000 01000100 10100111 00100000 00000000 01000110 00001100 10100100 00000000", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 9001)))

        assert(buffer.dumpBinary() == "10011111 00010000 00000000 00000000 01100000 10010000 00000000 00000000 00100000 00100100 01111000 00000000 00000000 00000000 00000000 00000000 00100010 01010011 10010000 00000000 00100011 00000110 01010010 00000000 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a Region3", function()
        local buffer = BitBuffer()

        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 9001)))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11000001 00100000 00000000 00000000 01000000 01001000 11110000 00000000 00000000 00000000 00000000 00000000 01000100 10100111 00100000 00000000 01000110 00001100 10100100 00000000 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        buffer.readRegion3()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        assert(buffer.readRegion3() == Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        buffer.readBits(1)

        assert(buffer.readRegion3() == Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Region3", function()
        local buffer = BitBuffer()

        buffer.writeRegion3(Region3.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))
        buffer.writeBits(1)

        buffer.readRegion3()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer =  BitBuffer()

        buffer.readRegion3()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests