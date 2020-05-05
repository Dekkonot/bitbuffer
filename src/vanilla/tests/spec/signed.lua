local BitBuffer = require("bitBuffer")

local function makeTests(try)
    local writeTest = try("writeSigned tests")
    local readTest = try("readSigned tests")

    writeTest("Should require the first argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeSigned({}, 1)
    end).fail()

    writeTest("Should require the second argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(1, {})
    end).fail()

    writeTest("Should require the first argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeSigned(math.pi, 1)
    end).fail()

    writeTest("Should require the second argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeSigned(1, math.pi)
    end).fail()

    writeTest("Should require the first argument be positive", function()
        local buffer = BitBuffer()

        buffer.writeSigned(-1, 1)
    end).fail()

    writeTest("Should require the first argument is greater than one", function()
        local buffer = BitBuffer()

        buffer.writeSigned(1, 1)
    end).fail()

    writeTest("Should require the first argument is less than 65", function()
        local buffer = BitBuffer()

        buffer.writeSigned(65, 1)
    end).fail()

    writeTest("Should allow the second argument to be -(2^n-1)", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, -(2^15))
    end).pass()

    writeTest("Should allow the second argument to be between -(2^n-1) and 0", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, -6788)
    end).pass()

    writeTest("Should allow the second argument to be 0", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 0)
    end).pass()

    writeTest("Should allow the second argument to be between 0 and (2^n-1)-1", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 6788)
    end).pass()

    writeTest("Should allow the second argument to be (2^n-1)-1", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 2^15-1)
    end).pass()

    writeTest("Should not allow numbers greater than (2^n-1)-1", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 2^15)
    end).fail()

    writeTest("Should not allow numbers lower than -(2^n-1)", function()
        local buffer = BitBuffer()
        
        buffer.writeSigned(16, -(2^15)-1)
    end).fail()

    writeTest("Should write positive numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        assert(buffer.dumpBinary() == "00000000 11111111", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, -255)
        
        assert(buffer.dumpBinary() == "11111111 00000001", "")
    end).pass()

    writeTest("Should write positive numbers to the stream properly with a width that isn't a multiple of 8", function()
        local buffer = BitBuffer()

        buffer.writeSigned(15, 255)

        assert(buffer.dumpBinary() == "00000001 1111111", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly with a width that isn't a multiple of 8", function()
        local buffer = BitBuffer()

        buffer.writeSigned(15, -255)

        assert(buffer.dumpBinary() == "11111110 0000001", "")
    end).pass()

    writeTest("Should write positive numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSigned(15, 255)

        assert(buffer.dumpBinary() == "10000000 11111111", "")
    end).pass()

    writeTest("Should write negative numbers to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSigned(15, -255)

        assert(buffer.dumpBinary() == "11111111 00000001", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a positive number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(15, 255)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000001 11111111", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a negative number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(15, -255)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11111110 00000011", "")
    end).pass()

    readTest("Should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        buffer.readSigned({})
    end).fail()

    readTest("Should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        buffer.readSigned(math.pi)
    end).fail()

    readTest("Should require the argument be positive", function()
        local buffer = BitBuffer()
        
        buffer.writeSigned(16, 255)

        buffer.readSigned(-1)
    end).fail()

    readTest("Should require the argument be greater than 1", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        buffer.readSigned(1)
    end).fail()

    readTest("Should require the argument be less than 65", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        buffer.readSigned(65)
    end).fail()

    readTest("Should read positive numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)

        assert(buffer.readSigned(16) == 255, "")
    end).pass()

    readTest("Should read negative numbers from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, -255)

        assert(buffer.readSigned(16) == -255, "")
    end).pass()

    readTest("Should read positive numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSigned(16, 255)

        buffer.readBits(1)

        assert(buffer.readSigned(16) == 255, "")
    end).pass()

    readTest("Should read negative numbers from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeSigned(16, -255)

        buffer.readBits(1)

        assert(buffer.readSigned(16) == -255, "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a positive number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, 255)
        buffer.writeBits(1)

        buffer.readSigned(16)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream correctly after a negative number", function()
        local buffer = BitBuffer()

        buffer.writeSigned(16, -255)
        buffer.writeBits(1)

        buffer.readSigned(16)

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readSigned(16)
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests