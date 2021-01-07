local try = require("src.try")

local BitBuffer = require("src.vanilla.init")
local CommonSpec = "src.common-spec.init"
local commonSpecModuleNames = require(CommonSpec)

local function runTestModule(name, parent)
    local testModule = parent:FindFirstChild(name)
    assert(testModule, 'unable to find spec file: ' .. name)
    local test = require(testModule)
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
