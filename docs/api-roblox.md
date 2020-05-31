This page covers all of the functions specific to the Roblox version of the BitBuffer. These functions allow for reading and writing Roblox specific datatypes to and from the BitBuffer.

For the main functions, including the constructor and export functions, see [*Main Functions*](api-main.md). The abstract BitBuffer functions are documented in [*Abstract Functions*](api-base.md).

## Write functions

### writeBrickColor
```
BitBuffer.writeBrickColor(n: BrickColor) -> nil
```
Writes a BrickColor to the BitBuffer as a 16-bit unsigned integer.

### writeColor3
```
BitBuffer.writeColor3(n: Color3) -> nil
```
Writes a Color3 to the BitBuffer as a 24-bit integer. Colors with RGB components outside of `[0, 255]` are not saved properly and may throw.

### writeCFrame
```
BitBuffer.writeCFrame(n: CFrame) -> nil
```
Writes a CFrame to the BitBuffer. If the CFrame is axis aligned (all of its faces are aligned with an axis), it takes up 13 bytes. Otherwise, it takes up 49.

### writeVector3
```
BitBuffer.writeVector3(n: Vector3) -> nil
```
Writes a Vector3 to the BitBuffer as three 32-bit floats. The written size is 12 bytes.

### writeVector2
```
BitBuffer.writeVector2(n: Vector2) -> nil
```
Writes a Vector2 to the BitBuffer as two 32-bit floats. The written size is 8 bytes.

### writeUDim2
```
BitBuffer.writeUDim2(u2: UDim2) -> nil
```
Writes a UDim2 to the BitBuffer as two 32-bit floats and two signed 32-bit integers. The written size is 16 bytes.

### writeUDim
```
BitBuffer.writeUDim(u: UDim) -> nil
```
Writes a UDim to the BitBuffer as a 32-bit float and a 32-bit signed integer. The written size is 8 bytes.

### writeRay
```
BitBuffer.writeRay(ray: Ray) -> nil
```
Writes a Ray to the BitBuffer as two Vector3s representing the `Origin` and `Direction`. The written size is 24 bytes.

### writeRect
```
BitBuffer.writeRay(rect: Rect) -> nil
```
Writes a Rect to the BitBuffer as two Vector2s representing the `Min` and `Max`. The written size is 16 bytes.

### writeRegion3
```
BitBuffer.writeRegion3(region: Region3) -> nil
```
Writes a Region3 to the BitBuffer as two Vector3s representing the `Min` and `Max`. The written size is 24 bytes.

Region3s do not have properties indicating their minimums and maximums, so they are determined using arithmetic. As a result, the value stores is subject to floating point errors.

### writeEnum
```
BitBuffer.writeEnum(enum: EnumItem) -> nil
```
Writes any EnumItem to the BitBuffer as a null-terminated string and a 16-bit unsigned integer. Due to the nature of this datatype, the written size varies. The size in bytes can be determined with `#tostring(enum.EnumType) + 3`.

### writeNumberRange
```
BitBuffer.writeNumberRange(range: NumberRange) -> nil
```
Writes a NumberRange to the BitBuffer as two 32-bit floats. The written size is 8 bytes.

### writeNumberSequence
```
BitBuffer.writeNumberSequence(sequence: NumberSequence) -> nil
```
Writes a NumberSequence to the BitBuffer as an array of NumberSequenceKeypoints. Due to the nature of the datatype, the written size varies. The size in bytes can be determined with `(#sequence.Keypoints*12)+4`.

### writeColorSequence
```
BitBuffer.writeColorSequence(sequence: ColorSequence) -> nil
```
Writes a ColorSequence to the BitBuffer as an array of ColorSequenceKeypoints. Due to the nature of the datatype, the written size varies. The size in bytes can be determined with `(#sequence.Keypoints*7)+4`.

## Read functions

### readBrickColor
```
BitBuffer.readBrickColor() -> BrickColor
```
Reads a BrickColor from the BitBuffer and returns it.

### readColor3
```
BitBuffer.readColor3() -> Color3
```
Reads a Color3 from the BitBuffer and returns it.

### readCFrame
```
BitBuffer.readCFrame() -> CFrame
```
Reads a CFrame from the BitBuffer and returns it.

### readVector3
```
BitBuffer.readVector3() -> Vector3
```
Reads a Vector3 from the BitBuffer and returns it.

### readVector2
```
BitBuffer.readVector2() -> Vector2
```
Reads a Vector2 from the BitBuffer and returns it.

### readUDim2
```
BitBuffer.readUDim2() -> UDim2
```
Reads a UDim2 from the BitBuffer and returns it.

### readUDim
```
BitBuffer.readUDim() -> UDim
```
Reads a UDim from the BitBuffer and returns it

### readRay
```
BitBuffer.readRay() -> Ray
```
Reads a Ray from the BitBuffer and returns it.

### readRect
```
BitBuffer.readRect() -> Rect
```
Reads a Rect from the BitBuffer and returns it.

### readRegion3
```
BitBuffer.readRegion3() -> Region3
```
Reads a Region3 from the BitBuffer and returns it. Note that because of limitations with the Roblox API, the Region3 will have lost precision over what was originally written.

### readEnum
```
BitBuffer.readEnum() -> EnumItem
```
Reads an EnumItem from the BitBuffer and returns it.

### readNumberRange
```
BitBuffer.readNumberRange() -> NumberRange
```
Reads a NumberRange from the BitBuffer and returns it.

### readNumberSequence
```
BitBuffer.readNumberSequence() -> NumberSequence
```
Reads a NumberSequence from the BitBuffer and returns it.

### readColorSequence
```
BitBuffer.readColorSequence() -> ColorSequence
```
Reads a ColorSequence from the BitBuffer and returns it.