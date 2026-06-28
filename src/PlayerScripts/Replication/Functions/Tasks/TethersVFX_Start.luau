local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TethersAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Solar.Tethers
local TethersVFXState = require(script.Parent.Shared.TethersVFXState)

local activeVFX = TethersVFXState.activeVFX

local function getKey(casterChar)
	return tostring(casterChar)
end

local function spawnFlareArms(casterChar)
	local template = TethersAssets:FindFirstChild("FlareArm")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local arm = casterChar:FindFirstChild(armName)
		if arm then
			for _, child in template:GetChildren() do
				local clone = child:Clone()
				clone.Parent = arm
				table.insert(spawned, clone)
			end
		end
	end

	return spawned
end

local function spawnFlareChains(casterChar, victimChar)
	local template = TethersAssets:FindFirstChild("FlareChains")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local casterArm = casterChar:FindFirstChild(armName)
		local victimArm = victimChar:FindFirstChild(armName)

		if casterArm and victimArm then
			local chain = template:Clone()
			chain.Parent = casterArm

			local victimPart = chain:FindFirstChild("Victim")
			if victimPart then
				victimPart.Parent = victimArm
			end

			table.insert(spawned, { chain = chain, victimPart = victimPart })
		end
	end

	return spawned
end

return function(params)
	local casterChar = params.casterChar
	local victimChar = params.victimChar
	if not casterChar or not victimChar then
		return
	end

	local key = getKey(casterChar)

	local existing = activeVFX[key]
	if existing then
		for _, c in existing.chains or {} do
			if c.chain and c.chain.Parent then
				c.chain:Destroy()
			end
			if c.victimPart and c.victimPart.Parent then
				c.victimPart:Destroy()
			end
		end
		for _, part in existing.armParts or {} do
			if part and part.Parent then
				part:Destroy()
			end
		end
		activeVFX[key] = nil
	end

	activeVFX[key] = {
		armParts = spawnFlareArms(casterChar),
		chains = spawnFlareChains(casterChar, victimChar),
	}
end
