local BitBuffer = require("bitBuffer")

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

    tests("crc32 should correctly calculate the crc32 checksum of the buffer's contents", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.crc32() == 0xebe6c6e6, "")
    end).pass()

    tests("getLength should return the length of the buffer in bytes", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getLength() == 13, "")
    end).pass()

    tests("getBitLength should return the length of the buffer in bits", function()
        local buffer = BitBuffer("Hello, world!")

        assert(buffer.getBitLength() == 104, "")
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

    tests("setPointer should allow its argument be zero", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(0)
    end).pass()

    tests("setPointer should set the pointer to the argument", function()
        local buffer = BitBuffer("Hello, world!")

        buffer.setPointer(4)

        assert(buffer.getPointer() == 4, "")
    end).pass()

    return tests.run()
end

return makeTests