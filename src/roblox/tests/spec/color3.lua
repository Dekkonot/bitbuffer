--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeColor3 tests")
    local readTest = try("readColor3 tests")

    writeTest("Should require the argument be a Color3", function()
        local buffer = BitBuffer()

        buffer.writeColor3({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeColor3(Color3.fromRGB(255, 127, 85))

        assert(buffer.dumpBinary() == "11111111 01111111 01010101", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColor3(Color3.fromRGB(255, 127, 85))

        assert(buffer.dumpBinary() == "11111111 10111111 10101010 1", "")
    end).pass()

    writeTest("Should write to the stream properly after a byte", function()
        local buffer = BitBuffer()

        buffer.writeColor3(Color3.fromRGB(255, 127, 85))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "11111111 01111111 01010101 1", "")
    end).pass()


    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeColor3(Color3.fromRGB(255, 127, 85))

        buffer.readColor3()
    end).pass()

    readTest("Should read from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeColor3(Color3.fromRGB(255, 127, 85))

        assert(buffer.readColor3() == Color3.fromRGB(255, 127, 85), "")
    end).pass()

    readTest("Should read from the stream correctly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColor3(Color3.fromRGB(255, 127, 85))
        
        buffer.readBits(1)

        assert(buffer.readColor3() == Color3.fromRGB(255, 127, 85), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Color3", function()
        local buffer = BitBuffer()

        buffer.writeColor3(Color3.fromRGB(255, 127, 85))
        buffer.writeBits(1)
        
        buffer.readColor3()
        
        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading after the stream ends", function()
        local buffer = BitBuffer()

        buffer.readColor3()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()

    return writeTestPassed and readTestPassed
end

return makeTests