This page covers all of the main functions of the BitBuffer. These include the constructor, functions to get the data out of the BitBuffer, and its main read/write functions. Abstract functions, like `writeUnsigned` (which allows writing an integer of arbitrary size) aren't documented on this page since they shouldn't generally see use in a normal project.

However, they're still useful and are thus documented in [*Abstract Functions*](api-base.md). Functions that are specific to the Roblox version of the BitBuffer are documented in [*Roblox Functions*](api-roblox.md).

??? abstract "Type Information"
    This API reference provides the argument and return types for the various functions. They will hopefully be self-explanatory, but as a brief overview, the type of arguments look like this: `x: number` and means that `x` is a `number`. If an argument's type is followed by a `?`, it means the argument is optional. The return type of a function follows a `->`.

    Thus, `BitBuffer(stream: string?) -> BitBuffer` means that the function `BitBuffer` optionally takes a string as an argument and returns a BitBuffer.

## BitBuffer

### Constructor

```
BitBuffer(stream: string?) -> BitBuffer
```

Creates a new BitBuffer object and fills it with `stream` if it's provided. Otherwise, returns an empty BitBuffer.

### getPointer

```
BitBuffer.getPointer() -> integer
```
Returns where the pointer is in the stream. The pointer is the bit from which the various [Read functions](#read-functions) operate.

### setPointer

```
BitBuffer.setPointer(n: integer) -> nil
```
Sets where the pointer is in the stream in bits.

### setPointerFromEnd

```
BitBuffer.setPointerFromEnd(n: integer) -> nil
```
Sets the pointer in bits from the end of the stream. Equivalent to `setPointer(getBitLength()-n)`.

### getPointerByte

```
BitBuffer.getPointerByte() -> integer
```
Returns the byte the pointer is at in the stream.

### setPointerByte

```
BitBuffer.setPointerByte(n: integer) -> nil
```
Sets where the pointer is in the stream in bytes.

### setPointerByteFromEnd

```
BitBuffer.setPointerByteFromEnd(n: integer) -> nil
```
Sets the pointer in bytes from the end of the stream. Equivalent to `setPointerByte(getLength()-n)`.

### getLength

```
BitBuffer.getLength() -> integer
```
Returns the length of the internal buffer in bits.

### getByteLength

```
BitBuffer.getByteLength() -> integer
```
Returns the length of the internal buffer in bytes.

### isFinished

```
BitBuffer.isFinished() -> boolean
```
Returns whether or not the buffer has data left in it to read.

## Export functions

The following functions are all intended to get data *out* of the BitBuffer in some way.

### dumpBinary

```
BitBuffer.dumpBinary() -> string
```
Returns a string of binary digits that represents the content of the BitBuffer. This is primarily intended for debugging or testing purposes.

### dumpString

```
BitBuffer.dumpString() -> string
```
Returns the raw binary content of the BitBuffer. This function is one of the main methods for getting things out of the buffer, and outputs the raw binary data.

### dumpBase64

```
BitBuffer.dumpBase64() -> string
```
Returns the base64 encoded content of the BitBuffer. This function doesn't add linebreaks to the data.

### dumpHex

```
BitBuffer.dumpHex() -> string
```
Returns a string of hex characters representing the contents of the BitBuffer.

### exportChunk

```
BitBuffer.exportChunk(chunkLength: integer) -> iterator() -> i: integer, chunk: string
```
Returns an iterator function that can be used to get individual chunks and their position in the Buffer.

```lua
local buffer = BitBuffer("foo|bar|baz")
for position, chunk in buffer.exportChunk(4) do
    print(position, chunk)
end
```

Would output:
```
1   foo|
5   bar|
9   baz
```

### exportBase64Chunk

```
BitBuffer.exportBase64Chunk(chunkLength: integer)- > iterator() -> chunk: string
```
Returns an iterator function that can be used to get individual chunks of the Buffer, encoded to Base64. The `chunkLength` argument is the size of the Base64 output, not the size of the chunk pre-encoding.

```lua
local buffer = BitBuffer("foo|bar|baz")
for chunk in buffer.exportBase64Chunk(4) do
    print(chunk)
end
```

Would output:
```
Zm9v
fGJh
cnxi
YXo=
```

### exportHexChunk

```
BitBuffer.exportHexChunk(chunkLength: integer)- > iterator() -> chunk: string
```
Returns an iterator function that can be used to get individual chunks of the Buffer with their bytes in hex. The `chunkLength` argument is the size of the hex output, not the size of the chunk pre-encoding.

```lua
local buffer = BitBuffer("foo|bar|baz")
for chunk in buffer.exportHexChunk(8) do
    print(chunk)
end
```

Would output:
```
666f6f7c
6261727c
62617a
```

### crc32

```
BitBuffer.crc32() -> integer
```
Returns the CRC-32 checksum of the BitBuffer's contents.

## Write functions

The following functions are all intended to write data to the BitBuffer. With little exception, they're more efficient than calling their abstract equivalents and should be used over them.

### writeUInt8

```
BitBuffer.writeUInt8(n: integer) -> nil
```
Writes the unsigned 8-bit integer `n` to the BitBuffer. Directly calls `BitBuffer.writeByte`, but included for the sake of completion.

### writeUInt16

```
BitBuffer.writeUInt16(n: integer) -> nil
```
Writes the unsigned 16-bit integer `n` to the BitBuffer.

### writeUInt32

```
BitBuffer.writeUInt32(n: integer) -> nil
```
Writes the unsigned 32-bit integer `n` to the BitBuffer.

### writeInt8

```
BitBuffer.writeUInt8(n: integer) -> nil
```
Writes the signed 8-bit integer `n` to the BitBuffer.

### writeInt16

```
BitBuffer.writeUInt16(n: integer) -> nil
```
Writes the signed 16-bit integer `n` to the BitBuffer.

### writeInt32

```
BitBuffer.writeUInt32(n: integer) -> nil
```
Writes the signed 32-bit integer `n` to the BitBuffer.

### writeFloat16

```
BitBuffer.writeFloat16(n: number) -> nil
```
Writes a [half-precision](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) (16-bit) floating point number to the BitBuffer.

### writeFloat32

```
BitBuffer.writeFloat32(n: number) -> nil
```
Writes a [single-precision](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) (32-bit) floating point number to the BitBuffer.

### writeFloat64

```
BitBuffer.writeFloat64(n: number) -> nil
```
Writes a [double-precision](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) (64-bit) floating point number to the BitBuffer. In most installs of Lua (including Roblox), all Lua numbers are doubles, so this should be used if the precision of a number is important.

### writeString

```
BitBuffer.writeString(str: string) -> nil
```
Writes a length-prefixed string to the BitBuffer. The length is written as a 24-bit unsigned integer before the bytes of the string.

### writeTerminatedString

```
BitBuffer.writeTerminatedString(str: string) -> nil
```
Writes a null-terminated string to the BitBuffer. For efficiency's sake, this function doesn't check to see if `str` contains an embedded `\0` character, so plan accordingly.

### writeSetLengthString

```
BitBuffer.writeSetLengthString(str: string) -> nil
```
Writes a set-length string to the BitBuffer. No information is stored about the length of the string -- readSetLengthString requires the length of the written string to read.

### writeField

!!! warning "Potential Performance Issue"
    Although this function allows for writing fields that aren't a multiple of 8 bits long, it can cause performance problems for subsequent writes because of the math involved. You should try to keep writeField calls to the end of the file or make sure they're multiples of 8.

```
BitBuffer.writeField(...: any) -> nil
```
Writes a bitfield with a bit for every argument passed. If the argument is truthy, the bit is `1`. Otherwise, it's `false`. The max number of arguments able to be passed to this function is 53 (see [the section on limitations](index.md#limitations)).

## Read functions

The following functions are all intended to read data from the BitBuffer. With little exception, they're more efficient than calling their abstract equivalents and should be used over them.

### readUInt8

```
BitBuffer.readUInt8() -> integer
```
Reads an 8-bit unsigned integer from the BitBuffer and returns it.

### readUInt16

```
BitBuffer.readUInt16() -> integer
```
Reads a 16-bit unsigned integer from the BitBuffer and returns it.

### readUInt32

```
BitBuffer.readUInt32() -> integer
```
Reads a 32-bit unsigned integer from the BitBuffer and returns it.

### readInt8

```
BitBuffer.readInt8() -> integer
```
Reads an 8-bit signed integer from the BitBuffer and returns it.

### readInt16

```
BitBuffer.readInt16() -> integer
```
Reads a 16-bit signed integer from the BitBuffer and returns it.

### readInt32

```
BitBuffer.readInt32() -> integer
```
Reads an 32-bit signed integer from the BitBuffer and returns it.

### readFloat16

```
BitBuffer.readFloat16() -> number
```
Reads a [half-precision](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) (16-bit) floating point number from the BitBuffer and returns it.

### readFloat32

```
BitBuffer.readFloat32() -> number
```
Reads a [single-precision](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) (32-bit) floating point number from the BitBuffer and returns it.

### readFloat64

```
BitBuffer.readFloat64() -> number
```
Reads a [double-precision](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) (64-bit) floating point number from the BitBuffer and returns it.

### readString

```
BitBuffer.readString() -> string
```
Reads a length-prefixed string from the BitBuffer and returns it.

### readTerminatedString

```
BitBuffer.readTerminatedString() -> string
```
Reads a null-terminated string from the BitBuffer and returns it.

### readSetLengthString

```
BitBuffer.readSetLengthString(length: integer) -> string
```
Reads a `length` byte string from the BitBuffer and returns it.

### readField

!!! warning "Potential Performance Issue"
    Although this function allows for reading fields that aren't a multiple of 8 bits long, it can cause performance problems for subsequent reads because of the math involved. You should try to keep readField calls to the end of the file or make sure they're multiples of 8.

```
BitBuffer.readField(n: integer) -> Array<boolean>
```
Reads an `n` width bitfield from the BitBuffer and returns an array of bools that represent its bits.
