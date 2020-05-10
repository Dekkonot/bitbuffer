The following is a list of all the built-in API for the module.

## Type Information

This API reference provides the argument and return types for the various functions. While most prominent Lua documentation sources use C's style for types and/or Lua's original documentation style, this documentation uses the annotation style that Roblox's typed Lua uses (you may recognize it vaguely from TypeScript or Rust). This is because it is clean and easy to understand.

As a brief overview, a function that has the signature `(x: number, y: string) -> boolean` means that a function accepts two arguments: `x` which is a number, and `y` which is a `string`, and returns a `boolean`. The signature `(x: number, y: string?) -> boolean` means the same thing but that `y` is optional.

Arrays are represented with `Array<T>` where T is a type like `string`. Varargs (`...`) are represented like `...: T` to indicate the type of the vararg entries.

# Main Module

## Constructor

```
BitBuffer(stream: string?) -> BitBuffer
```

Creates a new BitBuffer object and fills it with `stream` if it's provided. Otherwise, returns an empty BitBuffer.

## BitBuffer

```
BitBuffer.getPointer() -> integer
```
Returns where the pointer is in the stream. The pointer is the bit from which the various [Read functions](#read-functions) operate.

---

```
BitBuffer.setPointer(n: integer) -> nil
```
Sets where the pointer is in the stream.

---

```
BitBuffer.crc32() -> integer
```
Calculates the CRC32 checksum of the BitBuffer's contents.

---

```
BitBuffer.adler32() -> integer
```
Calculates the adler32 checksum of the BitBuffer's contents.

### Export functions

The following functions are all intended to get data *out* of the BitBuffer in some way.

---

```
BitBuffer.dumpBinary() -> string
```
Returns a string of binary digits that represent the contents of the BitBuffer. This is primarily intended for debugging or testing purposes.

---

```
BitBuffer.dumpString() -> string
```
Returns the raw binary contents of the BitBuffer. This function is one of the main methods for getting things out of the buffer, and outputs the raw binary data.

---

```
BitBuffer.dumpHex() -> string
```
Returns a string of hex characters that represent the contents of the BitBuffer.

---

```
BitBuffer.dumpBase64() -> string
```
Returns a string of base64 characters that represent the contents of the BitBuffer. This is provided as a courtesy and decoding is not included.

### Write functions

```
BitBuffer.writeBits(...: integer) -> nil
```
Writes an arbitrary number of bits to the BitBuffer. The arguments **MUST** all be 0 or 1.

---

```
BitBuffer.writeByte(n: integer) -> nil
```
Writes a byte to the BitBuffer. The argument `n` **MUST** be in the range [0, 255].

---

```
BitBuffer.writeUnsigned(width: integer, n: integer) -> nil
```
Writes an arbitrary width unsigned integer to the BitBuffer. The `width` **MUST** be in the range [1, 64], and `n` **MUST** fit within `width` bits and be positive.

---

```
BitBuffer.writeSigned(width: integer, n: integer) -> nil
```
Writes an arbitrary width signed integer to the BitBuffer. The `width` **MUST** be in the range [2, 64] and `n` **MUST** fit within `width-1` bits.

---

```
BitBuffer.writeFloat(expWidth: integer, mantWidth: integer, n: number) -> nil
```
Writes a floating point number with an arbitrarily long exponent and an arbitrarily long mantissa to the BitBuffer. `expWidth` is the length of the exponent and `mantWidth` is the length of the mantissa. Both the exponent and the mantissa **MUST** be in the range [1, 64].

Floating point numbers are complicated, so if you don't understand them, it's recommended you use this function with `8` and `23` as the width arguments (if you need less precision) or `11` and `52` (if you need more precision). 

---

```
BitBuffer.writeString(str: string) -> nil
```
Writes a length-prefixed string to the BitBuffer. The length prefix is 24 bits, meaning that the maximum length of the string is 16777215 characters (or around 16.77 megabytes). Because the string is length-prefixed, null characters may be written freely.

---

```
BitBuffer.writeTerminatedString(str: string) -> nil
```
Writes a null-terminated string to the BitBuffer.

---

```
BitBuffer.writeSetLengthString(str: string) -> nil
```
Writes a string to the BitBuffer as a sequence of bytes with not other overhead. Reading the string will require knowing the length of it.

---

```
BitBuffer.writeField(...: any) -> nil
```
Writes a series of bits to the BitBuffer as a bitfield. Truthy arguments get written as `1` and falsey arguments get written as `0`.

### Read functions

```
BitBuffer.readBits(n: integer) -> Array<integer>
```
Reads `n` number of bits from the BitBuffer and returns them in an array. Every value in the array will either be `0` or `1`.

---

```
BitBuffer.readByte() -> integer
```
Reads a byte from the BitBuffer and returns it.

---

```
BitBuffer.readUnsigned(width: integer) -> integer
```
Reads an unsigned integer that's `width` bits long from the BitBuffer and returns it.

---

```
BitBuffer.readSigned(width: integer) -> integer
```
Reads a signed integer that's `width` bits long from the BitBuffer and returns it.

---

```
BitBuffer.readFloat(expWidth: integer, mantWidth: integer) -> integer
```
Reads a floating point number from the BitBuffer with the given exponent and mantissa widths and returns it.

---

```
BitBuffer.readString() -> string
```
Reads a length-prefixed string from the BitBuffer and returns it.

---

```
BitBuffer.readTerminatedString() -> string
```
Reads a null-terminated string from the BitBuffer and returns it

---

```
BitBuffer.readSetLengthString(length: integer) -> string
```
Reads a `length` character string from the BitBuffer and returns it.

---

```
BitBuffer.readField(n: integer) -> Array<boolean>
```
Reads an `n` length bitfield from the BitBuffer and returns its representation in an array. Every value in the array will either be `true` or `false`.