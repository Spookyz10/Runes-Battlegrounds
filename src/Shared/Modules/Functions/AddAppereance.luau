local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Function = {}

function Function.Add(Player, Character, HumanoidDescription)
	if not Player or not Character or not Character.Parent then
		return
	end

	local userId = Player.UserId
	local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 5)
	if not Humanoid then
		return
	end

	HumanoidDescription = HumanoidDescription or Players:GetHumanoidDescriptionFromUserIdAsync(userId)

	if HumanoidDescription then
		Humanoid:ApplyDescription(HumanoidDescription)
	end

	for _, Accessory in Character:GetChildren() do
		if Accessory:IsA("Accessory") then
			local Handle = Accessory:FindFirstChild("Handle")
			if Handle and Handle:FindFirstChildOfClass("Weld") then
				local AccessoryWeld = Handle:FindFirstChildOfClass("Weld")

				local Weld = Instance.new("Weld")
				Weld.Name = "WeldConstraint"
				Weld.Part1 = AccessoryWeld.Part1
				Weld.Part0 = Handle
				Weld.C0 = Handle.CFrame:ToObjectSpace(AccessoryWeld.Part1.CFrame)
				Weld.Parent = Accessory

				AccessoryWeld:Destroy()

				Handle.CanCollide = false
				Handle.CanQuery = false
				Handle.CanTouch = false
				Handle.Massless = true
				Handle.CollisionGroup = "Players"

				Accessory.Name = "#ACCESSORY_" .. Accessory.Name
				Accessory.Parent = Character.FakeHead
			end
		end
	end

	local NewOutfitApplied = Instance.new("Configuration")
	NewOutfitApplied.Name = "NewHumanoidDescriptionApplied"
	NewOutfitApplied.Parent = Character
	Debris:AddItem(NewOutfitApplied, 5)

	if ReplicatedStorage.Clones:FindFirstChild(Character.Name) then
		ReplicatedStorage.Clones[Character.Name]:Destroy()
	end

	Character.Archivable = true
	local CharacterClone = Character:Clone()
	Character.Archivable = false

	CharacterClone.Parent = ReplicatedStorage.Clones
	for _, scriptInChar in CharacterClone:GetDescendants() do
		if scriptInChar:IsA("LocalScript") or scriptInChar:IsA("Script") then
			scriptInChar:Destroy()
		end
	end
end

return Function
