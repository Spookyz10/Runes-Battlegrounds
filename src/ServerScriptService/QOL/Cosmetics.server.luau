--Services
local Players = game:GetService("Players")
local RS = game:GetService('ReplicatedStorage')
local SvSt = game:GetService('ServerStorage')
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")



--Bindables
local Bindables = SvSt.Bindables

local CosmBind = Bindables.Cosmetics



--Remotes
local Remotes = RS.Remotes
local CosmeticsRems = Remotes.Cosmetics
local ComunicatorRems = Remotes.Comunicator

local CosmSet = CosmeticsRems.Set
local CosmGet = CosmeticsRems.Get

local ComSet = ComunicatorRems.Set
local ComGet = ComunicatorRems.Get



--Assets
local Assets = SvSt.Assets
local Models = Assets.Models
local Cosmetics = Models.Cosmetics

local Accessories = Cosmetics.Accessories
local Auras = Cosmetics.Auras



--Functions
local CustomAccessories = {
	["Red Gloves"] = function(Character: Model, Accessory: Model)
		local AccessoryClone = Accessory:Clone()
		AccessoryClone.Parent = Character
		AccessoryClone["Left Arm"].Weld.Part0 = Character["Left Arm"]
		AccessoryClone["Right Arm"].Weld.Part0 = Character["Right Arm"]

		return AccessoryClone
	end,

	["Bandages"] = function(Character: Model, Accessory: Model)
		local AccessoryClone = Accessory:Clone()
		AccessoryClone.Parent = Character
		AccessoryClone["Cube.007"].Weld.Part0 = Character["Right Arm"]
		AccessoryClone["Cube.008"].Weld.Part0 = Character["Left Arm"]
		AccessoryClone["MainWeld"].Part0 = Character["Torso"]

		return AccessoryClone
	end,

	["Bandage Wrap"] = function(Character: Model, Accessory: Model)
		local AccessoryClone = Accessory:Clone()
		AccessoryClone.Parent = Character
		AccessoryClone["Left Arm"].Weld.Part0 = Character["Left Arm"]
		AccessoryClone["Right Arm"].Weld.Part0 = Character["Right Arm"]
		AccessoryClone["Torso"].Weld.Part0 = Character["Torso"]

		return AccessoryClone
	end,
	
	["Spiral Cloth"] = function(Character: Model, Accessory: Model)
		local AccessoryClone = Accessory:Clone()
		AccessoryClone.Parent = Character
		AccessoryClone["Left Arm"].Weld.Part0 = Character["Left Arm"]
		AccessoryClone["Right Arm"].Weld.Part0 = Character["Right Arm"]
		AccessoryClone["Torso"].Weld.Part0 = Character["Torso"]

		return AccessoryClone
	end,

	["Leg Iron"] = function(Character: Model, Accessory: Model)
		local AccessoryClone = Accessory:Clone()
		AccessoryClone.Parent = Character
		AccessoryClone:PivotTo(Character:GetPivot())
		AccessoryClone.Sphere:AddTag("ballnchain")
		AccessoryClone.MainWeld.Part0 = Character["Left Leg"]

		return AccessoryClone
	end,
	
	["Custom Cape"] = function(Character: Model, Accessory: Model)
		local Player = Players:GetPlayerFromCharacter(Character)
		
		local CustomCapeDataStore
		pcall(function()
			CustomCapeDataStore = DataStoreService:GetDataStore("PlayerCapeData"):GetAsync("Cape_" .. Player.UserId)
		end)
		if not CustomCapeDataStore then return end
		
		
		local AccessoryClone = Accessory:Clone()
		local AccessoryPlane = AccessoryClone["Plane.002"]
		
		
		if CustomCapeDataStore.Decal then
			local DecalId = tonumber(CustomCapeDataStore.Decal)
			
			if DecalId then
				local IsFound, Asset = pcall(function()
					return game:GetService("InsertService"):LoadAsset(DecalId)
				end)
				
				
				if IsFound and Asset then
					local FoundDecal = Asset:FindFirstChildWhichIsA("Decal", true)
					
					AccessoryPlane.Decal.Texture = FoundDecal and FoundDecal.Texture or "rbxassetid://" .. DecalId
				else
					AccessoryPlane.Decal.Texture = "rbxassetid://" .. DecalId
				end
			else
				AccessoryPlane.Decal.Texture = tostring(CustomCapeDataStore.Decal)
			end
		end
		

		if CustomCapeDataStore.Color then
			AccessoryPlane.Color = Color3.new(unpack(CustomCapeDataStore.Color))
		end
		
		if CustomCapeDataStore.Value then
			AccessoryClone:SetAttribute("Value", CustomCapeDataStore.Value)
		end
		
		
		AccessoryClone.Parent = Character
		AccessoryClone.Weld.Part0 = Character:FindFirstChild("Torso")
		AccessoryClone:SetAttribute("Cosmetic", true)
		
		return AccessoryClone
	end
}

