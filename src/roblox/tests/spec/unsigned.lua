local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeUnsigned tests")
    local readTest = try("readUnsigned tests")

    writeTest("Should require the first argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned({}, 1)
    end).fail()

    writeTest("Should require the second argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(1, {})
    end).fail()

    writeTest("Should require the first argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(math.pi, 1)
    end).fail()

    writeTest("Should require the second argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(1, math.pi)
    end).fail()

    writeTest("Should require the first argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(-1, 1)
    end).fail()

    writeTest("Should require the second argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(1, -1)
    end).fail()

    writeTest("Should require the first argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(0, 1)
    end).fail()

    writeTest("Should require the first argument be less than 65", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(65, 1)
    end).fail()

    writeTest("Should allow the second argument to be zero", function()
        local buffer = BitBuffer()
        
        buffer.writeUnsigned(16, 0)
    end).pass()

    writeTest("Should allow the second argument to be a number between 0 and 2^n-1", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 6788)
    end).pass()

    writeTest("Should allow the second argument to be 2^n-1", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 2^16-1)
    end).pass()

    writeTest("Should not allow numbers past 2^n-1", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 2^16)
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)

        assert(buffer.dumpString() == "\0\255", "")
    end).pass()

    writeTest("Should write to the stream properly with a width that isn't a multiple of 8", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(15, 255)

        assert(buffer.dumpBinary() == "00000001 1111111", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUnsigned(15, 255)

        assert(buffer.dumpBinary() == "10000000 11111111", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after an unsigned number", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 11111111 1", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)

        buffer.readUnsigned({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)

        buffer.readUnsigned(math.pi)
    end).fail()

    readTest("Should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)

        buffer.readUnsigned(-1)
    end).fail()

    readTest("Should require the argument not be zero", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)

        buffer.readUnsigned(0)
    end).fail()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(15, 255)

        assert(buffer.readUnsigned(15) == 255, "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeUnsigned(15, 255)

        buffer.readBits(1)

        assert(buffer.readUnsigned(15) == 255, "")
    end).pass()

    readTest("Should read a bit from the stream properly after an unsigned number", function()
        local buffer = BitBuffer()

        buffer.writeUnsigned(16, 255)
        buffer.writeBits(1)

        buffer.readUnsigned(16)
        
        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readUnsigned(10)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests