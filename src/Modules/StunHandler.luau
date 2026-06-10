local module = {}
module.Cache = {}

local StunsTags = {
	"CantPunch",
	"CantDash",
	"CantSideDash",
	"CantBlock",
	"CantThrowable",
}

local function TriggerTags(Character, State)
	if not Character then
		return
	end

	for _, Tag in ipairs(StunsTags) do
		if State then
			Character:AddTag(Tag)
		else
			Character:RemoveTag(Tag)
		end
	end
end

local function Unstun(Character)
	if
		not Character
		or not Character:FindFirstChild("Humanoid")
		or Character.Humanoid.Health <= 0
		or Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead
	then
		return
	end

	Character:RemoveTag("Stunned")
	Character:SetAttribute("Stunned", false)
	Character:SetAttribute("Stunned", nil)

	task.spawn(function()
		for _, Stunned in Character:GetChildren() do
			if Stunned:IsA("Folder") and Stunned.Name == "Stunned" then
				Stunned:Destroy()
			end
		end
	end)

	TriggerTags(Character, false)
	module.Cache[Character] = nil
end

function module:Stun(Character, Duration, IgnoreImmunity, WalkSpeed, JumpPower, DestroyImmunity, IgnoreThrowable)
	Duration = Duration or -1
	WalkSpeed = WalkSpeed or 0
	JumpPower = JumpPower or 0

	if not Character or not Character.Parent then
		return
	end

	if module.Cache[Character] then
		pcall(function()
			task.cancel(module.Cache[Character])
		end)
		module.Cache[Character] = nil
	end

	task.spawn(function()
		for _, Stunned in Character:GetChildren() do
			if Stunned:IsA("Folder") and Stunned.Name == "Stunned" then
				Stunned:Destroy()
			end
		end
	end)

	Character:AddTag("Stunned")
	Character:SetAttribute("Stunned", true)

	local Stunned = Instance.new("Folder")
	Stunned.Name = "Stunned"
	Stunned.Parent = Character
	Stunned:SetAttribute("WalkSpeed", WalkSpeed)
	Stunned:SetAttribute("JumpPower", JumpPower)

	Stunned.Destroying:Once(function()
		Character:SetAttribute("Stunned", false)
		Character:SetAttribute("Stunned", nil)
		Character:RemoveTag("Stunned")
		TriggerTags(Character, false)
	end)

	if DestroyImmunity then
		Stunned:AddTag("DestroyImmunity")
	end

	TriggerTags(Character, true)

	if Duration > 0 then
		local Handle = task.delay(Duration, function()
			Unstun(Character)
		end)
		module.Cache[Character] = Handle
	else
		local Thread = coroutine.create(function()
			Unstun(Character)
		end)
		module.Cache[Character] = Thread
	end

	return Stunned
end

function module:RemoveAllStuns(Character, IgnoreImmunity)
	for _, Stunned in Character:GetChildren() do
		if Stunned.Name == "Stunned" and (IgnoreImmunity == true or not Stunned:HasTag("DestroyImmunity")) then
			Stunned:Destroy()
			Unstun(Character)
		end
	end
end

function module:Unstun(Character, StunObject)
	if
		not Character
		or not Character:FindFirstChild("Humanoid")
		or Character.Humanoid.Health <= 0
		or Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead
	then
		return
	end

	if StunObject then
		StunObject:Destroy()
	else
		Unstun(Character)
	end
end

function module:IsStunned(Character)
	return Character:FindFirstChild("Stunned") or Character:HasTag("Stunned") or Character:GetAttribute("Stunned")
end

return module