local function Cosmetic(Player: Player, Params: {any})
	local Character = Player.Character
	local playerClass = shared.playerClasses[Player.UserId]
	local PlayerCosmetics = playerClass.Cosmetics
	local CosmeticName: string = Params.Name

	if not Character then return end

	if Params.Type == 'Accessories' then
		if Params.State == true then
			if Character:FindFirstChild(CosmeticName) or not table.find(playerClass.OwnedCosmetics, Params.Name) then return end
			
			local TotalKills = Player.leaderstats:FindFirstChild("Total Kills", true)
			local Accessory = Accessories:FindFirstChild(CosmeticName)
			if Accessory and (TotalKills.Value >= (Accessory:GetAttribute("Kills") or 0) or table.find(playerClass.OwnedCosmetics, Params.Name)) then
				if CosmeticName == "Spiral Cloth" and Player:GetAttribute("Moveset") ~= "Monster Form" then
					ComSet:FireClient(Player, "SendNotification", { Title = 'NOTIFICATION'; Text = "THIS COSMETIC IS FOR MONSTER FORM"; })
					
					return
				elseif CosmeticName == "Blocky Body" then
					local AssetsFolder = Character:FindFirstChild("Assets")
					
					for _, v in Character:GetChildren() do
						if v.Name == "CharacterMesh" then
							v.Parent = AssetsFolder
						end
					end
				end
				
				if CosmeticName:match("Cape") then
					local CapeCount = 0

					for _,v in Character:GetChildren() do
						if v.Name:match("Cape") and v:GetAttribute("Cosmetic") == true then
							CapeCount += 1
						end
					end

					if CapeCount >= 2 then
						ComSet:FireClient(Player, "SendNotification", { Title = 'NOTIFICATION'; Text = "YOU CAN'T EQUIP MORE THAN 2 CAPES"; })

						return
					end
				end
				
				
				if CosmeticName ~= "Blocky Body" then
					local AccessoryClone
					local CustomFunction = CustomAccessories[CosmeticName]

					if CustomFunction then
						AccessoryClone = CustomFunction(Character, Accessory)

					else
						AccessoryClone = Accessory:Clone()
						AccessoryClone.Parent = Character
						AccessoryClone.MainWeld.Part0 = Character[AccessoryClone.MainWeld:GetAttribute("BodyPart")]


						local Animation = AccessoryClone:FindFirstChildOfClass("Animation")
						local Animator = AccessoryClone:FindFirstChildWhichIsA("Animator", true)
						if Animation and Animator then
							Animator:LoadAnimation(Animation):Play(0)
							Animation:Destroy()
						end

					end

					if AccessoryClone then
						AccessoryClone:SetAttribute("Cosmetic", true)
					end
				end


				PlayerCosmetics.Accessories[CosmeticName] = CosmeticName

				local Value = Instance.new('StringValue')
				Value.Name = CosmeticName
				Value.Parent = Player.Cosmetics.Accessories
			end
		else
			if CosmeticName == "Blocky Body" then
				local AssetsFolder = Character:FindFirstChild("Assets")
				
				if AssetsFolder then
					for _, v in AssetsFolder:GetChildren() do
						if v.Name == "CharacterMesh" then
							v.Parent = Character
						end
					end
				end
				
				PlayerCosmetics.Accessories[CosmeticName] = nil
				Player.Cosmetics.Accessories[CosmeticName]:Destroy()
			else
				local Accessory = Character:FindFirstChild(CosmeticName)
				if Accessory then
					Player.Cosmetics.Accessories[CosmeticName]:Destroy()
					PlayerCosmetics.Accessories[CosmeticName] = nil
					Accessory:Destroy()
				end
			end
		end

	elseif Params.Type == 'Auras' then
		if Params.State == true then
			if Character:FindFirstChild(CosmeticName, true) or not table.find(playerClass.OwnedCosmetics, Params.Name) then return end
			
			local TotalKills = Player.leaderstats:FindFirstChild("Total Kills", true)
			local AuraContainer = Auras:FindFirstChild(CosmeticName)
			if AuraContainer and (TotalKills.Value >= (AuraContainer:GetAttribute("Kills") or 0) or table.find(playerClass.OwnedCosmetics, Params.Name)) then
				for _, BodyPart in AuraContainer:GetChildren() do
					for _, Particle in BodyPart:GetChildren() do
						local Clone = Particle:Clone()
						Clone.Parent = Character[BodyPart.Name]
					end
				end

				PlayerCosmetics.Auras[AuraContainer.Name] = AuraContainer.Name

				local Value = Instance.new('StringValue')
				Value.Name = AuraContainer.Name
				Value.Parent = Player.Cosmetics.Auras
			end

		else
			for _, v in Character:GetDescendants() do
				if v.Name == CosmeticName then
					v:Destroy()
				end
			end

			PlayerCosmetics.Auras[CosmeticName] = nil

			local CosmeticInstance = Player.Cosmetics.Auras:FindFirstChild(CosmeticName)
			if CosmeticInstance then
				CosmeticInstance:Destroy()
			end

		end
	end
end


--Events
CosmSet.OnServerEvent:Connect(Cosmetic)
CosmBind.Event:Connect(Cosmetic)
CosmGet.OnServerInvoke = function(Player: Player, Parameters)
	local Goal = Parameters.Goal

	if Goal == "GetAccessories" then
		local AccessoriesInformation = {
			["Accessories"] = {},
			["Auras"] = {}
		}

		for _, Category: Folder in Cosmetics:GetChildren() do
			for _, Cosmetic in Category:GetChildren() do
				AccessoriesInformation[Category.Name][Cosmetic:GetAttribute("Index")] = {
					Name = Cosmetic.Name,
					Kills = Cosmetic:GetAttribute("Kills"),
					Image = Cosmetic:GetAttribute("Image") or 17138543887
				}
			end
		end

		return AccessoriesInformation
	end
end