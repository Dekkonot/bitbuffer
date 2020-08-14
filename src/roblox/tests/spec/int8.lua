--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeInt8 tests")
    local readTest = try("readInt8 tests")

    writeTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeInt8({})
    end).fail()

    writeTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeInt8(math.pi)
    end).fail()

    writeTest("Should require the argument be above -129", function()
        local buffer = BitBuffer()

        buffer.writeInt8(-129)
    end).fail()

    writeTest("Should require the argument be below 128", function()
        local buffer = BitBuffer()

        buffer.writeInt8(128)
    end).fail()

    writeTest("Should write positive numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt8(102)

        assert(buffer.dumpBinary() == "01100110", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeInt8(-102)

        assert(buffer.dumpBinary() == "10011010", "")
    end).pass()

    writeTest("Should write positive numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt8(102)

        assert(buffer.dumpBinary() == "10110011 0", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt8(-102)

        assert(buffer.dumpBinary() == "11001101 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt8(102)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01100110 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative number", function()
        local buffer = BitBuffer()
        
        buffer.writeInt8(-102)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "10011010 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeInt8(10)

        buffer.readInt8()
    end).pass()

    readTest("Should read positive numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt8(102)

        assert(buffer.readInt8() == 102, "")
    end).pass()

    readTest("Should read negative numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeInt8(-102)

        assert(buffer.readInt8() == -102, "")
    end).pass()

    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt8(102)

        buffer.readBits(1)

        assert(buffer.readInt8() == 102, "")
    end).pass()
    
    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeInt8(-102)

        buffer.readBits(1)

        assert(buffer.readInt8() == -102, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a positive number", function()
        local buffer = BitBuffer()

        buffer.writeInt8(102)
        buffer.writeBits(1)

        buffer.readInt8()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after reading a negative number", function()
        local buffer = BitBuffer()

        buffer.writeInt8(-102)
        buffer.writeBits(1)

        buffer.readInt8()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readInt8()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests