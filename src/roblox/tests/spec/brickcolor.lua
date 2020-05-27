local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeBrickColor tests")
    local readTest = try("readBrickColor tests")

    writeTest("Should require the argument be a BrickColor", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor(BrickColor.new(26))

        assert(buffer.dumpBinary() == "00000000 00011010", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBrickColor(BrickColor.new(26))

        assert(buffer.dumpBinary() == "10000000 00001101 0", "")
    end).pass()

    writeTest("Should write to the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor(BrickColor.new(26))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 00011010 1", "")
    end).pass()


    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor(BrickColor.new(26))

        buffer.readBrickColor()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor(BrickColor.new(26))

        assert(buffer.readBrickColor() == BrickColor.new(26), "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBrickColor(BrickColor.new(26))
        
        buffer.readBits(1)

        assert(buffer.readBrickColor() == BrickColor.new(26), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a BrickColor", function()
        local buffer = BitBuffer()

        buffer.writeBrickColor(BrickColor.new(26))
        buffer.writeBits(1)
        
        buffer.readBrickColor()
        
        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readBrickColor()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests