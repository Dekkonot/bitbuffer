--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeVector2 tests")
    local readTest = try("readVector2 tests")

    writeTest("Should require the argument be a Vector2", function()
        local buffer = BitBuffer()

        buffer.writeVector2({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeVector2(Vector2.new(1, 3.141592653589793))
        
        assert(buffer.dumpBinary() == "00111111 10000000 00000000 00000000 01000000 01001001 00001111 11011011", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeVector2(Vector2.new(1, 3.141592653589793))
        
        assert(buffer.dumpBinary() == "10011111 11000000 00000000 00000000 00100000 00100100 10000111 11101101 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a Vector2", function()
        local buffer = BitBuffer()

        buffer.writeVector2(Vector2.new(1, 3.141592653589793))
        buffer.writeBits(1)
        
        assert(buffer.dumpBinary() == "00111111 10000000 00000000 00000000 01000000 01001001 00001111 11011011 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeVector2(Vector2.new(1, 3.141592653589793))

        buffer.readVector2()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeVector2(Vector2.new(1, 3.141592653589793))

        assert(buffer.readVector2() == Vector2.new(1, 3.14159274101257324219), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeVector2(Vector2.new(1, 3.141592653589793))

        buffer.readBits(1)

        assert(buffer.readVector2() == Vector2.new(1, 3.14159274101257324219), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Vector2", function()
        local buffer = BitBuffer()

        buffer.writeVector2(Vector2.new(1, 3.141592653589793))
        buffer.writeBits(1)

        buffer.readVector2()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readVector2()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests