local BitBuffer = require(script.Parent.Parent.Parent)

local function makeTests(try)
    local writeTest = try("write__ tests")
    local readTest = try("read__ tests")

    writeTest("writeTest test", function()
        local buffer = BitBuffer()

        buffer.getPointer()
    end).pass()

    readTest("readTest test", function()
        local buffer = BitBuffer()

        buffer.getPointer()
    end).pass()

    local writeTestPassed = writeTest.run()
    local readTestPassed = readTest.run()


    return writeTestPassed and readTestPassed
end

return makeTests