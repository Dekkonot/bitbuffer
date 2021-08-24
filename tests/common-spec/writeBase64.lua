--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeBase64 tests")

    writeTest("Should require the argument be a string", function()
        local buffer = BitBuffer()

        buffer.writeBase64({})
    end).fail()

    writeTest("Should require the argument only contain Base64 characters", function()
        local buffer = BitBuffer()
        
        buffer.writeBase64("a;")
    end).fail()

    writeTest("Should write to the stream properly with no padding", function()
        local buffer = BitBuffer()

        buffer.writeBase64("YWFh")

        assert(buffer.dumpString() == "aaa", "")
    end).pass()

    writeTest("Should write to the stream properly with one byte of padding", function()
        local buffer = BitBuffer()

        buffer.writeBase64("YWE=")

        assert(buffer.dumpString() == "aa", "")
    end).pass()

    writeTest("Should write to the stream properly with two bytes of padding", function()
        local buffer = BitBuffer()

        buffer.writeBase64("YQ==")

        assert(buffer.dumpString() == "a", "")
    end).pass()

    writeTest("Should write to the stream properly with missing padding", function()
        local buffer = BitBuffer()

        buffer.writeBase64("YQ")

        assert(buffer.dumpString() == "a", "")
    end).pass()

    writeTest("Should write to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeBase64("YQ==")

        assert(buffer.dumpBinary() == "10110000 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBase64("YQ==")
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "01100001 1", "")
    end).pass()

    return writeTest.run()
end

return makeTests