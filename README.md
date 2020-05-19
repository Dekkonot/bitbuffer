# [Read The Documentation](https://dekkonot.github.io/bitbuffer/)

BitBuffer is a bit stream module implemented in pure Lua. Its purpose is to provide an easy way to write and read binary data down to the bit level. It first found life as a replacement for a module that performed rather poorly, and was primarily meant for use on Roblox.

However, no Roblox specific API is used in the main file or tests of this module. The module was written and tested using Lua 5.2, though any version of Lua that has a bit module should be able to run this module with a few modifications. It will probably perform best with LuaJIT, as Roblox's Lua VM is extremely fast compared to PUC-Rio and this module makes use of some specific optimizations (ipairs, as an example, is faster than a numeric for in Roblox).

## Why?

Numbers take up a lot of space. Take the number `24930`. On its own, it's 5 bytes of space. That's not an awful lot, but if you had to save hundreds of thousands of numbers of a similiar size, that's a lot of space spent on numbers alone.

When written with this BitBuffer though, `24930` only takes up 2 bytes and becomes `ab`.

Obviously, the two bytes taken up by `ab` is less than the 5 bytes taken up by `24930`. This difference gets a lot more dramatic the bigger the number: `1633837924` is 10 bytes to write out but in binary is `abcd`, and `107075202213222` is 15 bytes but turns into `abcdef`. That's a difference of 9 bytes per number!

For more information, visit the documentation site!
