--# selene: allow(incorrect_standard_library_use)

local try = require("tests.try")

local BitBuffer = require("src.vanilla")
local CommonSpec = "tests.common-spec"
local commonSpecModuleNames = require(CommonSpec .. ".init")

local function runTestModule(name, parent)
    local test = require(parent .. "." .. name)
    test(try.new, BitBuffer)
end

for _, name in ipairs(commonSpecModuleNames) do
    runTestModule(name, CommonSpec)
end

local finalPass, finalFail, finalDisabled = try.reportFinal()

print(string.format("FINAL COUNT: %i PASSED, %s FAILED, %s DISABLED", finalPass, finalFail, finalDisabled))

if finalFail ~= 0 then
    os.exit(false)
end
