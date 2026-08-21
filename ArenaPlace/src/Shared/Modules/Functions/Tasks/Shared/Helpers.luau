local Constants = require(script.Parent.Constants)

local RandomSeed = Random.new()
local DefaultFilter = Constants.DefaultFilter
local MapRayParams = Constants.MapRayParams

local function calculateCFrameBetweenVectors(vectorA, vectorB, axis)
	local dotProduct = vectorA:Dot(vectorB)
	local crossProduct = vectorA:Cross(vectorB)

	if dotProduct < -0.99999 then
		return CFrame.fromAxisAngle(axis, math.pi)
	else
		return CFrame.new(0, 0, 0, crossProduct.x, crossProduct.y, crossProduct.z, 1 + dotProduct)
	end
end

local function getTouchingPartsExceptIgnored(object)
	if not object then
		return
	elseif object.ClassName == "Model" then
		return
	else
		local touchConnection = object.Touched:Connect(function() end)

		local touchingParts = object:GetTouchingParts()
		touchConnection:Disconnect()

		local validParts = {}
		for _, part in pairs(touchingParts) do
			if part.Name ~= "InvisibleBorder" and part.Name ~= "InfBall" and not part:GetAttribute("NoDebris") then
				table.insert(validParts, part)
			end
		end

		return validParts
	end
end

local function performRaycast(rayData)
	local orig = rayData.orig
	local dir = rayData.dir
	local raycastParams = RaycastParams.new()

	local baseFilter = rayData.Whitelist or rayData.Ignore or DefaultFilter
	local filter = table.clone(baseFilter)

	raycastParams.FilterDescendantsInstances = filter
	if rayData.Whitelist then
		raycastParams.FilterType = Enum.RaycastFilterType.Include
	else
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end
	raycastParams.IgnoreWater = rayData.IgnoreWater or false

	local skipNoDebris = rayData.SkipNoDebris ~= false and not rayData.Whitelist

	for _ = 1, 8 do
		local result
		if rayData.Blockcast then
			result = workspace:Blockcast(orig, rayData.Blockcast, dir, raycastParams)
		else
			result = workspace:Raycast(orig, dir, raycastParams)
		end

		if not result then
			return
		end

		if skipNoDebris and result.Instance:GetAttribute("NoDebris") then
			table.insert(filter, result.Instance)
			raycastParams.FilterDescendantsInstances = filter
			continue
		end

		return result.Instance, result.Position, result.Material, result.Normal
	end
end

local function getRandomValue(min, max, isInteger, randomGenerator)
	local generator = randomGenerator or RandomSeed

	if not max and min then
		max = min
		min = 1
	end

	if not max and not min then
		min = 0
		max = 1
	end

	if not isInteger then
		return generator:NextNumber(min, max)
	else
		return generator:NextInteger(min, max)
	end
end

local function raycast(Origin, Direction, rayParams, isWhitelist, returnIsolated)
	local localRayParams
	if typeof(rayParams) == "table" then
		localRayParams = RaycastParams.new()
		localRayParams.FilterDescendantsInstances = rayParams
		if isWhitelist then
			localRayParams.FilterType = Enum.RaycastFilterType.Include
		else
			localRayParams.FilterType = Enum.RaycastFilterType.Exclude
		end
	else
		localRayParams = MapRayParams
	end

	local ray = workspace:Raycast(Origin, Direction, localRayParams)
	if not returnIsolated then
		return ray
	else
		return ray.Instance, ray.Position, ray.Material, ray.Normal
	end
end

return {
	RandomSeed = RandomSeed,
	calculateCFrameBetweenVectors = calculateCFrameBetweenVectors,
	getTouchingPartsExceptIgnored = getTouchingPartsExceptIgnored,
	performRaycast = performRaycast,
	getRandomValue = getRandomValue,
	raycast = raycast,
}
