local BitBuffer = require("src.vanilla")

local buffer = BitBuffer()

local clock = os.clock
local specialized, generic
local generic_arg1, generic_arg2

local v = ...

if v == "u8" then
    specialized = buffer.writeUInt8
    generic = buffer.writeByte
elseif v == "u16" then
    specialized = buffer.writeUInt16
    generic = buffer.writeUnsigned
    generic_arg1 = 16
elseif v == "u32" then
    specialized = buffer.writeUInt32
    generic = buffer.writeUnsigned
    generic_arg1 = 32
elseif v == "i8" then
    specialized = buffer.writeInt8
    generic = buffer.writeSigned
    generic_arg1 = 8
elseif v == "i16" then
    specialized = buffer.writeInt16
    generic = buffer.writeSigned
    generic_arg1 = 16
elseif v == "i32" then
    specialized = buffer.writeInt32
    generic = buffer.writeSigned
    generic_arg1 = 32
elseif v == "f16" then
    specialized = buffer.writeFloat16
    generic = buffer.writeFloat
    generic_arg1 = 5
    generic_arg2 = 10
elseif v == "f32" then
    specialized = buffer.writeFloat32
    generic = buffer.writeFloat
    generic_arg1 = 8
    generic_arg2 = 23
elseif v == "f64" then
    specialized = buffer.writeFloat64
    generic = buffer.writeFloat
    generic_arg1 = 11
    generic_arg2 = 52
end
if not specialized or not generic then
    print("Argument must start with u, i, or f and end with 8, 16, 32, or 64 -- f8, u64, and i64 do not exist")
    return
end

local i1, i2 = 0, 0
local t1 = clock()

while clock()-t1 <= 1 do
    specialized(64)
    i1 = i1+1
end

if generic_arg1 and generic_arg2 then
    local t2 = clock()
    while clock()-t2 <= 1 do
        generic(generic_arg1, generic_arg2, 64)
        i2 = i2+1
    end
elseif generic_arg1 then
    local t2 = clock()
    while clock()-t2 <= 1 do
        generic(generic_arg1, 64)
        i2 = i2+1
    end
else
    local t2 = clock()
    while clock()-t2 <= 1 do
        generic(64)
        i2 = i2+1
    end
end

local ratio1 = math.floor((i1/i2)*100)
local ratio2 = math.floor((i2/i1)*100)

print(string.format("Iterations in 1s for %s:", v))
print(string.format("  Specialized: %i - %s", i1, string.format("%i%% of generic", ratio1)))
print(string.format("  Generic:     %i - %s", i2, string.format("%i%% of specialized", ratio2)))