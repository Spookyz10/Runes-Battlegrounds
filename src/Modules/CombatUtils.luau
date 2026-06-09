local combatUtils = {}
combatUtils.__index = combatUtils

function combatUtils:AddValue(Player : Player, Class_Name : string, Value, value_name : string)
	if Player then
		local newvalue : PVInstance
		newvalue = Instance.new(Class_Name)
		newvalue.Name = value_name
		newvalue.Value = Value
		newvalue.Parent = Player

		return newvalue
	end
end

function combatUtils.createAngularVelocity(basePart : BasePart, velocitySettings : any, lifeTime : number)
	local newAngularVelocity = Instance.new("BodyAngularVelocity")

	for i, v in velocitySettings do
		newAngularVelocity[i] = v
	end

	if basePart then
		newAngularVelocity.Parent = basePart
	end

	if lifeTime then
		task.delay(lifeTime, function()
			shared.safeDestroy(newAngularVelocity)
		end)
	end

	return newAngularVelocity
end

function combatUtils.createBodyVelocity(basePart : BasePart, bodyVelocitySettings : any, lifeTime : number)
	local bodyVelocity = Instance.new("BodyVelocity")

	for i, v in bodyVelocitySettings do
		bodyVelocity[i] = v
	end

	if basePart then
		bodyVelocity.Parent = basePart
	end

	if lifeTime then
		task.delay(lifeTime, function()
			shared.safeDestroy(bodyVelocity)
		end)
	end

	return bodyVelocity
end

function combatUtils.stopVelocities(target : Model)
	if not target or not target:IsA("Model") then
		return
	end

	for i, v in target:GetDescendants() do
		if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
			shared.safeDestroy(v)
		end
	end

	target:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.zero
end

return combatUtils