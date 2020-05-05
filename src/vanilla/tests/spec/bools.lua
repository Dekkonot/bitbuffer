local BitBuffer = require("bitBuffer")

local function makeTests(try)
    local writeTest = try("writeBools tests")
    local readTest = try("readBools tests")

    writeTest("Should accept multiple arguments", function()
        local buffer = BitBuffer()

        buffer.writeBools(true, true, false)
    end).pass()

    writeTest("Should accept nil as an argument", function()
        local buffer = BitBuffer()

        buffer.writeBools(nil)
    end).pass()

    writeTest("Should write falsey values to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBools(nil)
        buffer.writeBools(false)

        assert(buffer.dumpBinary() == "00", "")
    end).pass()

    writeTest("Should write truthy values to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBools(1)
        buffer.writeBools(true)
        buffer.writeBools("true")
        buffer.writeBools({})
        
        assert(buffer.dumpBinary() == "1111", "")
    end).pass()

    writeTest("Should write multiple arguments to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBools(true, false, 1)
        
        assert(buffer.dumpBinary() == "101", "")
    end).pass()

    writeTest("Should write multiple arguments with nil to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeBools(true, false, nil, 1)

        assert(buffer.dumpBinary() == "1001", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()
        
        buffer.writeBits(1)
        buffer.writeBools(false, true, false)

        assert(buffer.dumpBinary() == "1010", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a bitfield", function()
        local buffer = BitBuffer()
        
        buffer.writeBools(false, true, false)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "0101", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeBools(true)

        buffer.readBools({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeBools(true)

        buffer.readBools(math.pi)
    end).fail()

    readTest("Should require the argument be greater than 0", function()
        local buffer = BitBuffer()

        buffer.writeBools(true)

        buffer.readBools(0)
    end).fail()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeBools(true, true, false)
        local values = buffer.readBools(3)
        assert(values[1] == true, "")
        assert(values[2] == true, "")
        assert(values[3] == false, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBools(true, true, false)

        buffer.readBits(1)

        local values = buffer.readBools(3)
        assert(values[1] == true, "")
        assert(values[2] == true, "")
        assert(values[3] == false, "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a bitfield", function()
        local buffer = BitBuffer()

        buffer.writeBools(true, true, false)
        buffer.writeBits(1)

        buffer.readBools(3)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readBools(10)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests