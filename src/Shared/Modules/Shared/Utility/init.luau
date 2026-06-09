local Module = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Camera = workspace.CurrentCamera
local Random = Random.new()
local FullCircle = 2 * math.pi

local BoatTween = require(script.BoatTween)

export type TweenData = {

	Time: number;
	EasingStyle: string;
	EasingDirection: string;

	Reverses: boolean;
	DelayTime: number;
	RepeatCount: number;

	StepType: string;

	Goal: {}

}

function Module.CreateTween(Object: Instance, TweenData: TweenData)
	local Tween = BoatTween.Create(Object, TweenData)
	return Tween
end

--// MODULE FUNCTIONS
function Module.Clone(instance: BasePart | Model, parent: Instance?, position: (Vector3 | CFrame)?)
	instance = instance:Clone()
	
	if typeof(position) == "Vector3" then
		instance.Position = position
	elseif typeof(position) == "CFrame" then
		if instance:IsA("Model") then
			instance:PivotTo(position)
		else
			instance.CFrame = position
		end
	end

	instance.Parent = parent
	return instance
end

function Module.DelayDestruction(delayTime: number, instance: Instance)
	task.delay(delayTime, function()
		instance:Destroy()
	end)
end

function Module.IsTableEmpty(t: {})
	for _, _ in t do
		return false
	end
	return true
end

function Module.DeepCloneTable(t: {})
	local result = {}
	for key, value in t do
		if type(value) == "table" then
			result[key] = Module.DeepCloneTable(value)
		else
			result[key] = value
		end
	end
	return result
end

function Module.Weld(a,b)
	local Constraint = Instance.new('WeldConstraint')
	Constraint.Part0 = a
	Constraint.Part1 = b 
	Constraint.Parent = a
	return Constraint
end

function Module:SetVelocity(Character, Velocity, Time)
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then
		warn("Character or HumanoidRootPart not found")
		return
	end

	local HumanoidRootPart = Character.HumanoidRootPart

	local Attachment = Instance.new("Attachment")
	Attachment.Name = "VelocityAttachment"
	Attachment.Parent = HumanoidRootPart

	local LinearVelocity = Instance.new("LinearVelocity")
	LinearVelocity.Name = "CharacterVelocity"
	LinearVelocity.MaxForce = math.huge
	LinearVelocity.VectorVelocity = Velocity 
	LinearVelocity.Attachment0 = Attachment
	LinearVelocity.Parent = HumanoidRootPart
	
	Debris:AddItem(LinearVelocity, Time)
end

for _, module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		module = require(module)
		for name, func in pairs(module) do
			Module[name] = func
		end
	end
end

return Module
