BitBuffer is a binary stream module implemented in pure Lua. Its purpose is to provide an easy way to write and read binary data down to the bit level. It first found life as a replacement for a BitBuffer that performed rather poorly, and was meant for use on Roblox. To that end, there is a [Rojo](https://github.com/rojo-rbx/rojo) project file in the [Roblox subfolder](src/roblox) that can be used to build it for Roblox.

However, no Roblox specific API is used in the main file or tests of this buffer. The module was written and tested using Lua 5.2, and any version of Lua that has a bit module should be able to run this module with only minor modifications. It will probably perform best with LuaJIT, as Roblox's Lua VM is extremely fast compared to PUC-Rio and this module makes use of some specific optimizations (ipairs, as an example, is faster than a numeric for in Luau).

Given only basic `bit32` functions are used (shifting, AND, btest, extract) for the core functionality of this module, it should be trivial to remove them if your environment doesn't have a bit module. The only core bitwise operation not trivially replicated in arithmetic, XOR, is used only to calculate the checksum functions, which can be removed without harming the module.

## Why?

Numbers take up a lot of space. Take the number `24930`. On its own, it's 5 bytes of space. That's not an awful lot, but if you had to save hundreds of thousands of numbers of a similiar size, that's a lot of space spent on numbers alone.

When written as binary data though, `24930` only takes up 2 bytes and becomes `ab`.

Obviously, the two bytes taken up by `ab` is less than the 5 bytes taken up by `24930`. This difference gets a lot more dramatic the bigger the number: `1633837924` is 10 bytes to write out but in binary is `abcd`, and `7017280452245743464` is 19 bytes but turns into `abcdefgh`. That's a difference of 11 bytes per number!

## Support

By default, the BitBuffer only supports basic data types (specifically bits, integers, floats, and strings) and some common variants of them.

Custom structs (Vectors, coordinates, etc.) can be added rather easily by modifying [the module](init.lua) however.

The module also obviously supports importing and exporting data to and from the stream. The constructor takes a string, which it will convert to a stream, and a buffer object has some functions to easily export the data inside. These are documented in [API Reference](api-reference.md).

## Limitations

A limit for the width of all numbers is hardcoded to  be 64-bits. However, as Lua numbers are doubles, the maximum precision for them is actually 53-bits. You should be wary when storing data that might reach or exceed that limit.

## Technical details

This BitBuffer is big-endian. It follows the IEEE-754 format for floating points. Signed integers are stored using two's complements, as you would expect. By default, strings are written and read by prefixing the length as an unsigned 24-bit integer.