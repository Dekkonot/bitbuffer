-- In a twist of fate, we now have to test the test framework
local function makeTests(try)

    local tests = try("Try Tests")

    tests("Should pass #1", function()
        assert(2+2 == 4, "Oh no")
    end).pass()

    tests("Should pass #2", function()
        string.byte("a")
    end).pass()

    tests("Should pass #3", function()

    end).pass()

    tests("Should fail #1", function()
        assert(2+2 == 10, "Reality has set in")
    end).fail()

    tests("Should fail #2", function()
        string.byte(true)
    end).fail()

    tests("Should fail #3", function()
        error("")
    end).fail()

    tests("Should be disabled #1", function()
        error("")
    end).disable()

    tests("Should be disabled #2", function()

    end).disable()

    return tests.run()
end

return makeTests