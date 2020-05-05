local try = require("try")

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
    "bools"
}

-- local trySpec = require("spec/try")
-- if not trySpec(try) then
--     print("trySpec failed")
--     return
-- end

for _, v in ipairs(specs) do
    local test = require("spec/"..v)
    test(try.new)
end

print(string.format("FINAL COUNT: %i PASSED, %s FAILED, %s DISABLED", try.reportFinal()))
