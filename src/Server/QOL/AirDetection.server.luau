--Services
local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

--Comunication
local Remotes = RS.Remotes

local Comunicator = Remotes.Comunicator.Set

local Bindables = SvSt.Bindables

local AD_Bindable = Bindables.AirDetector

--Params
local MapOVParams = OverlapParams.new()
MapOVParams.FilterType = Enum.RaycastFilterType.Include
MapOVParams.FilterDescendantsInstances = { workspace.Map }

--Functions
local function endAir(Character: Model)
	if not Character or not Character.Parent then
		return
	end

	Character:SetAttribute("TouchedGround", tick())

	for _, v in Character:GetChildren() do
		if v.Name == "inAir" then
			v:Destroy()
		end
	end
end

local function StartAirDetection(Character, _, isRagdoll, justDown, customClampDivider, customParams)
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP or HumRP.Anchored == true then
		return
	end

	local Player
	pcall(function()
		Player = HumRP:GetNetworkOwner()
	end)

	local inAir = Character:FindFirstChild("inAir")
	if not inAir then
		Character:SetAttribute("lastAir", tick())

		inAir = Instance.new("BoolValue")
		inAir.Name = "inAir"
		inAir.Parent = Character
	end

	task.spawn(function()
		if not Player then
			local ClosestPlayer = { Player = nil, Distance = nil }
			for _, Player2 in Players:GetPlayers() do
				local HumRP2: BasePart = Player2.Character:FindFirstChild("HumanoidRootPart")

				if HumRP2 then
					local Distance = (HumRP2.Position - HumRP.Position).Magnitude

					if ClosestPlayer.Player then
						if Distance < ClosestPlayer.Distance then
							ClosestPlayer.Player = Player2
							ClosestPlayer.Distance = Distance
						end
					else
						ClosestPlayer.Player = Player2
						ClosestPlayer.Distance = Distance
					end
				end
			end

			Player = ClosestPlayer.Player
		end

		if Player and HumRP.Anchored == false then
			pcall(function()
				HumRP:SetNetworkOwner(Player)
			end)

			local Bridge = Instance.new("RemoteEvent")
			Bridge.Name = Player.UserId .. " | " .. os.clock()
			Bridge.Parent = Player
			Debris:AddItem(Bridge, 30 + Player:GetNetworkPing())

			local Receive: RBXScriptConnection
			Receive = Bridge.OnServerEvent:Connect(function(Sender)
				if Sender ~= Player then
					return
				end

				endAir(Character)

				pcall(function()
					Receive:Disconnect()
				end)
				pcall(function()
					Bridge:Destroy()
				end)
			end)

			Comunicator:FireClient(Player, "DetectAir", {
				Bridge = Bridge.Name,
				Char = Character,
				ragdoll = isRagdoll,
				justdown = justDown and -math.abs(justDown),
				customClamp = customClampDivider,
				customParams = customParams,
			})
		else
			endAir(Character)
		end
	end)
end

AD_Bindable.Event:Connect(StartAirDetection)
shared.StartAirDetection = StartAirDetection
