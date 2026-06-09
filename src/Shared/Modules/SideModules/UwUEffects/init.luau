local EffectController = {}
local RunService = game:GetService("RunService")

local function CloneAndAttachParts(targetModel, sourceModel, cleanupList)
	local clonedModel = sourceModel:Clone()
	for _, sourcePart in clonedModel:GetChildren() do
		local targetPart = targetModel:FindFirstChild(sourcePart.Name)
		if targetPart then
			for _, child in sourcePart:GetChildren() do
				if child:IsA("Motor6D") or child:IsA("Weld") then
					child.Part0 = targetPart
					child.Part1 = clonedModel:FindFirstChild(child.Part1.Name) or targetModel:FindFirstChild(child.Part1.Name)
					child.Parent = targetPart
					table.insert(cleanupList, child)
				else
					child.Parent = targetPart
					table.insert(cleanupList, child)
				end
			end
		else
			sourcePart.Parent = targetModel
			table.insert(cleanupList, sourcePart)
		end
	end
	clonedModel:Destroy()
end

local function CleanupEffect(connection, partsToCleanup)
	connection:Disconnect()
	for _, instance in partsToCleanup do
		instance:Destroy()
	end
end

function EffectController.createEffect(attackerModel, victimModel, effectName)
	local attackerRoot = attackerModel.PrimaryPart
	local effectTemplate = script[effectName]
	local attackerParts = effectTemplate:FindFirstChild("Player")
	local victimParts = effectTemplate:FindFirstChild("Victim")
	local meshEffect = effectTemplate:FindFirstChild("Meshes")

	local clonedMesh = nil
	local cleanupItems = {}

	if attackerParts then
		CloneAndAttachParts(attackerModel, attackerParts, cleanupItems)
	end

	if victimParts then
		CloneAndAttachParts(victimModel, victimParts, cleanupItems)
	end

	if meshEffect then
		local root = attackerModel.PrimaryPart
		clonedMesh = meshEffect:Clone()
		clonedMesh:PivotTo(root.CFrame)
		clonedMesh.Parent = workspace.Thrown
		table.insert(cleanupItems, clonedMesh)
	end

	local effectScript = require(effectTemplate)
	local startTime = os.clock()
	local maxTime = 0
	local executedTimings = {}

	for timestamp, _ in effectScript do
		if maxTime < timestamp then
			maxTime = timestamp
		end
	end

	local updateConnection = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if clonedMesh then
			clonedMesh:PivotTo(attackerRoot.CFrame)
		end
		for timeKey, func in effectScript do
			if timeKey <= elapsed and not executedTimings[timeKey] then
				executedTimings[timeKey] = true
				pcall(func, attackerModel, victimModel, clonedMesh)
			end
		end
	end)

	task.delay(maxTime + 1, CleanupEffect, updateConnection, cleanupItems)
end

return EffectController