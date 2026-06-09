--// VARIABLES
local Module = {}

--// MODULE FUNCTIONS
function Module.GetCircularPosition(center: Vector3, radius: number, angle: number)
	return center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
end

function Module.GetCircularCFrame(center: Vector3, normal: Vector3, radius: number, angle: number)
	local position = Module.GetCircularPosition(center, radius, angle)
	return CFrame.lookAt(center, center + normal) * CFrame.new(position)
end

function Module.GetAngleBetweenVectors(vectorA: Vector3, vectorB: Vector3, withDirection: boolean?)
	vectorA, vectorB = vectorA.Unit, vectorB.Unit
	if withDirection then
		local dot = vectorA:Dot(vectorB)
		local det = vectorA.X * vectorB.Z - vectorA.Z * vectorB.X
		return math.atan2(det, dot)
	else
		return math.acos(vectorA:Dot(vectorB))
	end
end

return Module