local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeRay tests")
    local readTest = try("readRay tests")

    writeTest("Should require the argument be a Ray", function()
        local buffer = BitBuffer()

        buffer.writeRay({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11000001 00100000 00000000 00000000 01000000 01001000 11110101 11000011 00000000 00000000 00000000 00000000 01000100 10100111 00100000 00000000 01001011 00000100 01011111 11101101", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        assert(buffer.dumpBinary() == "10011111 00010000 00000000 00000000 01100000 10010000 00000000 00000000 00100000 00100100 01111010 11100001 10000000 00000000 00000000 00000000 00100010 01010011 10010000 00000000 00100101 10000010 00101111 11110110 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a Ray", function()
        local buffer = BitBuffer()

        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00111110 00100000 00000000 00000000 11000001 00100000 00000000 00000000 01000000 01001000 11110101 11000011 00000000 00000000 00000000 00000000 01000100 10100111 00100000 00000000 01001011 00000100 01011111 11101101 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        buffer.readRay()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        assert(buffer.readRay() == Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)), "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))

        buffer.readBits(1)

        assert(buffer.readRay() == Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)), "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Ray", function()
        local buffer = BitBuffer()

        buffer.writeRay(Ray.new(Vector3.new(0.15625, -10, 3.14), Vector3.new(0, 1337, 8675309)))
        buffer.writeBits(1)

        buffer.readRay()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer =  BitBuffer()

        buffer.readRay()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests