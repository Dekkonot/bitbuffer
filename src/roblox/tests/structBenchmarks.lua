local BitBuffer = require(script.Parent)
local Buffer = BitBuffer()

local rng = Random.new()

return {
	ParameterGenerator = function()
		local i1, i2, i3 = rng:NextInteger(0, 127), rng:NextInteger(-10, 10), rng:NextInteger(-1337, 1337)
		local f1, f2, f3 = rng:NextNumber(), rng:NextNumber(), rng:NextNumber()
		local m1, m2, m3 = i1 * f1, i2 * f2, i3 * f3
		return BrickColor.palette(rng:NextInteger(0, 127)), Color3.new(f1, f2, f3), CFrame.new(m1, m2, m3),
		Vector3.new(m1, m2, m3), Vector2.new(m1, m2), UDim2.new(f1, i1, f2, i2), UDim.new(f3, i3), Ray.new(Vector3.new(i1, i2, i3), Vector3.new(m1, m2, m3)),
		Rect.new(i1, m1, i2, m2), Region3.new(Vector3.new(i1, i2, i3), Vector3.new(m1, m2, m3)), Enum.KeyCode:GetEnumItems()[i1 + 1],
		NumberRange.new(-i1, i1), NumberSequence.new(m1, m2), ColorSequence.new(Color3.new(f1, f2, f3), Color3.new(1 - f1, 1 - f2, 1 - f3))
	end;

	Functions = {
		["writeBrickColor"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeBrickColor(brickcolor)
		end;
		["writeColor3"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeColor3(color3)
		end;
		["writeCFrame"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeCFrame(cframe)
		end;
		["writeVector3"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeVector3(vector3)
		end;
		["writeVector2"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeVector2(vector2)
		end;
		["writeUDim2"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeUDim2(udim2)
		end;
		["writeUDim"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeUDim(udim)
		end;
		["writeRay"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeRay(ray)
		end;
		["writeRect"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeRect(rect)
		end;
		["writeRegion3"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeRegion3(region3)
		end;
		["writeEnum"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeEnum(enum)
		end;
		["writeNumberRange"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeNumberRange(numberrange)
		end;
		["writeNumberSequence"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeNumberSequence(numbersequence)
		end;
		["writeColorSequence"] = function(Profiler, brickcolor, color3, cframe, vector3, vector2, udim2, udim, ray, rect, region3, enum, numberrange, numbersequence, colorsequence)
			Buffer.writeColorSequence(colorsequence)
		end;
	};

}