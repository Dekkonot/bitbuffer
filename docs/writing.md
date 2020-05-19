!!! info "This example covers writing binary data with the module"
    If you're interested in using the module to read binary data, check out the [second example](reading.md).

The BitBuffer is designed to have both a simple and powerful API. As a rather contrived example, imagine you were developing a game and had the following data:

```lua
local data = {
    name = "John Doe",
    health = 100,
    maxHealth = 100,
    points = 10,
    position = {
        x = 10.55915,
        y = -15.2222,
    },
    bossesKilled = { true, false, true },
}
```

If you wanted to save that data normally, you might JSON it and write it to a file, which would end up looking something like this:
```json
{"health":100,"points":10,"bossesKilled":[true,false,true],"maxHealth":100,"position":{"x":10.5591500,"y":-15.2222000},"name":"John Doe"}
```

Assuming you truncate the position values like above, that's 137 bytes.

Using the following code, that would be cut down to 26 bytes.

```lua
local BitBuffer = ... -- The BitBuffer should be required here.

local buffer = BitBuffer()

buffer.writeString(data.name)
buffer.writeUInt16(data.health) -- This is assuming someone's health will get above 255 but stay below 32,767
buffer.writeUInt16(data.maxHealth)
buffer.writeUInt16(data.points) -- Also assuming someone's points will stay rather low
buffer.writeFloat32(data.position.x)
buffer.writeFloat32(data.position.y)
buffer.writeField(table.unpack(data.bossesKilled))

-- To do the math: 11 bytes for name (length prefix + raw bytes), 2 each for health, maxHealth, and points, 
-- 8 for position, and an extra 1 for bossesKilled (though you could write 5 more bools without loosing any space!). 
-- 11+6+8+1 = 26

local output = buffer.dumpString()

-- And then write that to a file
```

On any modern PC, a difference of 95 bytes doesn't matter too much. But if you were limited by space, it would easily be worth taking the time to write the save information like this.