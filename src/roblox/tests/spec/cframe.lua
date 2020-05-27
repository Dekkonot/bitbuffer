local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("writeCFrame tests")
    local readTest = try("readCFrame tests")

    writeTest("Should require the argument be a CFrame", function()
        local buffer = BitBuffer()

        buffer.writeCFrame({})
    end).fail()

    writeTest("Should write CFrame.new() to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new())

        assert(buffer.dumpString() == "\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "")
    end).pass()

    writeTest("Should write CFrame.Angles(math.pi/2, 0, -math.pi) to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.Angles(math.pi/2, 0, -math.pi))

        assert(buffer.dumpString() == "\x17\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "")
    end).pass()

    writeTest("Should write CFrame.new(10, 20, 30)*CFrame.Angles(math.pi/2, 0, 0) to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new(10, 20, 30)*CFrame.Angles(math.pi/2, 0, 0))

        assert(buffer.dumpString() == "\x02\x41\x20\x00\x00\x41\xa0\x00\x00\x41\xf0\x00\x00", "")
    end).pass()

    writeTest("Should write CFrame.Angles(1, 2, 3) to the stream properly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.Angles(1, 2, 3))
        assert(buffer.dumpString() == "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3e\xd2\xef\x57\x3d\x70\x8b\x59\x3f\x68\xc7\xb7\xbf\x2e\x65\xec\xbf\x24\x93\x50\x3e\xb3\x4a\x33\x3f\x1a\xe9\x9e\xbf\x43\x83\x0c\xbe\x66\x3d\xca", "")
    end).pass()

    writeTest("Should write CFrame.new() to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeCFrame(CFrame.new())

        assert(buffer.dumpBinary() == "10000000 10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0", "")
    end).pass()

    writeTest("Should write CFrame.Angles(1, 2, 3) to the stream properly after a bit", function()
        local buffer = BitBuffer()

        buffer.writeBits(1)
        buffer.writeCFrame(CFrame.Angles(1, 2, 3))

        assert(buffer.dumpBinary() == "10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00011111 01101001 01110111 10101011 10011110 10111000 01000101 10101100 10011111 10110100 01100011 11011011 11011111 10010111 00110010 11110110 01011111 10010010 01001001 10101000 00011111 01011001 10100101 00011001 10011111 10001101 01110100 11001111 01011111 10100001 11000001 10000110 01011111 00110011 00011110 11100101 0", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after CFrame.new()", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new())
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 1", "")
    end).pass()

    writeTest("Should write a bit to the stream properly after CFrame.Angles(1, 2, 3)", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.Angles(1, 2, 3))
        buffer.writeBits(1)

        assert(buffer.dumpBinary() == "00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00111110 11010010 11101111 01010111 00111101 01110000 10001011 01011001 00111111 01101000 11000111 10110111 10111111 00101110 01100101 11101100 10111111 00100100 10010011 01010000 00111110 10110011 01001010 00110011 00111111 00011010 11101001 10011110 10111111 01000011 10000011 00001100 10111110 01100110 00111101 11001010 1", "")
    end).pass()

    readTest("Should require no arguments", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new())

        buffer.readCFrame()
    end).pass()

    readTest("Should read CFrame.new() from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new())

        assert(buffer.readCFrame() == CFrame.new(), "")
    end).pass()

    readTest("Should read CFrame.Angles(math.pi/2, 0, -math.pi) from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.Angles(math.pi/2, 0, -math.pi)) -- Oh boy I sure do love floating points

        local components = {buffer.readCFrame():GetComponents()}

        assert(components[1] == 0, "") -- 0
        assert(components[2] == 0, "") -- 0
        assert(components[3] == 0, "") -- 0

        assert(components[4] == -1, "") -- -1
        assert(components[5] == 0, "") -- 0 (-8.74227766e-08)
        assert(components[6] == 0, "") -- 0

        assert(components[7] == 0, "") -- 0 (-3.82137093e-15)
        assert(components[8] == 0, "") -- 0 (4.37113883e-08)
        assert(components[9] == -1, "") -- -1

        assert(components[10] == 0, "") -- 0 (8.74227766e-08)
        assert(components[11] == -1, "") -- -1
        assert(components[12] == 0, "") -- 0 (4.37113883e-08)
    end).pass()

    readTest("Should read CFrame.new(10, 20, 30)*CFrame.Angles(math.pi/2, 0, 0) from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.new(10, 20, 30)*CFrame.Angles(math.pi/2, 0, 0))

        local components = {buffer.readCFrame():GetComponents()}
        assert(components[1] == 10, "") -- 10
        assert(components[2] == 20, "") -- 20
        assert(components[3] == 30, "") -- 30

        assert(components[4] == 1, "") -- 1
        assert(components[5] == 0, "") -- 0
        assert(components[6] == 0, "") -- 0
        
        assert(components[7] == 0, "") -- 0
        assert(components[8] == -0, "") -- 0 (-4.37113883e-08)
        assert(components[9] == -1, "") -- -1
        
        assert(components[10] == 0, "") -- 0
        assert(components[11] == 1, "") -- 1
        assert(components[12] == 0, "") -- 0 (-4.37113883e-08)
    end).pass() 

    readTest("Should read CFrame.Angles(1, 2, 3) from the stream correctly", function()
        local buffer = BitBuffer()

        buffer.writeCFrame(CFrame.Angles(1, 2, 3))

        local components = {buffer.readCFrame():GetComponents()}
        assert(components[1] == 0, "") -- 0
        assert(components[2] == 0, "") -- 0
        assert(components[3] == 0, "") -- 0

        assert(components[4] == 0.4119822680950164794921875, "") -- 0.4119822680950164794921875
        assert(components[5] == 0.0587266422808170318603515625, "") -- 0.0587266422808170318603515625
        assert(components[6] == 0.909297406673431396484375, "") -- 0.909297406673431396484375
        
        assert(components[7] == -0.6812427043914794921875, "") -- -0.6812427043914794921875
        assert(components[8] == -0.64287281036376953125, "") -- -0.64287281036376953125
        assert(components[9] == 0.3501754701137542724609375, "") -- -0.3501754701137542724609375
        
        assert(components[10] == 0.60512721538543701171875, "") -- 0.60512721538543701171875
        assert(components[11] == -0.7637183666229248046875, "") -- -0.7637183666229248046875
        assert(components[12] == -0.2248450815677642822265625, "") -- -0.2248450815677642822265625
    end).pass()

    readTest("Should read CFrame.new() from the stream properly after a bit", function()
        local buffer = BitBuffer()

        local write = CFrame.new()

        buffer.writeBits(1)
        buffer.writeCFrame(write)

        buffer.readBits(1)

        assert(buffer.readCFrame() == write, "")
    end).pass()

    readTest("Should read CFrame.Angles(1, 2, 3) from the stream properly after a bit", function()
        local buffer = BitBuffer()

        local write = CFrame.Angles(1, 2, 3)

        buffer.writeBits(1)
        buffer.writeCFrame(write)

        buffer.readBits(1)

        assert(buffer.readCFrame() == write, "")
    end).pass()

    readTest("Should read a bit from the stream after CFrame.new()", function()
        local buffer = BitBuffer()

        local write = CFrame.new()

        buffer.writeCFrame(write)
        buffer.writeBits(1)

        buffer.readCFrame()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should read a bit from the stream after CFrame.Angles(1, 2, 3)", function()
        local buffer = BitBuffer()

        local write = CFrame.Angles(1, 2, 3)

        buffer.writeCFrame(write)
        buffer.writeBits(1)

        buffer.readCFrame()

        assert(buffer.readBits(1)[1] == 1, "")
    end).pass()

    readTest("Should not allow reading past the end of the stream with no remaining bytes", function()
        local buffer = BitBuffer()

        buffer.readCFrame()
    end).fail()

    readTest("Should not allow reading past the end of the stream with a non-zero byte remaining", function()
        local buffer = BitBuffer()

        buffer.writeByte(1)

        buffer.readCFrame()
    end).fail()

    readTest("Should not allow reading past the end of the stream with a zero byte remaining", function()
        local buffer = BitBuffer()

        buffer.writeByte(0)

        buffer.readCFrame()
    end).fail()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests