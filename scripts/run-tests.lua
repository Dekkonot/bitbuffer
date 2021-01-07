local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BitBuffer = require(ReplicatedStorage.BitBuffer)
local CommonSpec = ReplicatedStorage.BitBuffer.CommonSpec
local Spec = ReplicatedStorage.BitBuffer.Tests.spec

local commonSpecModuleNames = require(CommonSpec)
local robloxSpecModuleNames = require(Spec)
local try = require(ReplicatedStorage.try)

local function runTestModule(name, parent)
    local testModule = parent:FindFirstChild(name)
    assert(testModule, 'unable to find spec file: ' .. name)
    local test = require(testModule)
    test(try.new, BitBuffer)
end

for _, name in ipairs(commonSpecModuleNames) do
    runTestModule(name, CommonSpec)
end

for _, name in ipairs(robloxSpecModuleNames) do
    runTestModule(name, Spec)
end

local finalPass, finalFail, finalDisabled = try.reportFinal()

print(string.format("FINAL COUNT: %i PASSED, %s FAILED, %s DISABLED", finalPass, finalFail, finalDisabled))
