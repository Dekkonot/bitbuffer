!!! info "This example covers reading binary data with the module"
    If you're interested in using the module to write binary data, check out the [first example](writing.md).

The BitBuffer is also designed to easily read binary data. This is useful for all sorts of situations, but for this example the information written in the previous page will be used. To review, that data structure looked like this:

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

After the information was written with the BitBuffer to a file, it can be read issue with the buffer. It's as simple as reading the file contents, creating a BitBuffer with the content, and calling the respective read functions **in order**. If the file is read out of order, or the wrong datatypes are read, it will give unexpected results.

```lua
local BitBuffer = ... -- The BitBuffer should be required here.
local fileContents = ... -- The contents of the file should be put here.

local data = {}

local buffer = BitBuffer(fileContents) -- This creates a new BitBuffer with `fileContents` inside it

data.name = buffer:readString()
data.health = buffer:readInt16()
data.maxHealth = buffer:readInt16()
data.points = buffer:readInt16()
data.position = {
    x = buffer:readFloat32(),
    y = buffer:readFloat32(),
}
data.bossesKilled = buffer:readField(3)
```

With minimal effort, the data is restored... For the most part. All floating point numbers are subject to minor errors, and unfortunately the BitBuffer is no different. As a result, the `position` data read above will not be exactly correct. This is unavoidable and cannot be fixed. If you want to minimize floating point errors, use integers, or write Float64s instead of Float32s.

## Technical Info

This section analyzes the actual output of the BitBuffer and looks at what each byte is for the sake of knowledge.

If viewed in a hex editor ([HxD](https://mh-nexus.de/en/hxd/) is recommended), the above data structure looks like this when written to the file:
```
00 00 08 4A 6F 68 6E 20 44 6F 65 00 64 00 64 00 0A 41 28 F2 47 C1 73 8E 22 A0
```
As mentioned above, the data has to be read in the order it was written in.

So, `data.name` is first. Since `writeString` was used to write the name, a 24-bit unsigned integer was written to indicate how long the string is, then the raw bytes of the string are written. Since the number `0x000008` is 8, the string is 8 bytes long, which means it's `4A 6F 68 6E 20 44 6F 65` or `John Doe` when translated to ASCII.

Next, `data.health`. This was written as a 16-bit unsigned integer, which means that the value is `0x0064`, or `100` in decimal. This process is repeated for `data.maxHealth` and `data.points`, which are `0x0064` and `0x000A` (or `100` and `10`).

Next, the position values `data.position.x` and `data.position.y`. These were written as 32-bit floating point numbers, which means that 4 bytes have to be read for each, which are `41 28 F2 47` and `C1 73 8E 22` respectively. Rather than explaining floating point numbers in full here, these can be plugged into a site like [float.exposed](https://float.exposed/) to read their values. When plugged into that site (32-bit floats are commonly called singles) `0x4128F247` is `10.5591497421264648438` and `0xC1738E22` is read as `-15.2222003936767578125`.

Finally, `data.bossesKilled` is written as a bitfield of three bools. Because individual bits can't be written to a file, the spare 5 bits are filled with 0s and written as well. The last byte in the file (`A0`) is `10100000` in binary. Reading the first three bits of the byte gives `101` or `{true, false, true}`.
