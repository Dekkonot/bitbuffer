--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeNumberSequence tests")
    local readTest = try("readNumberSequence tests")

    writeTest("Should require the argument be a NumberSequence", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence({})
    end).fail()

    writeTest("Should write two keypoints to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))

        assert(buffer.dumpHex() == "0000000200000000c4de014dc4de014d3f80000042ae000000000000", "")
    end).pass()

    writeTest("Should write two keypoints to the stream with custom envelopes properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))

        assert(buffer.dumpHex() == "0000000200000000c4de014dc4de014d3f80000042ae000040a00000", "")
    end).pass()

    writeTest("Should write 10 keypoints to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))

        assert(buffer.dumpHex() == "0000000a00000000c4de014dc4de014d3dcccccd42ae0000000000003e4ccccdc2d20000c2d200003e99999a44a72000000000003ecccccdc4a72000c4a720003f00000043e28000000000003f19999ac2ae0000c2ae00003f33333342d20000000000003f4ccccdc3e28000c3e280003f8000000000000000000000", "")
    end).pass()

    writeTest("Should write two keypoints to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))

        assert(buffer.dumpHex() == "8000000100000000626f00a6e26f00a69fc00000215700000000000000", "")
    end).pass()

    writeTest("Should write two keypoints to the stream with custom envelopes properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))

        assert(buffer.dumpHex() == "8000000100000000626f00a6e26f00a69fc00000215700002050000000", "")
    end).pass()

    writeTest("Should write 10 keypoints to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))

        assert(buffer.dumpHex() == "8000000500000000626f00a6e26f00a69ee66666a1570000000000001f266666e1690000616900001f4ccccd22539000000000001f666666e2539000625390001f80000021f14000000000001f8ccccd61570000615700001f999999a1690000000000001fa66666e1f1400061f140001fc00000000000000000000000", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after two keypoints", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))
        buffer.writeBits(1)

        assert(buffer.dumpHex() == "0000000200000000c4de014dc4de014d3f80000042ae00000000000080", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after two keypoints with custom envelopes", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))
        buffer.writeBits(1)

        assert(buffer.dumpHex() == "0000000200000000c4de014dc4de014d3f80000042ae000040a0000080", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after 10 keypoints", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))
        buffer.writeBits(1)

        assert(buffer.dumpHex() == "0000000a00000000c4de014dc4de014d3dcccccd42ae0000000000003e4ccccdc2d20000c2d200003e99999a44a72000000000003ecccccdc4a72000c4a720003f00000043e28000000000003f19999ac2ae0000c2ae00003f33333342d20000000000003f4ccccdc3e28000c3e280003f800000000000000000000080", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))

        buffer.readNumberSequence()
    end).pass()

    readTest("Should read two keypoints from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))

        assert(buffer.readNumberSequence() == NumberSequence.new(-1776.0406, 87), "")
    end).pass()

    readTest("Should read a negative envelope keypoint from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1))

        assert(buffer.readNumberSequence() == NumberSequence.new(-1), "")
    end).pass()

    readTest("Should read two keypoints with custom envelopes from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))

        assert(buffer.readNumberSequence() == NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}), "")
    end).pass()

    readTest("Should read 10 keypoints from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))

        assert(buffer.readNumberSequence() == NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }), "")
    end).pass()

    readTest("Should read two keypoints from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))

        buffer.readBits(1)

        assert(buffer.readNumberSequence() == NumberSequence.new(-1776.0406, 87), "")
    end).pass()

    readTest("Should read two keypoints with custom envelopes from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))

        buffer.readBits(1)

        assert(buffer.readNumberSequence() == NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}), "")
    end).pass()

    readTest("Should read 10 keypoints from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))

        buffer.readBits(1)

        assert(buffer.readNumberSequence() == NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }), "")
    end).pass()

    readTest("Should read a bit from the stream properly after two keypoints", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new(-1776.0406, 87))
        buffer.writeBits(1)

        buffer.readNumberSequence()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after two keypoints with custom envelopes", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({NumberSequenceKeypoint.new(0, -1776.0406, 0), NumberSequenceKeypoint.new(1, 87, 5)}))
        buffer.writeBits(1)

        buffer.readNumberSequence()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after 10 keypoints", function()
        local buffer = BitBuffer()

        buffer.writeNumberSequence(NumberSequence.new({
            NumberSequenceKeypoint.new(0, -1776.0406), NumberSequenceKeypoint.new(0.1, 87), NumberSequenceKeypoint.new(0.2, -105),
            NumberSequenceKeypoint.new(0.3, 1337), NumberSequenceKeypoint.new(0.4, -1337), NumberSequenceKeypoint.new(0.5, 453),
            NumberSequenceKeypoint.new(0.6, -87), NumberSequenceKeypoint.new(0.7, 105), NumberSequenceKeypoint.new(0.8, -453),
            NumberSequenceKeypoint.new(1, 0)
        }))
        buffer.writeBits(1)

        buffer.readNumberSequence()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readNumberSequence()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests