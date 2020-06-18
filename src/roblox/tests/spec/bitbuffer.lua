local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
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

    tests("dumpBase64 should dump the base64 of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")
        
        assert(buffer.dumpBase64() == "SGVsbG8sIHdvcmxkIQ==", "")
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