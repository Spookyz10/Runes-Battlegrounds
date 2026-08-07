local Debris = game:GetService("Debris")

local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local RemoteManager = require(script.Parent.RemoteManager)
local Tasks = require(StarterPlayer.StarterPlayerScripts.Player.Replication.Functions.Tasks)

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

function WSys:Start(TweenTime, Player)
	if not self.Part1 then
		return
	end

	TweenTime = TweenTime or 0.25

	local Part0 = self.Part0
	local Part1 = self.Part1

	local Bind = Instance.new("Folder")
	Bind.Name = "#WeldBind_" .. Part0.Parent.Name .. "_" .. Part1.Parent.Name .. "_" .. tostring(os.clock())
	Bind.Parent = Part1
	self.Bind = Bind

	Part1.Massless = true

	if Part1.Parent:FindFirstChild("Humanoid") then
		for _, v in Part1.Parent:GetChildren() do
			if v:IsA("BasePart") then
				v.Massless = true
			end
		end

		self.AntiRotateConnection = game.CollectionService:GetInstanceRemovedSignal("CantRotate"):Connect(function(c)
			if c == Part1.Parent then
				Part1.Parent:AddTag("CantRotate")
			end
		end)
	end

	Part1.Parent:AddTag("WeldedToReplicated")

	self.Weld = Instance.new("WeldConstraint")
	self.Weld.Name = "GrabWeld"
	if self.Lifetime then
		Debris:AddItem(self.Weld, self.Lifetime)
	end

	self.Weld.Destroying:Once(function()
		if not self then
			return
		end

		if Part1 and Part1.Parent then
			Part1.Parent:RemoveTag("WeldedToReplicated")
			Part1.Massless = false

			if Part1.Parent:FindFirstChild("Humanoid") then
				for _, v in Part1.Parent:GetChildren() do
					if v:IsA("BasePart") then
						v.Massless = false
					end
				end
			end
		end

		if self.Bind then
			self.Bind:Destroy()
			self.Bind = nil
		end

		if self.TweenConnection then
			self.TweenConnection:Disconnect()
			self.TweenConnection = nil
		end

		if self.AntiRotateConnection then
			self.AntiRotateConnection:Disconnect()
		end

		setmetatable(self, nil)
	end)

	self.Weld.Part0 = Part0
	self.Weld.Part1 = Part1

	task.spawn(function()
		if RunService:IsServer() and Player then
			Part1:SetNetworkOwner(Player)

			Tasks["ClearVelocities"](Part1)

			RemoteManager.FireClient(Player, "ReplicateTask", "smoothweld", {
				Character = Part0.Parent,
				EnemyCharacter = Part1.Parent,
				TweenTime = TweenTime,
				Offset = self.Offset,
				Bind = Bind,
			})

			task.wait(TweenTime)
		end

		Part1.CFrame = Part0.CFrame * self.Offset
		self.Weld.Parent = Part1
	end)

	return self.Weld
end

function WSys:Stop(dontDelete)
	if self.Weld then
		if self.Weld.Part1 then
			self.Weld.Part1.Parent:RemoveTag("WeldedToReplicated")

			self.Weld.Part1.Massless = false

			if self.Weld.Part1.Parent:FindFirstChild("Humanoid") then
				for _, v in self.Weld.Part1.Parent:GetChildren() do
					if v:IsA("BasePart") then
						v.Massless = false
					end
				end
			end
		end

		self.Weld:Destroy()
		self.Weld = nil
	end

	if self.Bind then
		self.Bind:Destroy()
		self.Bind = nil
	end

	if self.TweenConnection then
		self.TweenConnection:Disconnect()
		self.TweenConnection = nil
	end

	if self.AntiRotateConnection then
		self.AntiRotateConnection:Disconnect()
	end

	if dontDelete ~= true then
		setmetatable(self, nil)
	end
end

return WSys
