--// VARIABLES
local random = Random.new(tick())

local Module = {}

--// MODULE FUNCTIONS
function Module.GetRandomVector(min: { number }, max: { number }, decimals: boolean?)
	if decimals then
		return Vector3.new(
			random:NextNumber(min[1], max[1]),
			random:NextNumber(min[2], max[2]),
			random:NextNumber(min[3], max[3])
		)
	else
		return Vector3.new(
			random:NextInteger(min[1], max[1]),
			random:NextInteger(min[2], max[2]),
			random:NextInteger(min[3], max[3])
		)
	end
end

function Module.GetRandomCFrame(min: { number }, max: { number }, decimals: boolean?)
	if decimals then
		return CFrame.new(
			random:NextNumber(min[1], max[1]),
			random:NextNumber(min[2], max[2]),
			random:NextNumber(min[3], max[3])
		)
	else
		return CFrame.new(
			random:NextInteger(min[1], max[1]),
			random:NextInteger(min[2], max[2]),
			random:NextInteger(min[3], max[3])
		)
	end
end

function Module.GetRandomAngles(min: { number }, max: { number }, decimals: boolean?)
	if decimals then
		return CFrame.Angles(
			random:NextNumber(min[1], max[1]),
			random:NextNumber(min[2], max[2]),
			random:NextNumber(min[3], max[3])
		)
	else
		return CFrame.Angles(
			random:NextInteger(min[1], max[1]),
			random:NextInteger(min[2], max[2]),
			random:NextInteger(min[3], max[3])
		)
	end
end

function Module.GetRandomNumber(min: number, max: number, decimals: boolean)
	if decimals then
		return random:NextNumber(min, max)
	else
		return random:NextInteger(min, max)
	end
end

function Module.GetRandomSign()
	local sign = Module.GetRandomNumber(-1, 1)
	if sign == 0 then
		sign = 1
	end
	return sign
end

return Module