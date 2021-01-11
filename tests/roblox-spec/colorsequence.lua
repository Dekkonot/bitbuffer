--!nocheck
local function makeTests(try, BitBuffer)
    local writeTest = try("writeColorSequence tests")
    local readTest = try("readColorSequence tests")

    writeTest("Should require the argument be a ColorSequence", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence({})
    end).fail()

    writeTest("Should write two keypoints to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))

        assert(buffer.dumpHex() == "00000002000000000a141e3f80000028323c", "")
    end).pass()

    writeTest("Should write 10 keypoints to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))

        assert(buffer.dumpHex() == "0000000a000000000a141e3dcccccd28323c3e4ccccd46505a3e99999a646e783ecccccd828c963f000000a0aab43f19999abec8d23f333333dce6f03f4ccccdfaf0e63f800000dcd2c8", "")
    end).pass()

    writeTest("Should write two keypoints to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))

        assert(buffer.dumpHex() == "8000000100000000050a0f1fc0000014191e00", "")
    end).pass()

    writeTest("Should write 10 keypoints to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))

        assert(buffer.dumpHex() == "8000000500000000050a0f1ee6666694191e1f266666a3282d1f4ccccd32373c1f666666c1464b1f80000050555a1f8ccccd5f64691f999999ee73781fa66666fd78731fc000006e696400", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after two keypoints", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))
        buffer.writeBits(1)

        assert(buffer.dumpHex() == "00000002000000000a141e3f80000028323c80", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after 10 keypoints", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))
        buffer.writeBits(1)

        assert(buffer.dumpHex() == "0000000a000000000a141e3dcccccd28323c3e4ccccd46505a3e99999a646e783ecccccd828c963f000000a0aab43f19999abec8d23f333333dce6f03f4ccccdfaf0e63f800000dcd2c880", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))

        buffer.readColorSequence()
    end).pass()

    readTest("Should read two keypoints from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))

        assert(buffer.readColorSequence() == ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)), "")
    end).pass()

    readTest("Should read 10 keypoints from the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))

        assert(buffer.readColorSequence() == ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }), "")
    end).pass()

    readTest("Should read two keypoints from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))

        buffer.readBits(1)

        assert(buffer.readColorSequence() == ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)), "")
    end).pass()

    readTest("Should read 10 keypoints from the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))

        buffer.readBits(1)

        assert(buffer.readColorSequence() == ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }), "")
    end).pass()

    readTest("Should read a bit from the stream properly after two keypoints", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new(Color3.fromRGB(10, 20, 30), Color3.fromRGB(40, 50, 60)))
        buffer.writeBits(1)

        buffer.readColorSequence()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream properly after 10 keypoints", function()
        local buffer = BitBuffer()

        buffer.writeColorSequence(ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 30)), ColorSequenceKeypoint.new(0.1, Color3.fromRGB(40, 50, 60)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(70, 80, 90)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 110, 120)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(130, 140, 150)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 170, 180)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(190, 200, 210)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 230, 240)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 240, 230)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 210, 200))
        }))
        buffer.writeBits(1)

        buffer.readColorSequence()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream", function()
        local buffer = BitBuffer()

        buffer.readColorSequence()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests