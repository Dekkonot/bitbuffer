BitBuffer is a bit stream module implemented in pure Lua. Its purpose is to provide an easy way to write and read binary data down to the bit level. It first found life as a replacement for a module that performed rather poorly, and was primarily meant for use on Roblox.

However, no Roblox specific API is used in the main file or tests of the module. The module was written and tested using Lua 5.2, though any version of Lua that has a bit module should be able to run this module with a few modifications. It will probably perform best with LuaJIT, as Roblox's Lua VM is extremely fast compared to PUC-Rio and this module makes use of some specific optimizations (ipairs, as an example, is faster than a numeric for in Roblox).

## Why?

Numbers take up a lot of space. Take the number `24930`. When written out, it's 5 bytes. That's not an awful lot, but if you had to save hundreds of thousands of numbers of a similiar size, that's a lot of space spent on numbers alone.

When written with this BitBuffer though, `24930` only takes up 2 bytes and becomes `ab`.

??? info "Interested how?"
    The number `24930` is `110000101100010` in binary, which is 15 bits long. Padding it to be exactly 16 bits (2 bytes evenly), it becomes `110000101100010`. That can be split into `01100001` and `01100010`, which are equivalent to `a` and `b` respectively. Thus, `ab` is the binary equivalent to `24930`.

Obviously, the two bytes taken up by `ab` is less than the 5 bytes taken up by `24930`. This difference gets a lot more dramatic the bigger the number: `1633837924` is 10 bytes to write out but in binary is `abcd`, and `107075202213222` is 15 bytes but turns into `abcdef`. That's a difference of 9 bytes per number!

## Support

By default, the BitBuffer only supports basic data types (specifically bits, integers, floats, and strings) and some common variants of them.

Custom structs (Vectors, coordinates, etc.) can be added rather easily by modifying [the module](https://github.com/dekkonot/bitbuffer/blob/master/src/vanilla/init.lua) however. An example of this is found under [*Customization*](customization.md).

The module also obviously supports importing and exporting data to and from the stream. The constructor takes a string, which it will convert to a stream, and a buffer object has some functions to easily export the data inside. These are documented in [*Main Functions*](api-main.md).

## Limitations

A limit for the width of all numbers is hardcoded to  be 64-bits. However, as Lua numbers are doubles, the maximum precision for them is actually 53 bits. If you need to store numbers at that size, you should consider alternatives regardless of whether you use the BitBuffer.

## Technical details

Data written with the BitBuffer is big-endian. It follows the IEEE-754 format for floating points. Signed integers are stored using two's complements, as you would expect. By default, strings are written and read by prefixing the length as an unsigned 24-bit integer.

There are a variety of tests that can be run in the [tests folder](https://github.com/dekkonot/bitbuffer/tree/master/src/vanilla/tests) to verify the functionality of the module. They expect a file named `bitbuffer.lua` that contains the main module.