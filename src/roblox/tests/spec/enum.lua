local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeEnum tests")
    local readTest = try("readEnum tests")

    writeTest("Should require the argument be an EnumItem", function()
        local buffer = BitBuffer()

        buffer.writeEnum({})
    end).fail()

    writeTest("Should write to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeEnum(Enum.Material.Air)

        assert(buffer.dumpBinary() == "01001101 01100001 01110100 01100101 01110010 01101001 01100001 01101100 00000000 00000111 00000000", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeEnum(Enum.Material.Air)

        assert(buffer.dumpBinary() == "10100110 10110000 10111010 00110010 10111001 00110100 10110000 10110110 00000000 00000011 10000000 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a Enum", function()
        local buffer = BitBuffer()

        buffer.writeEnum(Enum.Material.Air)
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01001101 01100001 01110100 01100101 01110010 01101001 01100001 01101100 00000000 00000111 00000000 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeEnum(Enum.Material.Air)

        buffer.readEnum()
    end).pass()

    readTest("Should read from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeEnum(Enum.Material.Air)

        assert(buffer.readEnum() == Enum.Material.Air, "")
    end).pass()

    readTest("Should read from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeEnum(Enum.Material.Air)

        buffer.readBits(1)

        assert(buffer.readEnum() == Enum.Material.Air, "")
    end).pass()

    readTest("Should read a bit from the stream properly after a Enum", function()
        local buffer = BitBuffer()

        buffer.writeEnum(Enum.Material.Air)
        buffer.writeBits(1)

        buffer.readEnum()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer =  BitBuffer()

        buffer.readEnum()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests