--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeUInt32 tests")
    local readTest = try("readUInt32 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeUInt32({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(math.pi)
    end).fail()

    writeTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(-1)
    end).fail()

    writeTest("Should require the argument be below 4294967296", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(4294967296)
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(134250981)

        assert(buffer.dumpBinary() == "00001000 00000000 10000001 11100101", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUInt32(134250981)

        assert(buffer.dumpBinary() == "10000100 00000000 01000000 11110010 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a byte", function()
        local buffer = BitBuffer()
        
        buffer.writeUInt32(134250981)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00001000 00000000 10000001 11100101 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(10)

        buffer.readUInt32()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(134250981)

        assert(buffer.readUInt32() == 134250981, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUInt32(134250981)

        buffer.readBits(1)

        assert(buffer.readUInt32() == 134250981, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeUInt32(134250981)
        buffer.writeBits(1)

        buffer.readUInt32()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readUInt32()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests