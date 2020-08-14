--!nocheck
local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeRect tests")
    local readTest = try("readRect tests")

    writeTest("Should require the argument be a Rect", function()
        local buffer = BitBuffer()

        buffer.writeRect({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))

        -- Rect automaticlly normalizes its Min/Max so what's written doesn't look like what's read despite being the same data.
        assert(buffer.dumpBinary() == "00000000 00000000 00000000 00000000 01000000 01001000 11110101 11000011 00111110 00100000 00000000 00000000 01001011 00000100 01011111 11101101", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))

        assert(buffer.dumpBinary() == "10000000 00000000 00000000 00000000 00100000 00100100 01111010 11100001 10011111 00010000 00000000 00000000 00100101 10000010 00101111 11110110 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a Rect", function()
        local buffer = BitBuffer()

        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 00000000 00000000 00000000 01000000 01001000 11110101 11000011 00111110 00100000 00000000 00000000 01001011 00000100 01011111 11101101 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))

        buffer.readRect()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))

        assert(buffer.readRect() == Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))

        buffer.readBits(1)

        assert(buffer.readRect() == Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Rect", function()
        local buffer = BitBuffer()

        buffer.writeRect(Rect.new(Vector2.new(0.15625, 3.14), Vector2.new(0, 8675309)))
        buffer.writeBits(1)

        buffer.readRect()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer =  BitBuffer()

        buffer.readRect()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests