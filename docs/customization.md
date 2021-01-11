!!! tip "Attention Roblox users"
    This is important information, but it's a lot less important for Roblox developers. The Roblox variant of this module already has all of the Roblox data types in it. 

By default, the BitBuffer doesn't have any complex datatypes in it. It only has the ability to write bits, bytes, unsigned and signed integers, floats, and strings. It also comes out of the box with a few functions to make writing standard sizes more convenient (stuff like being able to call `writeUInt32(X)` instead of `writeUnsigned(32, X)`).

For some enviroments, it might make sense to have shorthands for writing longer data pieces though. In [the example](writing.md), there's a table that looks like this:

```lua
{
    x = 10.55915,
    y = -15.2222,
}
```

If this sort of structure shows up in data quite often, it would make sense to write a seperate set of functions in the module to write and read it. Those functions can be written and inserted into the module easily and used from there. They should go after all the built-in functions (so that those functions can be used in your own function) and added to the return table at the bottom of the constructor.

Functions of that sort can be written as follows. In this example, the data structure is called a Vector2.

```lua
-- All the other functions above

local function writeVector2(vector)
    buffer.writeFloat32(vector.x)
    buffer.writeFloat32(vector.y)
end

local function readVector2(vector)
    local x = buffer.readFloat32(vector.x)
    local y = buffer.readFloat32(vector.y)
    return x, y
end

return {
    -- All of the built-in functions

    writeVector2 = writeVector2,
    readVector2 = readVector2,
}
```

If that example isn't sufficient, there are several present in the [Roblox version](https://github.com/Dekkonot/bitbuffer/blob/main/src/roblox.lua) of the module.
