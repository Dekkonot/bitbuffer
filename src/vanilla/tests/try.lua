local finalPassCount = 0
local finalFailCount = 0
local finalDisabledCount = 0

local BLOCK_NAME_TEXT = "%s [%i succeeded, %i failed]:"
local TEST_DISABLED_TEXT = "   [ ] %s"
local TEST_SUCCESS_TEXT = "   [+] %s"
local TEST_FAIL_TEXT = "   [-] %s"

local TEST_NEEDS_PASS = "   %s NEEDS PASS/FAIL SPECIFICATION"

local SHOW_DISABLED_TESTS = false

local function newTry(blockName)
    if type(blockName) ~= "string" then
        error("arg #1 passed to try constructor must be a string")
    end
    local tests = { }
    local testNum = 1

    local function makeNewTest(_, testName, testFunc)
        if type(testName) ~= "string" then
            error("arg #1 passed to try block must be a string", 2)
        elseif type(testFunc) ~= "function" then
            error("arg #2 passed to try block must be a function", 2)
        end
        local testEntry = {
            testName, -- test name
            nil, -- should succeed
            true, -- should run
            testFunc -- the function to run
        }
        tests[testNum] = testEntry
        testNum = testNum+1

        local testControl
        testControl = {
            fail = function()
                testEntry[2] = false
                return testControl
            end,
            pass = function()
                testEntry[2] = true
                return testControl
            end,
            disable = function()
                testEntry[3] = false
                return testControl
            end,
            enable = function()
                testEntry[3] = true
                return testControl
            end,
        }

        setmetatable(testControl, {
            __index = function(_, index)
                error("invalid index to test: "..tostring(index).."'", 2)
            end
        })

        return testControl
    end

    local function runTests()
        local resultsText = {}
        local passedCount = 0
        local failedCount = 0
        for i, v in ipairs(tests) do
            local testName = v[1]
            local shouldSucceed = v[2]
            local shouldRun = v[3]
            local funct = v[4]
            if shouldRun then
                local success = pcall(funct)
                if success == shouldSucceed then
                    resultsText[i] = string.format(TEST_SUCCESS_TEXT, testName)
                    passedCount = passedCount+1
                    finalPassCount = finalPassCount+1
                else
                    resultsText[i] = string.format(TEST_FAIL_TEXT, testName)
                    failedCount = failedCount+1
                    finalFailCount = finalFailCount+1
                end
            else
                if SHOW_DISABLED_TESTS then
                    resultsText[i] = string.format(TEST_DISABLED_TEXT, testName)
                else
                    resultsText[i] = ""
                end
                finalDisabledCount = finalDisabledCount+1
            end
            if shouldSucceed == nil then
                resultsText[i] = string.format(TEST_NEEDS_PASS, testName)
            end
        end
        print(string.format(BLOCK_NAME_TEXT, blockName, passedCount, failedCount))
        for _, v in ipairs(resultsText) do
            if v ~= "" then
                print(v)
            end
        end
        print("") -- And an extra newline just for readability
        return failedCount == 0
    end

    return setmetatable({
        run = runTests,
    }, {
        __call = makeNewTest,
    })
end

local function reportFinal()
    return finalPassCount, finalFailCount, finalDisabledCount
end

return {new = newTry, reportFinal = reportFinal}