Installing the module is rather simple. The only file that's needed for the actual BitBuffer is [the main one](https://github.com/dekkonot/bitbuffer/tree/master/src/vanilla/init.lua). Copy the contents of that file to a Lua file if you're using vanilla Lua or a ModuleScript if you're using Roblox, and it's ready to go.

## For Roblox users

All Roblox-specific files are stored in the [Roblox source folder](https://github.com/dekkonot/bitbuffer/tree/master/src/roblox). If you're using Roblox, you should probably use the files there. The Roblox version makes use of `table.create` and will eventually have type annotations. The test files are also translated over to work in Roblox, and a Rojo project file is included to build the module and its tests into a model for convenience.