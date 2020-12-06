local BitBuffer = require(script.Parent)
local Buffer = BitBuffer()

local rng = Random.new()

return {
	
	ParameterGenerator = function()
		return rng:NextNumber(-10, 10),
		rng:NextInteger(0, 0xff), rng:NextInteger(0, 0xffff), rng:NextInteger(0, 0xffffffff),
		rng:NextInteger(-0x80, 0x7f), rng:NextInteger(-0x8000, 0x7fff), rng:NextInteger(-0x80000000, 0x7fffffff)
	end;
	
	Functions = {
		["writeFloat32"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeFloat32(float)
		end;
		["writeFloat64"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeFloat64(float)
		end;
		["writeUInt8"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeUInt8(u8)
		end;
		["writeUInt16"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeUInt16(u16)
		end;
		["writeUInt32"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeUInt32(u32)
		end;
		["writeInt8"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeInt8(i8)
		end;
		["writeInt16"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeInt16(i16)
		end;
		["writeInt32"] = function(Profiler, float, u8, u16, u32, i8, i16, i32)
			Buffer.writeInt32(i32)
		end;
	};
	
}