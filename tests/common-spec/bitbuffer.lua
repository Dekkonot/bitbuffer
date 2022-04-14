--!nocheck
local function makeTests(try, BitBuffer)
    local tests = try("BitBuffer tests")

    tests("Should accept no arguments to its constructor", function()
        BitBuffer()
    end).pass()

    tests("Should accept a string as an argument to its constructor", function()
        BitBuffer("Hello, world!")
    end).pass()

    tests("Should require the argument passed to its contructor to be either a string or nil", function()
        BitBuffer({})
    end).fail()

    tests("dumpString should dump the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.dumpString() == "Hello, world!", "")
    end).pass()

    tests("dumpString should work with more than 4096 characters in the buffer", function()
        local buffer = BitBuffer(string.rep("h", 4100))

        assert(buffer.dumpString() == string.rep("h", 4100), "")
    end).pass()

    tests("dumpBinary should dump the binary of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.dumpBinary() == "01001000 01100101 01101100 01101100 01101111 00101100 00100000 01110111 01101111 01110010 01101100 01100100 00100001", "")
    end).pass()

    tests("dumpBase64 output should be the expected length", function()
        local buffer = BitBuffer(string.rep("e", 12345))

        assert(#buffer.dumpBase64() == math.ceil(12345 / 3) * 4)
    end).pass()

    tests("dumpBase64 should dump the base64 of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.dumpBase64() == "SGVsbG8sIHdvcmxkIQ==", "")
    end).pass()

    tests("dumpBase64 shouldn't duplicate any characters", function()
        local buffer = BitBuffer(string.rep("e", 5000))

        assert(buffer.dumpBase64() == string.rep("ZWVl", 1666) .. "ZWU=")
    end).pass()

    tests("dumpBase64 should handle large output", function()
        local buffer = BitBuffer(string.rep("e", 13337))

        assert(buffer.dumpBase64() == string.rep("ZWVl", 4445) .. "ZWU=")
    end).pass()

    tests("dumpHex should dump the hex of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.dumpHex() == "48656c6c6f2c20776f726c6421", "")
    end).pass()

    tests("exportChunk should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.exportChunk({})
    end).fail()

    tests("exportChunk should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.exportChunk(math.pi)
    end).fail()

    tests("exportChunk should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.exportChunk(-1)
    end).fail()

    tests("exportChunk should require the argument be non-zero", function()
        local buffer = BitBuffer()

        buffer.exportChunk(0)
    end).fail()

    tests("exportChunk should correctly export every single byte and its position", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local last = 1
        for pos, chunk in buffer.exportChunk(1) do
            assert(pos == last, "")
            assert(chunk == string.sub(str, pos, pos), "")
            last = last+1
        end
    end).pass()

    tests("exportChunk should correctly export chunks correctly", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local iter = buffer.exportChunk(2)

        local pos, chunk = iter()
        assert(pos == 1, "")
        assert(chunk == "ab", "")
        pos, chunk = iter()
        assert(pos == 3, "")
        assert(chunk == "cd", "")
        pos, chunk = iter()
        assert(pos == 5, "")
        assert(chunk == "ef", "")
        pos, chunk = iter()
        assert(pos == 7, "")
        assert(chunk == "g", "")
    end).pass()

    tests("exportBase64Chunk should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.exportBase64Chunk({})
    end).fail()

    tests("exportBase64Chunk should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.exportBase64Chunk(math.pi)
    end).fail()

    tests("exportBase64Chunk should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.exportBase64Chunk(-1)
    end).fail()

    tests("exportBase64Chunk should require the argument be non-zero", function()
        local buffer = BitBuffer()

        buffer.exportBase64Chunk(0)
    end).fail()

    tests("exportBase64Chunk allow no arguments", function()
        local buffer = BitBuffer()

        buffer.exportBase64Chunk()
    end).pass()

    tests("exportBase64Chunk should correctly export every single byte", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local base64 = buffer.dumpBase64()

        local last = 1
        for chunk in buffer.exportBase64Chunk(1) do
            assert(chunk == string.sub(base64, last, last), "")
            last = last+1
        end
    end).pass()

    tests("exportBase64Chunk should export chunks correctly", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local iter = buffer.exportBase64Chunk(2)

        local chunk = iter()
        assert(chunk == "YW", "")
        chunk = iter()
        assert(chunk == "Jj", "")
        chunk = iter()
        assert(chunk == "ZG", "")
        chunk = iter()
        assert(chunk == "Vm", "")
        chunk = iter()
        assert(chunk == "Zw", "")
        chunk = iter()
        assert(chunk == "==", "")
    end).pass()

    tests("exportBase64Chunk should export large strings correctly", function()
        local str = string.rep("e", 140)
        local buffer = BitBuffer(str)

        local base64 = buffer.dumpBase64()

        local output = ""

        for chunk in buffer.exportBase64Chunk(10) do
            output = output..chunk
        end

        assert(base64 == output)
        assert(#base64 == #output)
    end).pass()

    tests("exportBase64Chunk shouldn't duplicate any characters", function()
        local buffer = BitBuffer(string.rep("e", 5000))

        local base64 = string.rep("ZWVl", 1666) .. "ZWU="

        local output = ""

        for chunk in buffer.exportBase64Chunk(0x1000) do
            output = output..chunk
        end

        assert(base64 == output)
        assert(#base64 == #output)
    end).pass()

    tests("exportHexChunk should require the argument be a number", function()
        local buffer = BitBuffer()

        buffer.exportHexChunk({})
    end).fail()

    tests("exportHexChunk should require the argument be an integer", function()
        local buffer = BitBuffer()

        buffer.exportHexChunk(math.pi)
    end).fail()

    tests("exportHexChunk should require the argument be positive", function()
        local buffer = BitBuffer()

        buffer.exportHexChunk(-1)
    end).fail()

    tests("exportHexChunk should require the argument be non-zero", function()
        local buffer = BitBuffer()

        buffer.exportHexChunk(0)
    end).fail()


    tests("exportHexChunk should correctly export every single byte", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local hex = buffer.dumpHex()

        local last = 1
        for chunk in buffer.exportHexChunk(1) do
            assert(#chunk == 1, "")
            assert(chunk == string.sub(hex, last, last), "")
            last = last+1
        end
    end).pass()

    tests("exportHexChunk should export chunks correctly", function()
        local str = "abcdefg"
        local buffer = BitBuffer(str)

        local iter = buffer.exportHexChunk(2)

        local chunk = iter()
        assert(chunk == "61", "")
        chunk = iter()
        assert(chunk == "62", "")
        chunk = iter()
        assert(chunk == "63", "")
        chunk = iter()
        assert(chunk == "64", "")
        chunk = iter()
        assert(chunk == "65", "")
        chunk = iter()
        assert(chunk == "66", "")
    end).pass()

    tests("exportHexChunk should export large strings correctly", function()
        local str = string.rep("e", 140)
        local buffer = BitBuffer(str)

        local hex = buffer.dumpHex()

        local output = ""

        for chunk in buffer.exportHexChunk(10) do
            output = output..chunk
        end

        assert(hex == output)
        assert(#hex == #output)
    end).pass()


    tests("crc32 should correctly calculate the crc32 checksum of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.crc32() == 0xebe6c6e6, "")
    end).pass()

    tests("getLength should return the length of the buffer in bits", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getLength() == 104, "")
    end).pass()

    tests("getByteLength should return the length of the buffer in bytes", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getByteLength() == 13, "")
    end).pass()

    tests("getPointer should return the pointer", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getPointer() == 0, "")
    end).pass()

    tests("setPointer should require its argument be a number", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer({})
    end).fail()

    tests("setPointer should require its argument be an integer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(math.pi)
    end).fail()

    tests("setPointer should require its argument be positive", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(-1)
    end).fail()

    tests("setPointer should not allow its argument to be past the end of the stream", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(200)
    end).fail()

    tests("setPointer should allow its argument be zero", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(0)
    end).pass()

    tests("setPointer should set the pointer to the argument", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(4)

        assert(buffer.getPointer() == 4, "")
    end).pass()

    tests("setPointerFromEnd should require its argument be a number", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd({})
    end).fail()

    tests("setPointerFromEnd should require its argument be an integer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd(math.pi)
    end).fail()

    tests("setPointerFromEnd should require its argument be positive", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd(-1)
    end).fail()

    tests("setPointerFromEnd should not allow its argument to be be greater than the size of the buffer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd(200)
    end).fail()

    tests("setPointerFromEnd should allow its argument be 0", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd(0)
    end).pass()

    tests("setPointerFromEnd should set the pointer relative to the end of the stream", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerFromEnd(4)

        assert(buffer.getPointer() == 100, "")
    end).pass()

    tests("getPointerByte should require no arguments", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.getPointerByte()
    end).pass()

    tests("getPointerByte should return the byte is at without any pointer modifications", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getPointerByte() == 1, "")
    end).pass()


    tests("getPointerByte should return the byte the pointer is at after pointer modification", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(9)

        assert(buffer.getPointerByte() == 2, "")
    end).pass()

    tests("setPointerByte should require the argument be a number", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte({})
    end).fail()

    tests("setPointerByte should require the argument be an integer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(math.pi)
    end).fail()

    tests("setPointerByte should require the argument be positive", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(-1)
    end).fail()

    tests("setPointerByte should not allow its argument to be past the end of the stream", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(20)
    end).fail()

    tests("setPointerByte should not allow its argument to be zero", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(0)
    end).fail()

    tests("setPointerByte should set the pointer byte to its argument", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(2)

        assert(buffer.getPointerByte() == 2, "")
    end).pass()

    tests("setPointerByte should set the pointer in bits correctly", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByte(2)

        assert(buffer.getPointer() == 16, "")
    end).pass()

    tests("setPointerByteFromEnd should require the argument be a number", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd({})
    end).fail()

    tests("setPointerByteFromEnd should require the argument be an integer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(math.pi)
    end).fail()

    tests("setPointerByteFromEnd should require the argument be positive", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(-1)
    end).fail()

    tests("setPointerByteFromEnd should not allow its argument to be be greater than the size of the buffer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(20)
    end).fail()

    tests("setPointerByteFromEnd should allow its argument to be zero", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(0)
    end).pass()

    tests("setPointerByteFromEnd should set the pointer byte relative to the end of the stream", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(1)

        assert(buffer.getPointerByte() == 12, "")
    end).pass()

    tests("setPointerByte should set the pointer in bits correctly relative to the end of the stream", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointerByteFromEnd(1)

        assert(buffer.getPointer() == 96, "")
    end).pass()

    tests("isFinished should require no arguments", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.isFinished()
    end).pass()

    tests("isFinished should return false when the pointer is not at the end of the buffer", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.isFinished() == false, "")
    end).pass()

    tests("isFinished should return true when the pointer is at the end of the buffer", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(13*8)

        assert(buffer.isFinished() == true, "")
    end).pass()

    return tests.run()
end

return makeTests