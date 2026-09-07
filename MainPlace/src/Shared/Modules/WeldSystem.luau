local Debris = game:GetService("Debris")

local RunService = game:GetService("RunService")

local RemoteManager = require(script.Parent.RemoteManager)

local WSys = {}
WSys.__index = WSys

function WSys.new(Part0, Part1, Offset, LifeTime)
	return setmetatable({
		Part0 = Part0,
		Part1 = Part1,
		Offset = Offset,
		LifeTime = LifeTime,
	}, WSys)
end

local function ClearVelocities(Part: Part, Ignore: BodyVelocity?)
	for _, Velocity in Part:GetDescendants() do
		if
			Velocity ~= Ignore
			and (
				Velocity:IsA("BodyVelocity")
				or Velocity:IsA("LinearVelocity")
				or Velocity:IsA("BodyPosition")
				or Velocity:IsA("BodyGyro")
				or Velocity:IsA("BodyAngularVelocity")
				or Velocity:IsA("BodyMover")
				or Velocity:IsA("BodyForce")
				or Velocity:IsA("BodyThrust")
				or Velocity:IsA("AngularVelocity")
				or Velocity:IsA("VelocityMotor")
			)
		then
			Velocity:Destroy()
		end
	end
end

function WSys:Start(TweenTime, Player)
	local Part0, Part1 = self.Part0, self.Part1
	if not Part0 or not Part0.Parent or not Part1 or not Part1.Parent then
		return
	end
	self:Stop()
	self.Stopped = false
	self.Connections = {}
	self.PartStates = {}
	local Character = Part1.Parent
	self.Character = Character
	TweenTime = TweenTime or 0.25

	local Bind = Instance.new("Folder")
	Bind.Name = "#WeldBind_" .. Part0.Parent.Name .. "_" .. Character.Name .. "_" .. tostring(os.clock())
	Bind.Parent = Part1
	self.Bind = Bind

	self.PartStates[Part1] = Part1.Massless
	Part1.Massless = true
	if Character:FindFirstChild("Humanoid") then
		for _, part in Character:GetChildren() do
			if part:IsA("BasePart") then
				if self.PartStates[part] == nil then
					self.PartStates[part] = part.Massless
				end
				part.Massless = true
			end
		end
		table.insert(self.Connections, game:GetService("CollectionService"):GetInstanceRemovedSignal("CantRotate"):Connect(function(character)
			if character == Character and not self.Stopped then
				Character:AddTag("CantRotate")
			end
		end))
	end
	Character:AddTag("WeldedToReplicated")

	local Weld = Instance.new("WeldConstraint")
	Weld.Name = "GrabWeld"
	Weld.Part0 = Part0
	Weld.Part1 = Part1
	self.Weld = Weld
	table.insert(self.Connections, Weld.Destroying:Connect(function()
		self:Stop()
	end))
	for _, part in { Part0, Part1 } do
		table.insert(self.Connections, part.Destroying:Connect(function()
			self:Stop()
		end))
		table.insert(self.Connections, part.AncestryChanged:Connect(function()
			if not part:IsDescendantOf(workspace) then
				self:Stop()
			end
		end))
	end
	if self.LifeTime and self.LifeTime > 0 then
		Debris:AddItem(Weld, self.LifeTime)
	end

	task.spawn(function()
		if self.Stopped or self.Weld ~= Weld then
			return
		end
		if RunService:IsServer() and Player and Player.Parent then
			pcall(function()
				Part1:SetNetworkOwner(Player)
			end)
			ClearVelocities(Part1)
			RemoteManager.FireClient(Player, "ReplicateTask", "smoothweld", {
				Character = Part0.Parent,
				EnemyCharacter = Character,
				TweenTime = TweenTime,
				Offset = self.Offset,
				Bind = Bind,
			})
			task.wait(TweenTime)
		end
		if self.Stopped or self.Weld ~= Weld or not Part0.Parent or not Part1.Parent then
			return
		end
		Part1.CFrame = Part0.CFrame * self.Offset
		Weld.Parent = Part1
	end)
	return Weld
end

function WSys:Stop(_dontDelete)
	if self.Stopped then
		return
	end
	self.Stopped = true
	for _, connection in self.Connections or {} do
		connection:Disconnect()
	end
	self.Connections = nil
	local Weld = self.Weld
	self.Weld = nil
	if Weld then
		Weld:Destroy()
	end
	if self.Bind then
		self.Bind:Destroy()
		self.Bind = nil
	end
	if self.TweenConnection then
		self.TweenConnection:Disconnect()
		self.TweenConnection = nil
	end
	if self.Character then
		self.Character:RemoveTag("WeldedToReplicated")
	end
	for part, massless in self.PartStates or {} do
		if part.Parent then
			part.Massless = massless
		end
	end
	self.PartStates = nil
end

return WSys
