This page covers all of the abstract functions of the BitBuffer. These functions allow for writing arbitrarily sized numbers and bits, and shouldn't be used for most projects.

For the main functions, including the constructor and export functions, see [*Main Functions*](api-main.md). Functions that are specific to the Roblox version of the BitBuffer are documented in [*Roblox Functions*](api-roblox.md).

!!! warning "Potential Performance Issue"
    Although these functions allow for reading and writing arbitrarily sized numbers, it can cause performance problems for subsequent function calls because of the math involved unless the bits involved are clean multiples of 8.

    As an example, if `writeUnsigned(12, 0)` was called, every subsequent write function call will be slower until the total length of the BitBuffer is a multiple of 8. The same is true of read functions -- `readUnsigned(12)` causes performance issues for read functions until the total bits read are a multiple of 8.

## Write functions

### writeBits

```
BitBuffer.writeBits(...: integer) -> nil
```
Writes an arbitrary number of bits to the BitBuffer. The arguments **MUST** all be 0 or 1.

### writeByte

```
BitBuffer.writeByte(n: integer) -> nil
```
Writes a byte to the BitBuffer.

### writeUnsigned

```
BitBuffer.writeUnsigned(width: integer, n: integer) -> nil
```
Writes an arbitrary width unsigned integer to the BitBuffer.The width **MUST** be in the range [1, 64]

### writeSigned

```
BitBuffer.writeSigned(width: integer, n: integer) -> nil
```
Writes an arbitrary width signed integer to the BitBuffer. The width **MUST** be in the range [2, 63]

### writeFloat

!!! info "Floating point numbers are complicated! Try reading the source to learn more about this function."

```
BitBuffer.writeFloat(expWidth: integer, mantWidth: integer, n: number) -> nil
```
Writes a floating point number with an arbitrarily long exponent and an arbitrarily long mantissa to the BitBuffer. `expWidth` is the length of the exponent and `mantWidth` is the length of the mantissa. Both `expWidth` and `mantWidth` **MUST** be in the range [1, 64].

## Read functions

### readBits

```
BitBuffer.readBits(n: integer) -> Array<integer>
```
Reads `n` bits from the BitBuffer and returns them in an array of 1s and 0s.

### readByte

```
BitBuffer.readByte() -> integer
```
Reads a byte from the BitBuffer and returns it.

### readUnsigned

```
BitBuffer.readUnsigned(width: integer) -> integer
```
Reads an arbitrary width unsigned integer from the BitBuffer and returns it. The width **MUST** be in the range [1, 64]

### readSigned

```
BitBuffer.readSigned(width: integer) -> integer
```
Reads an arbitrary width signed integer from the BitBuffer and returns it. The width **MUST** be in the range [2, 63]

### readFloat

```
BitBuffer.readFloat(expWidth: integer, mantWidth: integer) -> number
```
Reads a floating point number with an arbitrarily long exponent and an arbitrarily long mantissa from the BitBuffer and returns it. `expWidth` is the length of the exponent and `mantWidth` is the length of the mantissa. Both `expWidth` and `mantWidth` **MUST** be in the range [1, 64].