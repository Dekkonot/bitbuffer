local try = require(script.try)

local specs = {
    "bitbuffer",
    "bit",
    "byte",
    "unsigned",
    "signed",
    "float",
    "string",
    "terminatedstring",
    "setlengthstring",
    "field"
}

-- local trySpec = require("spec/try")
-- if not trySpec(try) then
--     print("trySpec failed")
--     return
-- end

for _, v in ipairs(specs) do
    local test = require(script.spec:FindFirstChild(v))
    test(try.new)
end

local finalPass, finalFail, finalDisabled = try.reportFinal()

print(string.format("FINAL COUNT: %i PASSED, %s FAILED, %s DISABLED", finalPass, finalFail, finalDisabled))

--todo when Roblox CLI comes out, make process exit

return finalFail == 0