local LoadStart = tick()
workspace:SetAttribute("ServerOwner", game.PrivateServerOwnerId)


type ReceiptInfo = { PurchaseId: number, PlayerId: number, ProductId: number, PlaceIdWherePurchased: number, CurrencySpent: number, CurrencyType: EnumItem }

--Services
local Players = game:GetService('Players')
local DataService = game:GetService('DataStoreService')
local RS = game:GetService('ReplicatedStorage')
local SvSt = game:GetService('ServerStorage')
local Http = game:GetService('HttpService')
local RNS = game:GetService('RunService')
local Debris = game:GetService('Debris')
local StarterPlayerService = game:GetService('StarterPlayer')
local TpS = game:GetService('TeleportService')
local MessagingService = game:GetService('MessagingService')
local MarketplaceService = game:GetService('MarketplaceService')
local CollectionService = game:GetService("CollectionService")
local UserService = game:GetService("UserService")



--Assets
local Assets = SvSt.Assets

local Animations = Assets.Animations
local Sounds = Assets.Sounds

local CombatAnims = Animations.Combat
local CombatSounds = Sounds.Combat


local EmotesFolder = RS.Resources.Emotes.Animations



--Replicated Modules
local RpModules = RS.Modules

local WeldSystem = require(RpModules.WeldSystem)
local InfoModule = require(RS.Info)
local Trove = require(RpModules.Trove)



--DataStores
local DataStore = DataService:GetDataStore('DataStore')

local AdminCharBypasses = DataService:GetDataStore("BypassPlayers")

local AdminsDatabase = DataService:GetDataStore("Admins")
local DayTimeCycleDatastore = DataService:GetDataStore("DayTimeCycle")

local LastBuiltDatastore = DataService:GetDataStore("LastBuilt")
local BuildsDatastore = DataService:GetDataStore("Builds")

local CapeStore = DataService:GetDataStore("PlayerCapeData")

local TotalKillsDatastore = DataService:GetOrderedDataStore('TotalKillsDatastore')
local MonthlyKillsDatastore = DataService:GetOrderedDataStore('MonthlyKillsDatastore')
local DonationsDatastore = DataService:GetOrderedDataStore('DonationsDatastore')
local TotalDonationsDatastore = DataService:GetOrderedDataStore('TotalDonationsDatastore')


shared.playerClasses = {}




--Bindables
local Bindables = SvSt.Bindables

local CosmeticsBindable = Bindables.Cosmetics



--Remotes
local Remotes = RS.Remotes


local InviteRemotes = Remotes.Invites

local InviteSet = InviteRemotes.Set
local InviteGet = InviteRemotes.Get


local ComunicatorComms = Remotes.Comunicator

local ComSet = ComunicatorComms.Set
local ComGet = ComunicatorComms.Get


local Replication = Remotes.Replicate

local ReplicateSet = Replication.Set
local ReplicateGet = Replication.Get


local TitlesRemote = Remotes.Titles



--Server Modules
local SvModules = SvSt.Modules

local StunHandler = require(SvModules.StunHandler)
local MovesetHandlerModule = require(SvModules.MovesetHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local CollisionsModule = require(SvModules.CollisionsModule)
local SoundsModule = require(SvModules.SoundsModule)
local ReplicatedHitboxes = require(SvModules.ReplicatedHitboxes)
local DamageHandler = require(SvModules.DamageHandler)
local AnimationService = require(SvModules.AnimationService)
local Knockback = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)
local SpawnAnims = require(SvModules.SpawnAnims)
local PlayerClass = require(SvModules.PlayerClass)
local CombatUtils = require(SvModules.CombatUtils)
local Wallcombos = require(SvModules.WallCombos)
local ZonesModule = require(SvModules.Other.Zone)
local QeueModule = require(SvModules.Other.Qeue)


local InitModules = script.Modules

local WebhookModule = require(InitModules.Webhook)



--Variables
local DefaultData = PlayerClass.defaultData
local StarterPlayerFolder = script.StarterPlayer


local TimeValue: NumberValue = workspace.Terrain.Time
local PS_OwnerId = game.PrivateServerOwnerId
local CurrentSound: Sound = nil
local FadeTask: thread = nil
local Volume: number = 1.0


local AnimationsTable = {}
local Kills = {}
local Cosmetics = {}
local LocalBans = {}
local LoadedPlayers = {}


for _, Animation in Assets.Animations:GetDescendants() do
	if Animation:IsA('Animation') then
		table.insert(AnimationsTable, Animation.AnimationId)
	end
end

for _, Category in Assets.Models.Cosmetics:GetChildren() do
	for _, Cosmetic in Category:GetChildren() do
		table.insert(Cosmetics, Cosmetic)
	end
end


local Movesets = InfoModule.Movesets
local Passes = InfoModule.Passes
local Products = InfoModule.Products
local Gifts = InfoModule.Gifts
local Donations = InfoModule.Donations


local FirstOnLB = {}


local DestroyableOParams = OverlapParams.new()
DestroyableOParams.FilterType = Enum.RaycastFilterType.Include
DestroyableOParams.FilterDescendantsInstances = { workspace.Map.Destroyables }



--Functions
shared.Announcement = function(Params: { any })
	local GoalMessage = Params.Message


	local AnnouncementGui = script.Screen["Global Message"]:Clone()
	AnnouncementGui.Parent = Params.Player.PlayerGui
	AnnouncementGui:SetAttribute("Message", GoalMessage)


	if not Params.Title then
		AnnouncementGui.TextLabel.Text = "GLOBAL ANNOUNCEMENT"
	else
		AnnouncementGui.TextLabel.Text = Params.Title
	end

	for i = 1, #GoalMessage do
		task.wait(0.06)
	end


	task.delay(13, function()
		AnnouncementGui:Destroy()
	end)
end

shared.AddAppareance = function(Player: Player, Character: Model, HumanoidDescription: HumanoidDescription)
	if not Player or (typeof(Player) == "Instance" and Player.UserId <= 0) or not Character or not Character.Parent then return end

	local userId = typeof(Player) == "Instance" and Player.UserId or Player
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 5)
	if not Humanoid then return end

	local PlayersModel = Players:GetCharacterAppearanceAsync(userId)
	HumanoidDescription = HumanoidDescription or Players:GetHumanoidDescriptionFromUserId(userId)

	if HumanoidDescription then
		Humanoid:ApplyDescription(HumanoidDescription)
	end

	if PlayersModel then
		local Face = PlayersModel:FindFirstChild('face')
		if Face then
			Character.Head.face.Texture = Face.Texture
		end

		PlayersModel:Destroy()
	end


	for _, Accessory: Accessory in Character:GetChildren() do
		if Accessory:IsA("Accessory") then
			local Handle: BasePart = Accessory:FindFirstChild("Handle")
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
end

shared.sfx = function(Parameters)
	local Sound = Instance.new("Sound")
	Sound.SoundGroup = game.SoundService.Sounds


	if Parameters.AddTo then
		table.insert(Parameters.AddTo, Sound)
		Parameters.AddTo = nil
	end


	local Attachment = nil
	local EndConnection = nil
	EndConnection = Sound.Ended:connect(function()
		if Sound then
			Sound:Destroy()
		end

		if Attachment then
			Attachment:Destroy()
		end

		return EndConnection:Disconnect()
	end)


	if not Parameters.RollOffMaxDistance then
		Parameters.RollOffMaxDistance = 300
	end

	if Parameters.CFrame then
		Attachment = Instance.new("Attachment")
		Attachment.Parent = workspace.Terrain
		Attachment.WorldCFrame = Parameters.CFrame
		Parameters.Parent = Attachment
	end

	Parameters.CFrame = nil

	for Index, Value in Parameters do
		Sound[Index] = Value
	end

	return Sound, Attachment
end

shared.safeDestroy = function(instance)
	if not instance or typeof(instance) ~= "Instance" then
		return
	end

	instance:Destroy()
	instance = nil
end

shared.cfolder = function(instanceData, lifeTime)
	local newInstance = Instance.new("Accessory")

	for i, v in instanceData do
		newInstance[i] = v
	end

	if lifeTime and typeof(lifeTime)  == "number" then
		task.delay(lifeTime, function()
			shared.safeDestroy(newInstance)
		end)
	end

	return newInstance
end

local function Comma(amount)
	if not amount then
		return "nil"
	end

	return tostring(amount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function GetTableSize(Table: { any })
	local TableSize = 0

	for _,__ in Table do
		TableSize += 1
	end

	return TableSize
end

local updateFunctions = {
	TotalKills = function()
		local TotalKills = TotalKillsDatastore:GetSortedAsync(false, 50)
		local Page = TotalKills:GetCurrentPage()

		local Leaderboard = workspace.Leaderboards.AllTimeKills
		local Users = {}

		for Rank, Data in Page do
			table.insert(Users, tonumber(Data.key))
		end

		local CouldGet = pcall(function()
			Users = UserService:GetUserInfosByUserIdsAsync(Users)
		end)
		if not CouldGet or typeof(Users) ~= "table" then return end

		local UsersInfo = {}
		for Index, Info in Users do
			UsersInfo[tostring(Info.Id)] = Info
		end
		Users = nil

		for Rank, Data in Page do
			if tonumber(Data.key) <= 0 or Data.value == 0 then continue end

			local Info = UsersInfo["2"] or UsersInfo[tostring(Data.key)]
			if not Info then continue end

			local Best = Rank <= 3 and Rank >= 1

			local Holder
			if Best then
				if Rank == 1 then
					FirstOnLB['TotalKills'] = tonumber(Data.key)
				end

				Holder = Leaderboard.Screen.Leaderboard.Container[tostring(Rank)]
			else
				Holder = Leaderboard.Screen.Template:Clone()
			end

			Holder.AvatarIcon.Image = Players:GetUserThumbnailAsync(Info.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			Holder.Display.Text = Info.DisplayName
			Holder.Kills.Text = Comma(Data.value) .. " Kills"
			Holder.Rank.Text = "#" .. tostring(Rank)
			Holder.Username.Text = "@" .. Info.Username

			Holder.Visible = true
			Holder.Name = tostring(Rank)
			Holder.LayoutOrder = tonumber(Rank)
			Holder.Parent = Best and Leaderboard.Screen.Leaderboard.Container or Leaderboard.Screen.Leaderboard.Container.List.Container
		end
	end,

	MonthlyKills = function()
		local MonthlyKills = MonthlyKillsDatastore:GetSortedAsync(false, 50)
		local Page = MonthlyKills:GetCurrentPage()

		local Leaderboard = workspace.Leaderboards.MonthlyKills
		local Users = {}

		for Rank, Data in Page do
			table.insert(Users, tonumber(Data.key))
		end

		local CouldGet = pcall(function()
			Users = UserService:GetUserInfosByUserIdsAsync(Users)
		end)
		if not CouldGet or typeof(Users) ~= "table" then return end

		local UsersInfo = {}
		for Index, Info in Users do
			UsersInfo[tostring(Info.Id)] = Info
		end
		Users = nil

		for Rank, Data in Page do
			if tonumber(Data.key) <= 0 or Data.value == 0 then continue end

			local Info = UsersInfo["2"] or UsersInfo[tostring(Data.key)]
			if not Info then continue end

			local Best = Rank <= 3 and Rank >= 1

			local Holder
			if Best then
				if Rank == 1 then
					FirstOnLB['MonthlyKills'] = tonumber(Data.key)
				end

				Holder = Leaderboard.Screen.Leaderboard.Container[tostring(Rank)]
			else
				Holder = Leaderboard.Screen.Template:Clone()
			end

			Holder.AvatarIcon.Image = Players:GetUserThumbnailAsync(Info.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			Holder.Display.Text = Info.DisplayName
			Holder.Kills.Text = Comma(Data.value) .. " Kills"
			Holder.Rank.Text = "#" .. tostring(Rank)
			Holder.Username.Text = "@" .. Info.Username

			Holder.Visible = true
			Holder.Name = tostring(Rank)
			Holder.LayoutOrder = tonumber(Rank)
			Holder.Parent = Best and Leaderboard.Screen.Leaderboard.Container or Leaderboard.Screen.Leaderboard.Container.List.Container
		end
	end,

	TotalDonated = function()
		local TotalDonations = TotalDonationsDatastore:GetSortedAsync(false, 50)
		local Page = TotalDonations:GetCurrentPage()

		local Leaderboard = workspace.Leaderboards.AllTimeTopDonators
		local Users = {}

		for Rank, Data in Page do
			table.insert(Users, tonumber(Data.key))
		end

		local CouldGet = pcall(function()
			Users = UserService:GetUserInfosByUserIdsAsync(Users)
		end)
		if not CouldGet or typeof(Users) ~= "table" then return end

		local UsersInfo = {}
		for Index, Info in Users do
			UsersInfo[tostring(Info.Id)] = Info
		end
		Users = nil

		for Rank, Data in Page do
			if tonumber(Data.key) <= 0 or Data.value == 0 then continue end

			local Info = UsersInfo["2"] or UsersInfo[tostring(Data.key)]
			if not Info then continue end

			local Best = Rank <= 3 and Rank >= 1

			local Holder
			if Best then
				if Rank == 1 then
					FirstOnLB['TotalDonated'] = tonumber(Data.key)
				end

				Holder = Leaderboard.Screen.Leaderboard.Container[tostring(Rank)]
			else
				Holder = Leaderboard.Screen.Template:Clone()
			end

			Holder.AvatarIcon.Image = Players:GetUserThumbnailAsync(Info.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			Holder.Display.Text = Info.DisplayName
			Holder.Kills.Text = Comma(Data.value) .. " Robux"
			Holder.Rank.Text = "#" .. tostring(Rank)
			Holder.Username.Text = "@" .. Info.Username

			Holder.Visible = true
			Holder.Name = tostring(Rank)
			Holder.LayoutOrder = tonumber(Rank)
			Holder.Parent = Best and Leaderboard.Screen.Leaderboard.Container or Leaderboard.Screen.Leaderboard.Container.List.Container
		end
	end,

	MonthlyDonated = function()
		local MonthlyDonated = DonationsDatastore:GetSortedAsync(false, 50)
		local Page = MonthlyDonated:GetCurrentPage()

		local Leaderboard = workspace.Leaderboards.MonthlyTopDonators
		local Users = {}

		for Rank, Data in Page do
			table.insert(Users, tonumber(Data.key))
		end

		local CouldGet = pcall(function()
			Users = UserService:GetUserInfosByUserIdsAsync(Users)
		end)
		if not CouldGet or typeof(Users) ~= "table" then return end

		local UsersInfo = {}
		for Index, Info in Users do
			UsersInfo[tostring(Info.Id)] = Info
		end
		Users = nil

		for Rank, Data in Page do
			if tonumber(Data.key) <= 0 or Data.value == 0 then continue end

			local Info = UsersInfo["2"] or UsersInfo[tostring(Data.key)]
			if not Info then continue end

			local Best = Rank <= 3 and Rank >= 1

			local Holder
			if Best then
				if Rank == 1 then
					FirstOnLB['MonthlyDonated'] = tonumber(Data.key)
				end

				Holder = Leaderboard.Screen.Leaderboard.Container[tostring(Rank)]
			else
				Holder = Leaderboard.Screen.Template:Clone()
			end

			Holder.AvatarIcon.Image = Players:GetUserThumbnailAsync(Info.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			Holder.Display.Text = Info.DisplayName
			Holder.Kills.Text = Comma(Data.value) .. " Robux"
			Holder.Rank.Text = "#" .. tostring(Rank)
			Holder.Username.Text = "@" .. Info.Username

			Holder.Visible = true
			Holder.Name = tostring(Rank)
			Holder.LayoutOrder = tonumber(Rank)
			Holder.Parent = Best and Leaderboard.Screen.Leaderboard.Container or Leaderboard.Screen.Leaderboard.Container.List.Container
		end
	end,
}

local function SpinEmoteFunc(Player: Player)
	local emotePool = {}
	for _, EmoteAnimation in EmotesFolder:GetChildren() do
		if table.find(shared.playerClasses[Player.UserId].OwnedEmotes, EmoteAnimation.Name) ~= nil then continue end 

		table.insert(emotePool, EmoteAnimation.Name)
	end

	if #emotePool <= 0 then return end


	local newEmote = emotePool[math.random(1, #emotePool)]

	table.insert(shared.playerClasses[Player.UserId].OwnedEmotes, newEmote)
end

local function SpinCosmeticFunc(Player: Player, Bulk: boolean?)
	local cosmeticPool = {}
	for _, Category in Assets.Models.Cosmetics:GetChildren() do
		for _, Cosmetic in Category:GetChildren() do
			if table.find(shared.playerClasses[Player.UserId].OwnedCosmetics, Cosmetic.Name) ~= nil then continue end 

			table.insert(cosmeticPool, Cosmetic.Name)
		end
	end

	Player:SetAttribute("LeftCosmetics", #cosmeticPool)

	if #cosmeticPool <= 0 then return end


	local newCosmetic = cosmeticPool[math.random(1, #cosmeticPool)]

	table.insert(shared.playerClasses[Player.UserId].OwnedCosmetics, newCosmetic)

	shared.playerClasses.TitlesProgress.Cosmetics += 1
	Player:SetAttribute("CosmeticsProgress", shared.playerClasses.TitlesProgress.Cosmetics)
	
	return newCosmetic
end

local function isAdmin(Player: Player)
	local isAdmin = table.find(InfoModule.Admins, Player.UserId) ~= nil or AdminsDatabase:GetAsync(Player.UserId) == true
	if isAdmin == true or isAdmin == false then
		Player:SetAttribute("isAdmin", isAdmin)
	end
	
	return isAdmin
end

local function ownsGamepass(userId: number?, PassName)
	if typeof(userId) == "Instance" and userId.ClassName == "Player" then
		userId = userId.UserId
	end

	
	local playerClass = shared.playerClasses[userId]
	if playerClass then
		return playerClass.OwnedPasses[PassName] == true
	else
		local ownsGamepass = MarketplaceService:UserOwnsGamePassAsync(userId, Passes[PassName])
		if ownsGamepass == true then
			return true
		else
			playerClass = DataStore:GetAsync(userId)

			if playerClass then
				if playerClass.OwnedPasses then
					return playerClass.OwnedPasses[PassName] == true
				else
					return nil
				end
			else
				return nil
			end
		end
	end
end

local function hasAccessToAdminMovesets(Player: Player)
	local userId = Player.UserId

	return FirstOnLB.TotalDonated == userId or FirstOnLB.MonthlyDonated == userId or AdminCharBypasses:GetAsync(userId) == true or AdminsDatabase:GetAsync(userId) == true or userId == 9904096067
end

local function FinishGame()
	local Type = workspace:GetAttribute("Legendary") and "Legendary" or "Normal"
	workspace:SetAttribute("FinishedDuel", Type)

	workspace:AddTag('Finished')
	task.delay(5, function()
		TpS:TeleportAsync(workspace:GetAttribute("DuelsHubPlaceId"), Players:GetPlayers())
	end)
end

local function HumanoidDied(Player: Player)
	if not Player.Character then return end
	if workspace.Configuration.KickOnDeath.Value == true then
		Player:Kick("You were kicked because you died")

		return
	end
	
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		Player:SetAttribute('TimesDied', Player:GetAttribute('TimesDied') + 1)
	end
	

	local Character = Player.Character
	local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid: Humanoid = Character.Humanoid

	if not Character:HasTag('DontDoDieFunction') then
		if Humanoid.BreakJointsOnDeath then
			for _, v in Character:GetDescendants() do
				if v:IsA("Motor6D") or v:IsA("BallSocketConstraint") then
					v:Destroy()
				elseif v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") then
					v.AssemblyLinearVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					v.AssemblyAngularVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
				end
			end

			StunHandler:Stun(Character, 6)
		else
			Character:AddTag('CantRagdollCancel')

			RagdollHandler.ragdoll(Humanoid)
		end
	end
	
	
	local deathSoundId = Player:GetAttribute("deathSound")
	if deathSoundId ~= nil and HumRP then
		local deathSound = Instance.new("Sound")
		deathSound.RollOffMaxDistance = 250
		deathSound.RollOffMinDistance = 10
		deathSound.Volume = 1
		deathSound.SoundId = "rbxassetid://"..tostring(deathSoundId)
		deathSound.SoundGroup = game.SoundService.Sounds
		deathSound.Parent = HumRP
		deathSound:Play()
		task.spawn(function()
			deathSound.Stopped:Wait()
			deathSound:Destroy()
		end)
	end
	
	
	iFramesService:RemoveAlliFrames(Character)
	
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") and Player:GetAttribute('TimesDied') == 2 then
		if Player:GetAttribute('Teammate') then
			local LosersTeammate = Players:FindFirstChild(Player:GetAttribute('Teammate'))
			if LosersTeammate and LosersTeammate:GetAttribute('TimesDied') < 2 then
				return
			else
				FinishGame()
			end
		else
			FinishGame()
		end

		for _, Winner in Players:GetPlayers() do
			if Winner ~= Player and Winner.Name ~= Player:GetAttribute('Teammate') and not Winner:HasTag('AddedWinPoints') then
				Winner:AddTag('AddedWinPoints')
				
				local WinnerplayerClass = shared.playerClasses[Winner.UserId]
				if not WinnerplayerClass then return end
				
				if Winner:GetAttribute('Teammate') then
					local WinnersTeammate: Player = Players:FindFirstChild(Winner:GetAttribute('Teammate'))
					local WinnersTeammateplayerClass = shared.playerClasses[WinnersTeammate.UserId]
					if not WinnersTeammateplayerClass then return end
					
					if WinnersTeammate then
						WinnersTeammate:AddTag('AddedWinPoints')
						WinnersTeammateplayerClass.Rank2v2 += 5
					end

					WinnerplayerClass.Rank2v2 += 5
				else
					WinnerplayerClass.Rank1v1 += 5
				end
			end
		end

		return
	end
	
	
	local respawnConnection
	local respawnStartTime = os.clock()
	local respawnDelay: number = Player:WaitForChild("RespawnTime").Value
	
	
	respawnConnection = RNS.Heartbeat:Connect(function(deltaTime)
		if Player.Commands.NoRespawn.Value then
			respawnStartTime = os.clock()
			if respawnDelay ~= 2.5 then
				respawnDelay = 2.5
			end
			
			return
		end
		
		if Player:WaitForChild("CanRespawn").Value == true then
			if (os.clock() - respawnStartTime) >= respawnDelay then
				Character:Destroy()

				if Player:IsDescendantOf(game) then
					Player:LoadCharacter()
				end

				respawnConnection:Disconnect()
				return
			end
		else
			respawnStartTime = os.clock()
			
			if respawnDelay ~= 2.5 then
				respawnDelay = 2.5
				return
			end
		end
	end)
end

local function SaveData(userId, playerClass)
	if not shared.playerClasses[userId] then return end

	local Data = playerClass or table.clone(shared.playerClasses[userId])
	local ReceivedGifts = Data.ReceivedGifts
	local PlayerKills = Kills[userId]

	shared.playerClasses[userId] = nil
	Data.ReceivedGifts = nil
	Kills[userId] = nil

	PlayerClass:RemoveClass(userId)

	DataStore:UpdateAsync(userId, function(oldData)
		if oldData then
			oldData = Http:JSONDecode(oldData)

			for Index, Value in DefaultData do
				if oldData[Index] then continue end

				oldData[Index] = Value
			end

			local SetOldGifts = false

			for _,v in oldData.PendingGifts do
				if not table.find(ReceivedGifts, v[2]) then
					Data.PendingGifts = oldData.PendingGifts

					break
				end
			end
		end

		return Http:JSONEncode(Data)
	end)

	if PlayerKills ~= nil then
		local totalKills = PlayerKills.Total
		local monthlyKills = PlayerKills.Monthly

		if totalKills ~= nil then
			TotalKillsDatastore:SetAsync(userId, totalKills)
		end

		if monthlyKills ~= nil then
			MonthlyKillsDatastore:SetAsync(userId, monthlyKills)
		end
	end
end

local function fadeOutAndDestroy(sound: Sound, fadeTime: number)
	if not sound or not sound:IsDescendantOf(workspace.Thrown) or not sound.IsPlaying then
		if sound and sound.Parent then
			sound:Destroy()
		end
		return
	end

	if FadeTask then
		task.cancel(FadeTask)
		FadeTask = nil
	end

	local startVolume = sound.Volume
	local elapsed = 0.0

	FadeTask = task.spawn(function()
		while elapsed < fadeTime and sound.IsPlaying do
			elapsed += RNS.Heartbeat:Wait()
			sound.Volume = startVolume * (1 - math.clamp(elapsed / fadeTime, 0.0, 1.0))
		end

		if sound:IsDescendantOf(workspace.Thrown) then
			if sound.IsPlaying then
				sound:Stop()
			end
			sound:Destroy()
		end

		if CurrentSound == sound then
			CurrentSound = nil
		end

		FadeTask = nil
	end)
end

local function ChatCommands(Player: Player, msg: string)
	local CommandSplit = msg:split('/')
	local isCommand = CommandSplit[1] == '' and CommandSplit[2] ~= ''

	if isCommand == true then
		local IsPSOwner = Player.UserId == PS_OwnerId
		local IsAdmin = isAdmin(Player)

		if IsAdmin ~= true and not IsPSOwner then return end

		local SplittedMsg = msg:split(' ')
		local CommandName = SplittedMsg[1]
		
		pcall(function()
			WebhookModule(Player, msg) 
		end)

		if CommandName == "/fly" then
			local GoalPlayer
			if not SplittedMsg[2] or SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer then return end

			ReplicateSet:FireClient(GoalPlayer, "flystart")

		elseif CommandName == "/unfly" then
			local GoalPlayer
			if not SplittedMsg[2] or SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer then return end

			ReplicateSet:FireClient(GoalPlayer, "flyend")

		elseif CommandName == "/builder" then
			local GoalPlayer
			if not SplittedMsg[2] or SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			elseif SplittedMsg[2] == "all" then
				ComSet:FireAllClients("buildmode")

				return
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer then return end

			ComSet:FireClient(GoalPlayer, "buildmode")

		elseif CommandName == "/play" and SplittedMsg[2] then
			local soundId = tonumber(SplittedMsg[2])
			if not soundId then return end

			if CurrentSound then
				if FadeTask then
					task.cancel(FadeTask)
					FadeTask = nil
				end
				
				CurrentSound:Stop()
				CurrentSound:Destroy()
				CurrentSound = nil
			end

			local sound, _ = shared.sfx({
				Name = "ServerMusic",
				SoundId = "rbxassetid://" .. tostring(soundId),
				Volume = Volume,
				Looped = false,
				Parent = workspace.Thrown,
				RollOffMaxDistance = 300
			})

			sound.Ended:Connect(function()
				if sound:IsDescendantOf(workspace.Thrown) then sound:Destroy() end
				if CurrentSound == sound then CurrentSound = nil end
			end)

			sound:Play()
			CurrentSound = sound

		elseif CommandName == "/stop" then
			if CurrentSound then
				fadeOutAndDestroy(CurrentSound, 0.7)
			end

		elseif CommandName == "/volume" and SplittedMsg[2] then
			local vol = tonumber(SplittedMsg[2])
			if not vol then return end

			Volume = math.clamp(vol, 0, 10) / 10
			if CurrentSound then
				CurrentSound.Volume = Volume
			end

		elseif CommandName == "/bring" then
			if not SplittedMsg[2] then return end

			local GoalPlayer
			if SplittedMsg[2]:lower() == "all" then
				for _,v in Players:GetPlayers() do
					v.Character:PivotTo(Player.Character.PrimaryPart.CFrame)
				end

				return
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer or not GoalPlayer.Character then return end

			GoalPlayer.Character:PivotTo(Player.Character.PrimaryPart.CFrame)

		elseif SplittedMsg[1] == '/copyoutfit' then
			local TargetUsername = msg:gsub('/copyoutfit ', '')
			local success, TargetUserId = pcall(function()
				return Players:GetUserIdFromNameAsync(TargetUsername)
			end)

			if success and TargetUserId then
				local success2, TargetDescription = pcall(function()
					return Players:GetHumanoidDescriptionFromUserId(TargetUserId)
				end)

				if success2 and TargetDescription then
					local PlayerCharacter = Player.Character
					if PlayerCharacter then
						local PlayerHumanoid = PlayerCharacter:FindFirstChildOfClass("Humanoid")
						if PlayerHumanoid then
							PlayerHumanoid:ApplyDescription(TargetDescription)
						end
					end
				end
			end

		elseif SplittedMsg[1] == '/kjrequest' then
			local EnemyPlayer = Players:FindFirstChild(msg:gsub('/kjrequest ', ''))
			if EnemyPlayer then
				EnemyPlayer:SetAttribute("DamageNeed", 1)
				EnemyPlayer.AwakeningProgress.Value = 100
			end

		elseif SplittedMsg[1] == '/lastbreath' then
			local EnemyPlayer = Players:FindFirstChild(msg:gsub('/lastbreath ', ''))
			if EnemyPlayer then
				local EnemyCharacter = EnemyPlayer.Character
				EnemyCharacter:SetAttribute("InstandVariant", true)
			end
			
		elseif CommandName == "/goto" then
			if not SplittedMsg[2] then return end

			local GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			if not GoalPlayer or not GoalPlayer.Character or not GoalPlayer.Character.PrimaryPart then return end

			Player.Character:PivotTo(GoalPlayer.Character.PrimaryPart.CFrame)

		elseif CommandName == "/size" then
			if not SplittedMsg[2] or not SplittedMsg[3] then return end

			local GoalPlayer
			if SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer or not GoalPlayer.Character then return end

			local IsSizeValid, GoalSize = pcall(function()
				return tonumber(SplittedMsg[3])
			end)
			if not IsSizeValid then return end

			GoalPlayer.Character:ScaleTo(math.clamp(GoalSize, 0.1, 100))

		elseif SplittedMsg[1] == '/godmode2' then
			local PlayerCharacter = Player.Character
			if PlayerCharacter then
				local Humanoid = PlayerCharacter:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid.MaxHealth = math.huge
					Humanoid.Health = Humanoid.MaxHealth
				end
			end

		elseif CommandName == "/godmode" then
			local GoalPlayer
			if not SplittedMsg[2] or SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			elseif SplittedMsg[2]:lower() == "all" then
				for _,v in Players:GetPlayers() do
					local LastState = v.Character:GetAttribute("Godmode")

					if LastState == true then
						iFramesService:RemoveAlliFrames(v.Character)
						v.Character:SetAttribute("Godmode", false)
					else
						iFramesService:AddAlliFrames(v.Character)
						v.Character:SetAttribute("Godmode", true)
					end

				end

				return
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer or not GoalPlayer.Character then return end


			local LastState = GoalPlayer.Character:GetAttribute("Godmode")

			if LastState == true then
				iFramesService:RemoveAlliFrames(GoalPlayer.Character)
				GoalPlayer.Character:SetAttribute("Godmode", false)
			else
				iFramesService:AddAlliFrames(GoalPlayer.Character)
				GoalPlayer.Character:SetAttribute("Godmode", true)
			end

		elseif CommandName == "/respawn" then
			local GoalPlayer
			if not SplittedMsg[2] or SplittedMsg[2]:lower() == "me" then
				GoalPlayer = Player
			elseif SplittedMsg[2] == "all" then
				for _,v in Players:GetPlayers() do
					v:LoadCharacter()
				end

				return
			else
				GoalPlayer = Players:FindFirstChild(SplittedMsg[2])
			end
			if not GoalPlayer then return end

			GoalPlayer:LoadCharacter()

		elseif CommandName == '/kick' then
			local EnemyPlayer = Players:FindFirstChild(msg:gsub('/kick ', ''))
			if EnemyPlayer then
				if EnemyPlayer == Player then return end

				EnemyPlayer:Kick('You were kicked from the experience.')
			end

		elseif CommandName == "/ban" then
			if not SplittedMsg[2] then return end

			local GoalPlayer: Player = Players:FindFirstChild(SplittedMsg[2])
			if not GoalPlayer then return end
			if GoalPlayer == Player then
				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = "YOU CAN'T BAN YOURSELF" })

				return
			end

			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = GoalPlayer.Name .. " WAS BANNED FROM THIS SERVER" })

			LocalBans[GoalPlayer.Name] = GoalPlayer.UserId
			GoalPlayer:Kick("You were banned from this server")

		elseif CommandName == "/unban" then
			if not SplittedMsg[2] then return end

			LocalBans[SplittedMsg[2]] = nil

		elseif CommandName == '/gban' then
			if not IsAdmin then return end

			local EnemyUserId, EnemyName = SplittedMsg[2], nil
			local BanTime = SplittedMsg[3]
			local CanBan = pcall(function()
				BanTime = tonumber(SplittedMsg[3])
				EnemyUserId = tonumber(EnemyUserId)
				EnemyName = Players:GetNameFromUserIdAsync(tonumber(EnemyUserId))
			end)

			if EnemyUserId == Player.UserId then
				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = "YOU CAN'T BAN YOURSELF" })

				return
			end

			if CanBan == true and (BanTime == -1 or BanTime > 0) then
				Players:BanAsync({ UserIds = { EnemyUserId }, ApplyToUniverse = true, Duration = BanTime, DisplayReason = 'You have been banned for using exploits.', PrivateReason = SplittedMsg[4] or 'Exploits', ExcludeAltAccounts = false })

				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = "THE USER " .. EnemyName .. " (" .. EnemyUserId .. ") WAS BANNED " .. (BanTime == -1 and "PERMANENTLY." or "FOR " .. BanTime .. " SECONDS.") })
			end

		elseif CommandName == '/gunban' then
			if not IsAdmin then return end

			local EnemyUserId, EnemyName = SplittedMsg[2], nil
			local CanUnBan = pcall(function()
				EnemyUserId = tonumber(EnemyUserId)
				EnemyName = Players:GetNameFromUserIdAsync(tonumber(EnemyUserId))
			end)

			if CanUnBan == true and EnemyUserId ~= Player.UserId then
				Players:UnbanAsync({ UserIds = { EnemyUserId }, ApplyToUniverse = true })

				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = "THE USER " .. EnemyUserId .. " (" .. EnemyName .. ") WAS UNBANNED." })
			end

		elseif CommandName == '/freeze' then
			if not IsAdmin then return end

			local EnemyPlayer: Player? = Players:FindFirstChild(msg:gsub('/freeze ', ''))
			if EnemyPlayer then
				if EnemyPlayer == Player then return end

				local EnemyCharacter = EnemyPlayer.Character
				if EnemyCharacter then
					local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild('HumanoidRootPart')
					if EnemyHumRP then
						if EnemyCharacter:HasTag('Freezed') then
							EnemyCharacter:RemoveTag('Freezed')

							EnemyHumRP.Anchored = false
						else
							local FreezeConnection: RBXScriptConnection

							EnemyCharacter:AddTag('Freezed')
							EnemyHumRP.Anchored = true
							FreezeConnection = EnemyHumRP:GetPropertyChangedSignal('Anchored'):Connect(function()
								if EnemyCharacter:HasTag('Freezed') then
									EnemyHumRP.Anchored = true
								else
									FreezeConnection:Disconnect()
								end
							end)
						end
					end
				end
			end

		elseif CommandName == '/gmute' then
			if not IsAdmin then return end

			local EnemyPlayer: Player? = Players:FindFirstChild(msg:gsub('/globalmute ', ''))
			if EnemyPlayer then
				if EnemyPlayer == Player then return end

				if EnemyPlayer:HasTag('Muted') then
					EnemyPlayer:RemoveTag('Muted')
					ComSet:FireClient(EnemyPlayer, 'Unmute')
				else
					EnemyPlayer:AddTag('Muted')
					ComSet:FireClient(EnemyPlayer, 'Mute')
				end
			end

		elseif CommandName == '/gannounce' then
			if not IsAdmin then return end

			MessagingService:PublishAsync('Announcement', msg:gsub('/gannounce ', ''))

		elseif CommandName == '/addmove' then
			if not SplittedMsg[2] or not SplittedMsg[3] or not IsAdmin then return end

			local Move
			for _, Tool: Tool in SvSt.Movesets:GetDescendants() do
				if Tool:IsA('Tool') then
					local lowerToolName = Tool.Name:lower()
					local lowerGoalToolName = msg:gsub(CommandName.." "..SplittedMsg[2].." ", ""):lower()

					if lowerToolName:match(lowerGoalToolName) or lowerToolName:gsub(" ", ""):match(lowerGoalToolName:gsub(" ", "")) then
						Move = Tool

						break
					end
				end
			end

			local function addMove(goalPlayer)
				if not goalPlayer then return end

				local movesCount = #goalPlayer.Moveset:GetChildren()
				if movesCount == 9 then return end

				local MoveTool = Move:Clone()
				MoveTool.Parent = goalPlayer.Moveset
				MoveTool:SetAttribute('Index', movesCount + 1)
			end

			if Move then
				if SplittedMsg[2]:lower() == "all" then
					for _, goalPlayer in Players:GetPlayers() do
						addMove(goalPlayer)
					end

				elseif SplittedMsg[2]:lower() == "me" then
					addMove(Player)

				else
					addMove(Players:FindFirstChild(SplittedMsg[2]))
				end
			end

		elseif CommandName == '/delmove' then
			if not SplittedMsg[2] or not SplittedMsg[3] or not IsAdmin then return end

			local function delMove(goalPlayer)
				if not goalPlayer then return end

				for _, Tool: Tool in goalPlayer.Moveset:GetChildren() do
					if Tool:IsA("Tool") then
						local lowerToolName = Tool.Name:lower()
						local lowerGoalToolName = msg:gsub(CommandName.." "..SplittedMsg[2].." ", ""):lower()

						if lowerToolName == lowerGoalToolName or lowerToolName:gsub(" ", "") == lowerGoalToolName:gsub(" ", "") then
							local LastIndex = Tool:GetAttribute('Index')
							Tool:Destroy()

							for _,v in goalPlayer.Moveset:GetChildren() do
								if v:GetAttribute('Index') > LastIndex then
									v:SetAttribute('Index', v:GetAttribute('Index') - 1)
								end
							end
						end
					end
				end
			end


			if SplittedMsg[2]:lower() == "all" then
				for _, goalPlayer in Players:GetPlayers() do
					delMove(goalPlayer)
				end

			elseif SplittedMsg[2]:lower() == "me" then
				delMove(Player)

			else
				delMove(Players:FindFirstChild(SplittedMsg[2]))
			end

		elseif CommandName == '/giveadmin' or CommandName == '/removeadmin' then
			if Player.UserId ~= 9904096067 then return end

			local goalUserId = SplittedMsg[2]
			local canProceed = pcall(function()
				goalUserId = tonumber(goalUserId)
				Players:GetNameFromUserIdAsync(goalUserId)
			end)

			if canProceed == true and goalUserId ~= 9904096067 then
				local goalState = false
				if CommandName == '/giveadmin' then
					goalState = true
				end

				AdminsDatabase:SetAsync(goalUserId, goalState)
			end

		elseif CommandName == '/givevip' or CommandName == '/removevip' then
			if not IsAdmin then return end

			local goalUserId = SplittedMsg[2]
			local canProceed = pcall(function()
				goalUserId = tonumber(goalUserId)
				Players:GetNameFromUserIdAsync(goalUserId)
			end)

			if canProceed == true and goalUserId ~= 9904096067 and goalUserId ~= Player.UserId then
				local goalState = false
				if CommandName == '/givevip' then
					goalState = true
				end

				local goalPlayer = Players:GetPlayerByUserId(goalUserId)
				if goalPlayer then
					if goalState == true then
						local playerClass = shared.playerClasses[Player.UserId]
						if not playerClass then return end
						
						ComSet:FireClient(Player, "SendNotification", { Text = "Unlocked VIP!" })
						if Passes["VIP"] and playerClass.OwnedPasses["VIP"] ~= true then
							playerClass.OwnedPasses["VIP"] = true
						end
						
						Player:SetAttribute("HasVIP", true)
						
						
						TitlesRemote:FireClient(Player, "UnlockTitle", "VIP")
						ComSet:FireClient(Player, 'AddEmoteSlots')
						ComSet:FireClient(Player, 'AddSecondPage')
						ComSet:FireClient(Player, 'PS+')
						
						
						table.insert(playerClass.OwnedTitles, "VIP")
						table.insert(playerClass.OwnedCosmetics, "Custom Cape")
					else
						goalPlayer:SetAttribute("HasVIP", nil)
					end
				end
			end

		elseif CommandName == '/giveadminchar' or CommandName == '/removeadminchar' then
			if not IsAdmin then return end

			local goalUserId = SplittedMsg[2]
			local canProceed = pcall(function()
				goalUserId = tonumber(goalUserId)
				Players:GetNameFromUserIdAsync(goalUserId)
			end)

			if canProceed == true and goalUserId ~= 9904096067 and goalUserId ~= Player.UserId then
				local goalState = false
				if CommandName == '/giveadminchar' then
					goalState = true
				end

				AdminCharBypasses:SetAsync(goalUserId, goalState)

				local goalPlayer = Players:GetPlayerByUserId(goalUserId)
				if goalPlayer then
					if goalState == true then
						ComSet:FireClient(goalPlayer, 'GiveAdminChar')
					else
						ComSet:FireClient(goalPlayer, 'RemoveAdminChar')
					end
				end
			end
		end
	end
end

local function UpdateCosmetic(Player: Player)
	local playerClass = shared.playerClasses[Player.UserId]
	if not playerClass then return end
	
	local TotalKills = Player.leaderstats:FindFirstChild("Total Kills", true)
	for _, Cosmetic: Model in Cosmetics do
		if Cosmetic.Name == "Custom Cape" and Player:GetAttribute("HasVIP") then
			table.insert(playerClass.OwnedCosmetics, Cosmetic.Name)
		end
		
		if TotalKills.Value >= Cosmetic:GetAttribute("Kills") and not table.find(playerClass.OwnedCosmetics, Cosmetic.Name) then
			table.insert(playerClass.OwnedCosmetics, Cosmetic.Name)
		end
	end

	task.spawn(function()
		local cosmeticPool = {}
		for _, Category in Assets.Models.Cosmetics:GetChildren() do
			for _, Cosmetic in Category:GetChildren() do
				if table.find(playerClass.OwnedCosmetics, Cosmetic.Name) ~= nil then continue end 

				table.insert(cosmeticPool, Cosmetic.Name)
			end
		end

		Player:SetAttribute("LeftCosmetics", #cosmeticPool)


		local OwnedCosmeticsCount = 0
		for _,v in playerClass.OwnedCosmetics do
			OwnedCosmeticsCount += 1
		end

		playerClass.TitlesProgress.Cosmetics = OwnedCosmeticsCount
		Player:SetAttribute("CosmeticsProgress", OwnedCosmeticsCount)
	end)
	
	Player:SetAttribute("OwnedCosmetics", Http:JSONEncode(playerClass.OwnedCosmetics))
end

local ComunicatorFunctions = {
	MonsterPosConfrim = function(Player: Player, Parameters)
		local Position = Parameters.Pos
		if typeof(Position) ~= "Vector3" then return end
		
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart
		if not Character or not HumRP then return end
		
		local function clampDistance(origin, target, max)
			local dir = target - origin
			local mag = dir.Magnitude
			
			if mag <= max then 
				return target 
			end
			if mag == 0 then 
				return origin 
			end
			
			return origin + dir.Unit * max
		end
		
		Position = clampDistance(HumRP.Position, Position, 300)
		
		local RayOrigin = Position + Vector3.new(0, 5, 0)
		local RayDir = Vector3.new(0, -200, 0)
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		RayParams.FilterDescendantsInstances = {
			Character
		}
		
		
		local Hit = workspace:Raycast(RayOrigin, RayDir, RayParams)
		if Hit and Hit.Position then
			Position = Hit.Position
		end
		
		local Name = "MonsterPosConfrim"
		local HasAlready = Character:FindFirstChild(Name)
		
		if HasAlready and HasAlready:IsA("CFrameValue") then
			HasAlready.Value = CFrame.new(Position)
		else
			local CFrameValue = Instance.new("CFrameValue")
			CFrameValue.Name = Name
			CFrameValue.Value = CFrame.new(Position)
			CFrameValue.Parent = Character
		end
	end,
	
	SendDuoInvite = function(Player: Player, DuoName: string)
		if DuoName == Player.Name or DuoName == '' then return end
		local DuoPlayer = Players:FindFirstChild(DuoName)

		if DuoPlayer then
			local State = InviteGet:InvokeClient(DuoPlayer, 'Invite', { Inviter = Player.Name; })

			if State == 'Accepted' and DuoPlayer and DuoPlayer.Parent and Player and Player.Parent and Player:GetAttribute('Teammate') == 'nil' then
				ComSet:FireClient(Player, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = false; })
				ComSet:FireClient(DuoPlayer, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = false; })
				
				Player:SetAttribute('MainTeammate', true)
				DuoPlayer:SetAttribute('MainTeammate', false)
				
				Player:SetAttribute('Teammate', DuoName)
				DuoPlayer:SetAttribute('Teammate', Player.Name)
				
				Player.Character:PivotTo(workspace.Miscellaneous["PvP Twos"].PrimaryPart.CFrame)
				DuoPlayer.Character:PivotTo(workspace.Miscellaneous["PvP Twos"].PrimaryPart.CFrame)
			end
		end
	end,
	
	EquipTitle = function(Player: Player, Title: string)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass or not table.find(playerClass.OwnedTitles, Title) then return end

		playerClass.EquippedTitle = Title

		local Character = Player.Character
		if not Character or not Character:FindFirstChild("Head") then return end

		local Head = Character.Head
		local LastUI = Head:FindFirstChild("TitleUI")
		if LastUI then
			LastUI:Destroy()
		end

		local TitleColor
		for _, Config in InfoModule.Titles do
			if Config.Name ~= Title then continue end

			local TitleUI = Assets.Models.TitleUI:Clone()
			TitleUI.Text.Text = "[" .. Title .. "]"
			TitleUI.Text.TextColor3 = Config.TitleColor
			TitleUI.Parent = Character.Head

			TitleColor = TitleUI.Text.TextColor3

			break
		end

		Player:SetAttribute("EquippedTitle", "[" .. Title .. "]")
		Player:SetAttribute("TitleColor", TitleColor)
	end,

	UnequipTitle = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end

		playerClass.EquippedTitle = ""


		local Character = Player.Character
		if not Character or not Character:FindFirstChild("Head") then return end

		local Head = Character.Head
		local TitleUI = Head:FindFirstChild("TitleUI")
		if TitleUI then
			TitleUI:Destroy()
		end

		Player:SetAttribute("EquippedTitle", nil)
		Player:SetAttribute("TitleColor", nil)
	end,
	
	SendGift = function(Player: Player, Parameters)
		local function ErrorNotification()
			ComSet:FireClient(Player, "SendNotification", { Text = "Error during validation. Please try again." })
		end


		local userId = Parameters.userId
		local Pass = Parameters.Pass

		if not userId or typeof(userId) ~= "number" or not Players:GetNameFromUserIdAsync(userId) or not Pass or typeof(Pass) ~= "string" or not Gifts[Pass] then
			return ErrorNotification()
		end

		if not Gifts[Pass] then
			return ErrorNotification()
		end
		
		
		local playerClass = shared.playerClasses[userId]
		if not playerClass then
			local CouldGet, Data = pcall(function()
				return DataStore:GetAsync(userId)
			end)
			if not CouldGet then
				return ErrorNotification()
			end

			if not Data or typeof(Data) ~= "string" then
				playerClass = DefaultData
			else
				playerClass = Http:JSONDecode(Data)
			end
		end
		
		for Index, Value in DefaultData do
			if playerClass[Index] then continue end

			playerClass[Index] = Value
		end


		if playerClass.OwnedPasses[Pass] == true then
			return ComSet:FireClient(Player, "SendNotification", { Text = "Subject already owns that GamePass." })
		end


		MarketplaceService:PromptProductPurchase(Player, Gifts[Pass])
		
		Player:SetAttribute("GiftingPass", Pass)
		Player:SetAttribute("GiftingPlayer", userId)
		
		ComSet:FireClient(Player, "SendNotification", { Text = "Subject is eligible!" })
	end,
	
	Buildmode = function(Player: Player, Parameters: {})
		if PS_OwnerId == 0 then return end

		local Todo: string = rawget(Parameters, "Todo")

		if Todo == "Place" then
			if Parameters.Class == "Throwable" then
				local Part: Part? = RS.Resources.Trashcan:Clone()

				Part:AddTag("PSBuilt")
				Part:AddTag("Throwable")

				Part:SetAttribute("Collision", true)
				Part:SetAttribute("Shadow", true)
				Part:SetAttribute("Serial", Parameters.Serial)

				Part.Name = Parameters.Serial
				Part.CFrame = Parameters.CFrame
				Part.Parent = workspace.Built

			else
				local Part: Part? = Instance.new(Parameters.Class)

				for Name, Value in Parameters.Properties do
					Part[Name] = Value
				end

				Part:AddTag("PSBuilt")
				Part:AddTag("Combeable")

				Part:SetAttribute("Collision", true)
				Part:SetAttribute("Shadow", true)
				Part:SetAttribute("Serial", Parameters.Serial)

				Part.Size = Parameters.Size
				Part.Name = Parameters.Serial
				Part.Transparency = Parameters.Transparency or 0
				Part.Material = Parameters.Material or Enum.Material.SmoothPlastic
				Part.Color = Parameters.Color or Color3.fromRGB(163, 162, 165)
				Part.CFrame = Parameters.CFrame
				Part.Anchored = true
				Part.Parent = workspace.Built


				local BuildText = script.Screen.BuildText:Clone()
				BuildText.Parent = Part


				local LiveOverlapParameters = OverlapParams.new()
				LiveOverlapParameters.FilterType = Enum.RaycastFilterType.Include
				LiveOverlapParameters.FilterDescendantsInstances = { workspace.Live }

				local TouchedCharacters = {}
				local LastCharacters = {}
				local Touched = RNS.Heartbeat:Connect(function()
					LastCharacters = {}

					for _, otherPart in workspace:GetPartsInPart(Part, LiveOverlapParameters) do
						local Character = otherPart.Parent
						if not Character:FindFirstChild("Humanoid") or not Character:FindFirstChild("HumanoidRootPart") then continue end
						local Player = Players:GetPlayerFromCharacter(Character)
						if not Player or table.find(TouchedCharacters, Character) or table.find(LastCharacters, Character) or iFramesService:HasiFrame(Character, "M1") then continue end
						table.insert(TouchedCharacters, Character)
						table.insert(LastCharacters, Character)

						local Humanoid: Humanoid = Character.Humanoid
						local HumRP: BasePart = Character.HumanoidRootPart

						if Part:GetAttribute("NoAttack") then
							Character:SetAttribute("NoAttack", not (Character:GetAttribute("NoAttack") or false))
						end

						if Part:GetAttribute("GivesAwakening") then
							Player.AwakeningProgress.Value = 100
						end

						if Part:GetAttribute("ResetsCooldowns") then
							Player.Commands.NoCooldown.Value = true
							Player.Commands.NoCooldown.Value = false
						end

						if Part:GetAttribute("Heals") and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Humanoid.Health > 0 then
							Humanoid.Health = Humanoid.MaxHealth
						end

						if Part:GetAttribute("Bouncy") then
							task.spawn(function()
								Knockback:Knockback(Character, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = -CFrame.lookAt(HumRP.Position, Part.Position).LookVector * 75 })
								RagdollHandler.ragdoll(Humanoid, 1)
							end)
						end

						if Part:GetAttribute("Deadly") then
							Humanoid.Health = 0
						end

						if Part:GetAttribute("CurrentMoves") then
							local CurrentMoves = Http:JSONDecode(Part:GetAttribute("CurrentMoves"))
							local ClearPrevious, RandomMoveset = table.find(CurrentMoves, "Clear Previous"), table.find(CurrentMoves, "Random Moveset")						

							if ClearPrevious then
								table.remove(CurrentMoves, ClearPrevious)

								for _,v in Player.Moveset:GetChildren() do
									v:Destroy()
								end
							end

							if RandomMoveset then
								table.remove(CurrentMoves, RandomMoveset)

								MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"), true)

							else
								MovesetHandlerModule:AddCustomMoveset(Player, CurrentMoves)

							end
						end
					end

					for Index, Character: Model in TouchedCharacters do
						if table.find(LastCharacters, Character) then continue end

						table.remove(TouchedCharacters, Index)
					end
				end)

				Part.Destroying:Once(function()
					Touched:Disconnect()
				end)

			end

		elseif Todo == "Delete" then
			local Part: Part = workspace.Built:FindFirstChild(Parameters.Serial)
			if Part then
				Part:Destroy()
			end

		elseif Todo == "Resize" then
			for _, Table: { Serial: string, Size: Vector3, CFrame: CFrame } in Parameters.List do
				local Part: Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					Part.Size = Table.Size
					Part.CFrame = Table.CFrame
				end
			end

		elseif Todo == "Change Color" then
			for _, Table: { Serial: string } in Parameters.List do
				local Part: Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					Part.Color = Parameters.Color
				end
			end

		elseif Todo == "Change Material" then
			for _, Table: { Serial: string } in Parameters.List do
				local Part: Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					Part.Material = Enum.Material[Parameters.New]
				end
			end

		elseif Todo == "Property Change" then
			for _, Table: { Serial: string } in Parameters.List do
				local Part: Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					local Property: string = Parameters.Property

					if Property == "EmitLight" then
						if Parameters.New == true then
							local PointLight = Instance.new("PointLight")
							PointLight.Parent = Part

						else
							local PointLight: PointLight = Part:FindFirstChildOfClass("PointLight")
							if PointLight then
								PointLight:Destroy()
							end

						end

					elseif Property == "Range" then
						local PointLight: PointLight = Part:FindFirstChildOfClass("PointLight")
						if PointLight then
							PointLight.Range = Parameters.New
						end

					elseif Property == "Brightness" then
						local PointLight: PointLight = Part:FindFirstChildOfClass("PointLight")
						if PointLight then
							PointLight.Brightness = Parameters.New
						end

					elseif Property == "Shadow" then
						Part.CastShadow = Parameters.New

					elseif Property == "Collision" then
						Part.CanCollide = Parameters.New

					elseif Property == "NoAttack" or Property == "GivesAwakening" or Property == "ResetsCooldowns" or Property == "Heals" or Property == "Bouncy" or Property == "Deadly" or Property == "Destructible" or Property == "Fragile" then
						Part:SetAttribute(Property, Parameters.New)

					elseif Property == "TextOutline" then
						local SurfaceGui = Part:FindFirstChild("BuildText")
						if SurfaceGui then
							local TextLabel = SurfaceGui:FindFirstChildOfClass("TextLabel")
							if TextLabel then
								TextLabel.TextStrokeTransparency = Parameters.New == true and 0 or 1
							end
						end

					elseif Property == "Text" then
						local SurfaceGui = Part:FindFirstChild("BuildText")
						if SurfaceGui then
							local TextLabel = SurfaceGui:FindFirstChildOfClass("TextLabel")
							if TextLabel then
								TextLabel.Text = Parameters.New
							end
						end

					elseif Property == "TextTransparency" then
						local SurfaceGui = Part:FindFirstChild("BuildText")
						if SurfaceGui then
							local TextLabel = SurfaceGui:FindFirstChildOfClass("TextLabel")
							if TextLabel then
								TextLabel.TextTransparency = Parameters.New
							end
						end

					elseif Property == "TextColor" then
						local SurfaceGui = Part:FindFirstChild("BuildText")
						if SurfaceGui then
							local TextLabel = SurfaceGui:FindFirstChildOfClass("TextLabel")
							if TextLabel then
								TextLabel.TextColor3 = Parameters.New
							end
						end

					else
						Part[Property] = Parameters.New
					end

					Part:SetAttribute(Property, Parameters.New)
				end
			end

		elseif Todo == "Change Font" then
			for _, Table: { Serial: string } in Parameters.List do
				local Part: Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					local SurfaceGui = Part:FindFirstChild("BuildText")
					if SurfaceGui then
						local TextLabel = SurfaceGui:FindFirstChildOfClass("TextLabel")
						if TextLabel then
							TextLabel.Font = Enum.Font[Parameters.New]
						end
					end

					Part:SetAttribute("TextFont", Parameters.New)
				end
			end

		elseif Todo == "Change Moves" then
			for _, Table: { Serial: string } in Parameters.List do
				local Part = workspace.Built:FindFirstChild(Table.Serial)
				if Part then
					Part:SetAttribute("CurrentMoves", Parameters.New)
				end
			end

		elseif Todo == "Clear" then
			for _, Part: Part in CollectionService:GetTagged("PSBuilt") do
				Part:Destroy()
			end

		elseif Todo:match("Save ") then
			local IsValidSlot, SaveSlot = pcall(function()
				return tonumber(Todo:gsub("Save ", ""), 10)
			end)

			if not IsValidSlot or SaveSlot > shared.playerClasses[Player.UserId].SaveSlots then return end

			local CouldSave = pcall(function()
				BuildsDatastore:UpdateAsync(Player.UserId, function(oldData)
					oldData = oldData or {}


					local BuiltTable = {}

					for _, Part: Part in workspace.Built:GetChildren() do
						BuiltTable[Part.Name] = {
							Class = Part.Name == "Trashcan" and "Trashcan" or Part.ClassName,
							Position = { Part.Position.X, Part.Position.Y, Part.Position.Z },
							Orientation = { Part.Orientation.X, Part.Orientation.Y, Part.Orientation.Z },
							Size = { Part.Size.X, Part.Size.Y, Part.Size.Z },
							Color = { Part.Color.R, Part.Color.G, Part.Color.B },
							Material = Part.Material.Name,
							Transparency = Part.Transparency,
							EmitLight = Part:GetAttribute("EmitLight"),
							Range = Part:GetAttribute("Range") or 8,
							Brightness = Part:GetAttribute("Brightness") or 1,
							CastShadow = Part.CastShadow,
							CanCollide = Part.CanCollide,
							NoAttack = Part:GetAttribute("NoAttack"),
							GivesAwakening = Part:GetAttribute("GivesAwakening"),
							ResetsCooldowns = Part:GetAttribute("ResetsCooldowns"),
							Heals = Part:GetAttribute("Heals"),
							Bouncy = Part:GetAttribute("Bouncy"),
							Deadly = Part:GetAttribute("Deadly"),
							Destructible = Part:GetAttribute("Destructible"),
							Fragile = Part:GetAttribute("Fragile"),
							TextOutline = Part.BuildText.TextLabel.TextStrokeTransparency < 1,
							Text = Part.BuildText.TextLabel.Text,
							TextTransparency = Part.BuildText.TextLabel.TextTransparency,
							TextFont = Part.BuildText.TextLabel.Font.Name,
							TextColor = { Part.BuildText.TextLabel.TextColor3.R, Part.BuildText.TextLabel.TextColor3.G, Part.BuildText.TextLabel.TextColor3.B },
							CurrentMoves = Part:GetAttribute("CurrentMoves")
						}
					end


					oldData[SaveSlot] = BuiltTable

					return oldData
				end)
			end)


			local Message = "The build was saved successfully"
			if not CouldSave then
				Message = "There was an error while saving the build.\nPlease try again later"
			end

			ComSet:FireClient(Player, "SendNotification", {
				Title = "NOTIFICATION", 
				Text = Message, 
				Duration = 5
			})

		elseif Todo:match("Load ") then
			local CouldLoad = pcall(function()
				local IsValidSlot, SaveSlot = pcall(function()
					return tonumber(Todo:gsub("Load ", ""), 10)
				end)

				if not IsValidSlot or SaveSlot > shared.playerClasses[Player.UserId].SaveSlots then return end


				local CouldGetBuild, Builds = pcall(function()
					return BuildsDatastore:GetAsync(Player.UserId)
				end)

				if not CouldGetBuild then return end


				local BuildTable = Builds[SaveSlot]

				if not BuildTable then return end


				for Serial, PartInfo in BuildTable do
					local Part: Part?

					if PartInfo.Class == "Throwable" then
						Part = RS.Resources.Trashcan:Clone()

						Part:AddTag("Throwable")

					else
						Part = Instance.new(PartInfo.Class)

						Part:AddTag("Combeable")

					end


					Part:AddTag("PSBuilt")

					local BuildText = script.Screen.BuildText:Clone()
					BuildText.Parent = Part

					for Name, Value in PartInfo do
						if Name == "Class" or Name == "Range" or Name == "Brightness" then continue end

						if Name == "Position" or Name == "Orientation" or Name == "Size" or Name == "Color" then
							local Constructor = Name == "Color" and Color3.new or Vector3.new
							Value = Constructor(Value[1], Value[2], Value[3])

							Part[Name] = Value

						elseif Name == "Material" then
							Part.Material = Enum.Material[Value]

						elseif Name == "Transparency" then
							Part.Transparency = Value

						elseif Name == "EmitLight" then
							if Value == true then
								local PointLight = Instance.new("PointLight")
								PointLight.Range = PartInfo.Range
								PointLight.Brightness = PartInfo.Brightness
								PointLight.Parent = Part
							end

						elseif Name == "CastShadow" or Name == "CanCollide" then
							Part[Name] = Value

						elseif Name == "TextOutline" then
							BuildText.TextLabel.TextStrokeTransparency = Value == true and 0 or 1

						elseif Name == "Text" then
							BuildText.TextLabel.Text = Value

						elseif Name == "TextTransparency" then
							BuildText.TextLabel.TextTransparency = Value

						elseif Name == "TextFont" then
							BuildText.TextLabel.Font = Enum.Font[Value]

						elseif Name == "TextColor" then
							Value = Color3.new(Value[1], Value[2], Value[3])

							BuildText.TextLabel.TextColor3 = Value

						end

						Part:SetAttribute(Name, Value)
					end

					Part.Anchored = true
					Part.Name = Serial
					Part.Parent = workspace.Built


					local LiveOverlapParameters = OverlapParams.new()
					LiveOverlapParameters.FilterType = Enum.RaycastFilterType.Include
					LiveOverlapParameters.FilterDescendantsInstances = { workspace.Live }

					local TouchedCharacters = {}
					local LastCharacters = {}
					local Touched = RNS.Heartbeat:Connect(function()
						LastCharacters = {}

						for _, otherPart in workspace:GetPartsInPart(Part, LiveOverlapParameters) do
							local Character = otherPart.Parent
							if not Character:FindFirstChild("Humanoid") or not Character:FindFirstChild("HumanoidRootPart") then continue end
							local Player = Players:GetPlayerFromCharacter(Character)
							if not Player or table.find(TouchedCharacters, Character) or table.find(LastCharacters, Character) or iFramesService:HasiFrame(Character, "M1") then continue end
							table.insert(TouchedCharacters, Character)
							table.insert(LastCharacters, Character)

							local Humanoid: Humanoid = Character.Humanoid
							local HumRP: BasePart = Character.HumanoidRootPart

							if Part:GetAttribute("NoAttack") then
								Character:SetAttribute("NoAttack", not (Character:GetAttribute("NoAttack") or false))
							end

							if Part:GetAttribute("GivesAwakening") then
								Player.AwakeningProgress.Value = 100
							end

							if Part:GetAttribute("ResetsCooldowns") then
								Player.Commands.NoCooldown.Value = true
								Player.Commands.NoCooldown.Value = false
							end

							if Part:GetAttribute("Heals") and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Humanoid.Health > 0 then
								Humanoid.Health = Humanoid.MaxHealth
							end

							if Part:GetAttribute("Bouncy") then
								task.spawn(function()
									Knockback:Knockback(Character, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = -CFrame.lookAt(HumRP.Position, Part.Position).LookVector * 75 })
									RagdollHandler.ragdoll(Humanoid, 1)
								end)
							end

							if Part:GetAttribute("Deadly") then
								Humanoid.Health = 0
							end

							if Part:GetAttribute("CurrentMoves") then
								local CurrentMoves = Http:JSONDecode(Part:GetAttribute("CurrentMoves"))
								local ClearPrevious, RandomMoveset = table.find(CurrentMoves, "Clear Previous"), table.find(CurrentMoves, "Random Moveset")						

								if ClearPrevious then
									table.remove(CurrentMoves, ClearPrevious)

									for _,v in Player.Moveset:GetChildren() do
										v:Destroy()
									end
								end

								if RandomMoveset then
									table.remove(CurrentMoves, RandomMoveset)

									MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"), true)

								else
									MovesetHandlerModule:AddCustomMoveset(Player, CurrentMoves)

								end
							end
						end

						for Index, Character: Model in TouchedCharacters do
							if table.find(LastCharacters, Character) then continue end

							table.remove(TouchedCharacters, Index)
						end
					end)

					Part.Destroying:Once(function()
						Touched:Disconnect()
					end)
				end
			end)


			local Message = "The build was load successfully"
			if not CouldLoad then
				Message = "There was an error while loading the build.\nPlease try again later"
			end

			ComSet:FireClient(Player, "SendNotification", {
				Title = "NOTIFICATION",
				Text = Message,
				Duration = 5
			})
		end
	end,
	
	Keypress = function(Player: Player, Parameters: { Key: EnumItem })
		local Character = Player.Character
		if not Character then return end
		local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
		if not Humanoid then return end
		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end


		local Keypressed = Parameters.Key

		if Keypressed == Enum.KeyCode.Q then
			local Direction = Parameters.Direction

			if Direction == "Front" or Direction == "Back" then
				if Direction == "Back" then
					if not Character:HasTag('Ragdolled') and not Character:HasTag("Knockbacked") then
						if (Character:HasTag('DashCD') and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value) or Character:HasTag('CantDash') or Character:HasTag('Stunned') then
							return
						end

					else
						if not Character:HasTag('CantRagdollCancel') and Character:GetAttribute('RagdollCancel') ~= false then
							task.spawn(function()
								RagdollHandler.cancelRagdoll(Humanoid, nil, false, nil, true, true)
								
								ReplicateSet:FireAllClients("Evasive", { Char = Character })
								SoundsModule:PlaySound(CombatSounds.Dashing.Evasive, Character.HumanoidRootPart)
								
								Character:SetAttribute('RagdollCancel', false)
								task.delay(30, function()
									Character:SetAttribute('RagdollCancel', true)
								end)
							end)

						else
							return
						end
					end
					
					local Jantior = Trove.new()
					
					
					Character:AddTag('DashCD')
					task.delay(5,function()
						Character:RemoveTag('DashCD')
					end)
					
					AnimationService:stopAnimation(Character, Animations.Other.Knockback)
					
					for _, Anim in EmotesFolder:GetDescendants() do
						if Anim:IsA("Animation") then
							AnimationService:stopAnimation(Character, Anim)
						end
					end
					
					StunHandler:Stun(Character, 1.017, true, 0, 0, true)
					SoundsModule:PlaySound(CombatSounds.Dashing.BackDash, HumRP)
					SoundsModule:PlaySound(CombatSounds.Dashing["Back First Woosh"], HumRP)
					
					
					task.delay(0.05, function()
						iFramesService:AddBaseiFrames(Character)
						task.delay(0.75, function()
							iFramesService:RemoveAlliFrames(Character)
						end)
						
						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.2))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character
						
						ReplicateSet:FireAllClients("smokeEffect", { time = 0.2, char = Character })
						SoundsModule:PlaySound(CombatSounds.Dashing["Back Second Woosh"], HumRP)
					end)
					
					task.delay(0.5, function()
						ReplicateSet:FireAllClients("smokeEffect", { time = 0.35, char = Character })
						
						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.4))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character
						
						SoundsModule:PlaySound(CombatSounds.Dashing["Back Second Woosh"], HumRP)
					end)
					
					task.delay(1.2, function()
						Jantior:Clean()
					end)
					
					
					local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
					for i, v in pairs(Character:GetChildren()) do
						if v:IsA("BasePart") then
							if table.find(limbNames, v.Name) then
								ReplicateSet:FireAllClients("armTrailEffect", { char = Character, lifeTime = 0.65, limbName = v.Name })
							end
						end
					end
				else
					if Character:HasTag('Stunned') then return end

					local Player = Players:GetPlayerFromCharacter(Character)
					local HumRP : BasePart = Character.HumanoidRootPart
					local Humanoid: Humanoid = Character.Humanoid

					local detectWall = false

					local ray
					local rpars = RaycastParams.new()
					rpars.FilterType = Enum.RaycastFilterType.Include
					rpars.FilterDescendantsInstances = { workspace.Map }


					local WallEnemyCharacter: Model = Character:FindFirstChild("DamagerLog")
					local WallEnemyHumanoid: Humanoid
					local WallEnemyHumRP: BasePart
					if WallEnemyCharacter then
						WallEnemyCharacter = WallEnemyCharacter.Value
						WallEnemyHumanoid = WallEnemyCharacter:FindFirstChild("Humanoid")
						WallEnemyHumRP = WallEnemyCharacter:FindFirstChild("HumanoidRootPart")

						if WallEnemyHumanoid and WallEnemyHumRP then
							local ClientCFrame: CFrame = Parameters.ClientCFrame
							local ClientPosition = ClientCFrame.Position - Vector3.new(0, 1.25, 0)
							local _, YOrientation = ClientCFrame.Rotation:ToOrientation()

							ray = workspace:Raycast(ClientPosition, (CFrame.new(ClientPosition) * CFrame.Angles(0, YOrientation, 0)).LookVector * 11.5, rpars)

							if ray and not ReplicateGet:InvokeClient(Player, "IsPartDestroyed", { Part = ray.Instance }) then
								local Part = ray.Instance
								if Part.Name == "Leaves" then return end

								if Character:FindFirstChild('DamagerLog') and Character.DamagerLog.TimeRemaining.Value > Character.DamagerLog:GetAttribute('CombatStateDuration') - 2 and WallEnemyCharacter:HasTag("Ragdolled") then
									if (WallEnemyHumRP.Position - Character.PrimaryPart.Position).Magnitude <= 16.5 then
										detectWall = true
										
									end
									
								end
							end
						end
					end


					if detectWall == true and not Character:HasTag('WallcomboCD') then
						local EnemyPlayer = Players:GetPlayerFromCharacter(WallEnemyCharacter)

						local playerClass = shared.playerClasses[Player.UserId]
						if playerClass then
							playerClass.TitlesProgress.WallCombo += 1
							Player:SetAttribute("WallComboProgress", playerClass.TitlesProgress.WallCombo)
						end
						
						Character:AddTag('WallcomboCD')
						task.delay(10, function()
							Character:RemoveTag('WallcomboCD')
						end)


						AnimationService:stopAll(Character)
						AnimationService:stopAll(WallEnemyCharacter)
						if WallEnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(WallEnemyHumanoid, nil, false, nil, false, true)
						end


						WallEnemyCharacter:AddTag('CantRotate')

						Character:AddTag('CantRotate')


						iFramesService:AddAlliFrames(Character)
						AnimationService:stopAll(WallEnemyCharacter, 0)
						iFramesService:AddAlliFrames(WallEnemyCharacter)
						
						local raycast_position = ray.Position
						local raycast_normal = Vector3.new(ray.Normal.X, 0, ray.Normal.Z)
						local offsetPosition = Vector3.new(raycast_position.X, HumRP.Position.Y, raycast_position.Z) + (raycast_normal * 4.5)

						Humanoid.AutoRotate = false
						HumRP.Anchored = true
						WallEnemyHumanoid.AutoRotate = false
						HumRP.CFrame = CFrame.new(offsetPosition, offsetPosition - raycast_normal)

						local Wallcmb = Wallcombos[Player:GetAttribute("Moveset")] or require(SvModules.WallCombos).Default
						Wallcmb(Character, WallEnemyCharacter, WeldSystem.new(HumRP, WallEnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 10):Start(nil, Player or EnemyPlayer), ray)
					else
						if not Character:HasTag('Ragdolled') and not Character:HasTag("Knockbacked") then
							if (Character:HasTag('DashCD') and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value) or Character:HasTag('CantDash') or Character:HasTag('Stunned') then
								return
							end
						end
						
						Character:AddTag('CantDash')
						Character:AddTag('DashCD')
						task.delay(5,function()
							Character:RemoveTag('CantDash')
							Character:RemoveTag('DashCD')
						end)

						for _,v in HumRP:GetChildren() do
							if v:IsA("LinearVelocity") or v:IsA("BodyVelocity") then
								v:Destroy()
							end
						end
						
						
						local dashVelocity = Instance.new("BodyVelocity")
						dashVelocity.Name = "FrontDashVelocity"
						dashVelocity.MaxForce = Vector3.new(40000, 0, 40000)
						
						
						
						local SmallDebris = shared.cfolder({ Name = "SmallDebris" }, 1)
						CollectionService:AddTag(SmallDebris, "SmallDebris")
						SmallDebris.Parent = Character
						
						task.delay(0.1, function()
							ReplicateSet:FireAllClients("Ring", {
								FirstProps = {
									Size = Vector3.new(2.589, 0.896, 2.589),
									Transparency = 0.25
								},

								CF = HumRP.CFrame * CFrame.Angles(1.5707963267948966, 0, 0),

								TN_Info = {
									Time = 0.3,
									Style = 'Quad',
									Direction = 'Out'
								},

								FinalProps = {
									Size = Vector3.new(9.874, 0.1, 9.874),
									Transparency = 1
								}
							})
						end)


						local DashStart = CombatAnims.Dashes.DashFront
						local AnimTrack: AnimationTrack = AnimationService:getAnimationTrack(Character, DashStart)
						local HitEvents = {}

						local DetectedEnemy
						local Hit = false
						local Ended = false
						local Time = time()
						local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
						local NearEnemys = {}
						
						
						local Jantior = Trove.new()

						local dashingForward = Jantior:Add(shared.cfolder({ Name = "dashingForward" }))
						dashingForward.Parent = Character
						

						local function endDash()
							Ended = true
							
							SoundsModule:PlaySound(CombatSounds.Dashing.FrontDashSwing, HumRP)
							
							Character:SetAttribute("Dashing", false)
							
							dashVelocity:Destroy()


							AnimTrack:AdjustSpeed(1)
							
							shared.safeDestroy(SmallDebris)
							
							if Jantior then
								Jantior:Destroy()
								Jantior = nil
							end
						end

						for _, CloseEnemy in workspace.Live:GetChildren() do
							if CloseEnemy == Character then continue end

							local CloseHumRP: BasePart = CloseEnemy:FindFirstChild('HumanoidRootPart')
							if CloseHumRP then
								if (CloseHumRP.Position - HumRP.Position).Magnitude < 15 then
									table.insert(NearEnemys, CloseEnemy)
								end
							end
						end
						

						HitEvents['hit'] = AnimTrack:GetMarkerReachedSignal('hit'):Once(function()
							ReplicateSet:FireAllClients("destroyAmbient", {
								Velocity = HumRP.CFrame.LookVector,
								Multiplier = { 15, 50 },
								Size = Vector3.one * 8,
								CFrame = HumRP,
								Offset = CFrame.new(0, 1, -4),
								Voxels = true
							})
							ReplicateSet:FireAllClients("DashMiss", { PrimaryPart = HumRP, YAngle = math.pi })

							local Hitbox = ReplicatedHitboxes.new(Player)
							Hitbox.Size = Vector3.new(8, 8, 8)
							Hitbox.Offset = CFrame.new(0, 1, -4)
							Hitbox.Instance = HumRP
							Hitbox.Ignore = { Character }
							Hitbox.destroyAfterOnce = true
							Hitbox.onTouch = function(EnemyCharacter)
								local EnemyHumRP = EnemyCharacter.HumanoidRootPart
								local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
								local Ragdolled = EnemyCharacter:HasTag('Ragdolled')
								local inAir = EnemyCharacter:FindFirstChild("inAir") or (EnemyCharacter:GetAttribute("TouchedGround") and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25)

								if EnemyCharacter ~= DetectedEnemy then
									if iFramesService:HasiFrame(EnemyCharacter, 'M1') or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or (Ragdolled and not inAir) then return end
								end


								local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, 1, Assets.Animations.Combat.Hits[tostring(math.random(1, 3))], true, true, true)
								if HitInfo.Blocked == true then
									SoundsModule:PlaySound(CombatSounds.Blocking.Hits:GetChildren()[math.random(1, #CombatSounds.Blocking.Hits:GetChildren())], EnemyHumRP)
									
									return
										
								elseif HitInfo.Countered == true then
									return
								
								end

								if not Hit then
									Hit = true

									ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 2 })
								end

								ReplicateSet:FireAllClients('DashHit', { Char = Character, EChar = EnemyCharacter, RootPart = EnemyHumRP, LookVector = HumRP.CFrame.LookVector })
								SoundsModule:PlaySound(CombatSounds.Dashing.FrontDashHit, EnemyHumRP)
								
								
								if dashingForward then
									Debris:AddItem(dashingForward, 0.1)
								end
								
								
								if Ragdolled or table.find(NearEnemys, EnemyCharacter) then
									if Ragdolled then
										RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
									end
									
									
									EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
									
									local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
									local lookVector = Character.HumanoidRootPart.CFrame.LookVector
									
									local dotProduct = lookVector:Dot(selfToOtherChar)
									if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
										dotProduct = 1
									end
									
									local at = Character.HumanoidRootPart.Position
									local forward = Character.HumanoidRootPart.CFrame.LookVector
									local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))
									
									
									if EnemyHumanoid ~= Enum.Material.Air or not inAir then
										require(SvModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
											LookVector = lookposition.LookVector,
											LookForce = 58.5,
											LookFinalForce = 55,
											LookAt = lookposition,
											DestroyRagdoll = true,
											GroundStunTime = 0.95,
											Escapable = false,
											FallingDetectDelay = 0.2,
											Dot = dotProduct,
											DotParams = {0.4, 1},
											canHitWall = true
										}, Character)
									else
										require(SvModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
											LookVector = lookposition.LookVector,
											LookForce = 58.5,
											LookFinalForce = 55,
											LookAt = lookposition,
											DestroyRagdoll = true,
											GroundStunTime = 0.95,
											Escapable = false,
											FallingDetectDelay = 0.2,
											Dot = dotProduct,
											DotParams = {0.4, 1},
											canHitWall = true
										}, Character)
									end
									
									Knockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
									
									ReplicateSet:FireAllClients("Ring", {
										FirstProps = {
											Size = Vector3.new(2.589, 0.896, 2.589),
											Transparency = 0.25
										},
										
										CF = EnemyHumRP.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(math.rad(90), 0, 0),
										
										TN_Info = {
											Time = 0.3,
											Style = 'Quad',
											Direction = 'Out'
										},

										FinalProps = {
											Size = Vector3.new(9.874, 0.1, 9.874),
											Transparency = 1
										}
									})
								end
							end


							Hitbox:Once()
							
							if Hit then
								task.delay(0.05, function()
									StunHandler:Unstun(Character, Stun)
								end)
							end
						end)
						
						HitEvents['freeze'] = AnimTrack:GetMarkerReachedSignal('freeze'):Once(function()
							AnimTrack:AdjustSpeed(0)
						end)
						
						HitEvents['jump'] = AnimTrack:GetMarkerReachedSignal('jump'):Once(function()
							dashVelocity.Parent = HumRP
							Debris:AddItem(dashVelocity, 0.85)
							
							SoundsModule:PlaySound(Assets.Sounds.Combat.Dashing.FrontDash, HumRP)
							
							local DetectHitbox = ReplicatedHitboxes.new(Player)
							DetectHitbox.Size = Vector3.new(8, 8, 8)
							DetectHitbox.Offset = CFrame.new(0, 1, -4)
							DetectHitbox.Instance = HumRP
							DetectHitbox.Ignore = { Character }
							DetectHitbox.onTouch = function(EnemyCharacter)
								local EnemyHumRP = EnemyCharacter.HumanoidRootPart
								local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
								local Ragdolled = EnemyCharacter:HasTag('Ragdolled')
								local inAir = EnemyCharacter:FindFirstChild("inAir") or (EnemyCharacter:GetAttribute("TouchedGround") and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25)

								if iFramesService:HasiFrame(EnemyCharacter, "M1") == true or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or (Ragdolled and not inAir) then return end

								if not Ended then
									if Character:GetAttribute("Combo") == 3 then
										shared.safeDestroy(dashVelocity)
										
										Character:SetAttribute("Combo", 0)
									end
									
									if time() - Time < 0.315 then
										return
									end
									
									if DetectHitbox ~= nil then
										DetectHitbox:Destroy()
										DetectHitbox = nil
									end

									DetectedEnemy = EnemyCharacter

									endDash()
								end
							end

							DetectHitbox:Start(0.7, true)
						end)

						AnimTrack.Stopped:Once(function()
							for _,v in HitEvents do
								v:Disconnect()
							end

							StunHandler:Unstun(Character, Stun)
						end)


						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, DashStart)

						Character:SetAttribute("Dashing", true)
						
						if Character:HasTag('HasKnife') then
							ReplicateSet:FireAllClients("CharaDash", { Stage = "Start",  Char = Character })
							
						elseif Player:GetAttribute("Moveset") == "Hero Hunter" or Player:GetAttribute("Moveset") == "Monster Form" then
							local Effect = Player:GetAttribute("Moveset") == "Monster Form" and "RedPalm" or "waterpalm"
							
							ReplicateSet:FireAllClients(Effect, { Char = Character, Time = 0.7, Limb = "Right Arm" })
						end
						ReplicateSet:FireAllClients("DashMiss", { PrimaryPart = HumRP })
						
						
						task.delay(0.55, function()
							Character:SetAttribute("Dashing", false)
						end)
						
						task.delay(0.7, function()
							HumRP.AssemblyLinearVelocity = Vector3.new()
							
							if not Ended then
								endDash()
							end
						end)
						
						
						local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
						for i, v in Character:GetChildren() do
							if v:IsA("BasePart") then
								if table.find(limbNames, v.Name) then
									ReplicateSet:FireAllClients("armTrailEffect", { char = Character, lifeTime = 0.875, limbName = v.Name })
								end
							end
						end
					end
					
				end

			elseif Direction == "Right" or Direction == "Left" then
				if not Character:HasTag('Ragdolled') and not Character:HasTag("Knockbacked") then
					if (Character:HasTag('SideDashCD') and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value) or Character:HasTag('CantSideDash') or Character:HasTag('Stunned') then
						return
					end
					
				else
					if not Character:HasTag('CantRagdollCancel') and Character:GetAttribute('RagdollCancel') ~= false then
						task.spawn(function()
							RagdollHandler.cancelRagdoll(Humanoid, nil, false, nil, true, true)
							
							ReplicateSet:FireAllClients("Evasive", { Char = Character })
							SoundsModule:PlaySound(CombatSounds.Dashing.Evasive, Character.HumanoidRootPart)
							
							Character:SetAttribute("RagdollCancel", false)
							task.delay(30, function()
								Character:SetAttribute("RagdollCancel", true)
							end)
						end)
						
					else
						return
					end
				end
				
				local Jantior = Trove.new()
				
				
				AnimationService:stopAnimation(Character, Animations.Other.Knockback)
				
				for _, Anim in EmotesFolder:GetDescendants() do
					if Anim:IsA("Animation") then
						AnimationService:stopAnimation(Character, Anim)
					end
				end


				SoundsModule:PlaySound(CombatSounds.Dashing.SideDash, HumRP)
				SoundsModule:PlaySound(CombatSounds.Dashing[Direction .."Woosh"], HumRP)
				
				
				if Character:GetAttribute("TpDash") then
					Character:SetAttribute("Invisible", true)
					task.delay(0.45, function()
						Character:SetAttribute("Invisible", false)
					end)
				else
					task.spawn(function()
						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.25))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character
						
						ReplicateSet:FireAllClients("smokeEffect", { time = 0.3, char = Character })
					end)
					
					task.delay(0.7, function()
						Jantior:Clean()
					end)
				end


				Character:AddTag('SideDashCD')
				task.delay(2,function()
					Character:RemoveTag('SideDashCD')
				end)

				Character:AddTag('CantDash')
				task.delay(.6, function()
					Character:RemoveTag('CantDash')
				end)
			end
		end
	end,
	
	DeleteBV = function(Player: Player, Parameters: { any })
		local BodyVelocity: BodyVelocity = Parameters.BV
		if BodyVelocity then
			BodyVelocity:Destroy()
		end
	end,

	ApplyOutfit = function(Player: Player, Params: { any })
		Params.Hum:ApplyDescription(Players:GetHumanoidDescriptionFromOutfitId(Params.Id))
	end,
	
	SaveButtonsPos = function(Player: Player, Positions)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end

		playerClass.ButtonsInfo.Dash.ScaleX  = Positions.Dash.ScaleX
		playerClass.ButtonsInfo.Dash.OffsetX = Positions.Dash.OffsetX
		playerClass.ButtonsInfo.Dash.ScaleY  = Positions.Dash.ScaleY
		playerClass.ButtonsInfo.Dash.OffsetY = Positions.Dash.OffsetY

		playerClass.ButtonsInfo.M1.ScaleX  = Positions.M1.ScaleX
		playerClass.ButtonsInfo.M1.OffsetX = Positions.M1.OffsetX
		playerClass.ButtonsInfo.M1.ScaleY  = Positions.M1.ScaleY
		playerClass.ButtonsInfo.M1.OffsetY = Positions.M1.OffsetY

		playerClass.ButtonsInfo.Block.ScaleX  = Positions.Block.ScaleX
		playerClass.ButtonsInfo.Block.OffsetX = Positions.Block.OffsetX
		playerClass.ButtonsInfo.Block.ScaleY  = Positions.Block.ScaleY
		playerClass.ButtonsInfo.Block.OffsetY = Positions.Block.OffsetY

		playerClass.ButtonsInfo.Shiftlock.ScaleX  = Positions.Shiftlock.ScaleX
		playerClass.ButtonsInfo.Shiftlock.OffsetX = Positions.Shiftlock.OffsetX
		playerClass.ButtonsInfo.Shiftlock.ScaleY  = Positions.Shiftlock.ScaleY
		playerClass.ButtonsInfo.Shiftlock.OffsetY = Positions.Shiftlock.OffsetY
	end,

	SaveButtonSize = function(Player: Player, Parameters)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end

		playerClass.ButtonsInfo[Parameters.Button].SizeMultiplier = Parameters.Size
	end,
	
	ownsGamepass = function(_, Params)
		return ownsGamepass(Params.userId, Params.passName)
	end,
	
	destroyAmbient = function(_, Params)
		local Container: Model = Params.Container
		local State: boolean = Params.State
		
		if not Container then return end
		
		if State == true then
			Container:AddTag('Destroyed')
			
			for _, Part: Part in Container:GetDescendants() do
				if Part:IsA('Part') or Part:IsA('MeshPart') then
					Part.Transparency = 1
					Part.CanCollide = false
					Part.CanQuery = false
				end
			end
			
		else
			Container:RemoveTag('Destroyed')
			
			for _, Part: Part in Container:GetDescendants() do
				if Part:IsA('Part') or Part:IsA('MeshPart') then
					Part.Transparency = 0
					Part.CanCollide = true
					Part.CanQuery = true
				end
			end
		end
	end,
	
	replicationLoaded = function(Player)
		Remotes.Replicate.Set:FireClient(Player, 'preloadanims', AnimationsTable)
	end,
	
	SetAwkOutfit = function(Player: Player, Params: { any })
		if not ownsGamepass(Player.UserId, "VIP") then return end
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end
		
		for _,v in Params.Movesets do
			playerClass.AwakeningOutfits[v] = Params.OutfitId
		end
	end,
	
	IsPSOwner = function(Player: Player)
		return (Player.UserId == game.PrivateServerOwnerId and ownsGamepass(Player.UserId, "VIP")) or RNS:IsStudio() or isAdmin(Player) == true
	end,
	
	ResetCharacter = function(Player: Player)
		if not Player.Character or not Player.Character.Parent or Player.Commands.NoReset.Value == true or workspace.Configuration.NoReset.Value == true then return end
		
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		
		local DamagedLog: ObjectValue = Character:FindFirstChild('DamagedLog')
		local DamagerLog: ObjectValue = Character:FindFirstChild('DamagerLog')
		
		if Character:HasTag('Stunned') then
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU CAN'T RESET YOUR CHARACTER RIGHT NOW"; })
			
		elseif (DamagedLog and not DamagedLog:HasTag("Dummy")) or (DamagerLog and not DamagerLog:HasTag("Dummy")) then
			local TimeUntilReset = 0
			if DamagedLog then
				TimeUntilReset = DamagedLog.TimeRemaining.Value
			end

			if DamagerLog then
				if DamagerLog.TimeRemaining.Value > TimeUntilReset then
					TimeUntilReset = DamagerLog.TimeRemaining.Value
				end
			end

			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = 'WAIT '..tostring(math.round(TimeUntilReset))..' SECONDS BEFORE RESETTING'; })
			
		else
			Humanoid.Health = 0
		end
	end,
	
	GetCF = function(Player: Player, Params: { any })
		if Params.Obj then
			return Params.Obj.CFrame
		else
			return nil
		end
	end,
	
	Ban = function(Player: Player)
		Players:BanAsync({ UserIds = { Player.UserId }; ApplyToUniverse = true; Duration = -1; DisplayReason = 'You have been banned for using exploits.'; PrivateReason = 'Exploits'; ExcludeAltAccounts = false; })
	end,
	
	CheckAdminChar = function(Player: Player)
		local userId = Player.UserId
		
		if isAdmin(Player) == true or hasAccessToAdminMovesets(Player) == true then
			return true
		else
			return false
		end
	end,
	
	Kick = function(Player: Player, Params: { any })
		Player:Kick(Params.Msg)
	end,
	
	SetConfig = function(Player: Player, Params)
		Player.Configuration[Params.CN].Value = Params.V
	end,
	
	SetMoveset = function(Player: Player, MovesetName)
		if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") and workspace:GetAttribute('Started') == true then return end
		if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
			if MovesetName == "The Frozen Soul" or MovesetName == "Finger Eater" then
				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU CAN'T USE THIS MOVESETS IN DUELS."; })
				
				return
			end
		end
		
		if MovesetName == Player:GetAttribute("Moveset") then 
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU ARE ALREADY PLAYING THIS CHARACTER."; })
			
			return
		end


		local Character = Player.Character
		if not Character or Character:HasTag("Stunned") then
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU CAN'T CHANGE MOVESETS RIGHT NOW."; })

			return
		end


		local MovesetInfo = Movesets[MovesetName]
		if not MovesetInfo then return end


		local MovesetFolder = SvSt.Movesets:FindFirstChild(MovesetName)
		if not MovesetFolder then return end

		if Player:HasTag('MovesetCD') then
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "CAN'T EQUIP MOVESET, YOU ARE ON COOLDOWN."; })

			return
		end


		local userId = Player.UserId

		if
			MovesetInfo.isAdmin == true and
			not isAdmin(Player) and
			not hasAccessToAdminMovesets(Player)
		then
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU CAN'T USE THIS MOVESET BECAUSE IT'S ADMIN-ONLY."; })

			return
		end
		
		if
			MovesetInfo.isQuest == true and 
			not shared.playerClasses[Player.UserId].CompletedQuest
		then
			local message = "YOU MUST COMPLETE THE QUEST TO USE THIS MOVESET.\n" ..
				"You need a 30 killstreak."
			
			ComSet:FireClient(Player, "SendNotification", { Title = "THE COLDEST DETERMINATION"; Text = message; Time = 5; })
			return
		end

		if
			MovesetInfo.isEA == true and 
			not ownsGamepass(Player, "VIP")
		then
			MarketplaceService:PromptGamePassPurchase(Player, Passes.VIP) 
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "YOU MUST BUY THE EARLY ACCESS GAMEPASS TO USE THIS MOVESET."; })

			return
		end


		local DamagerLog: ObjectValue = Player.Character:FindFirstChild('DamagerLog')
		local DamagedLog: ObjectValue = Player.Character:FindFirstChild('DamagedLog')

		if (DamagerLog and not DamagerLog.Value:FindFirstChild("Dummy")) or (DamagedLog and not DamagedLog.Value:FindFirstChild("Dummy")) then
			local DamagerTime, DamagedTime = 0, 0

			if DamagerLog then
				DamagerTime = math.round(DamagerLog.TimeRemaining.Value)
			end

			if DamagedLog then
				DamagedTime = math.round(DamagedLog.TimeRemaining.Value)
			end


			local HighestTime = math.max(DamagerTime, DamagedTime)


			if HighestTime > 0 then
				ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = "CAN'T CHANGE MOVESETS RIGHT NOW, WAIT " .. HighestTime .. " SECONDS."; })


				return
			end
			
			
		end


		if MovesetName == 'KJ' then
			ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION'; Text = 'Character based on KJ\'s Final Ride & KJ Kills Day \n Credits to Kilojoule & Stealth'; })
			
		end
		
		Player:AddTag('MovesetCD')
		task.delay(2, function()
			Player:RemoveTag('MovesetCD')
		end)

		Player.AwakeningProgress.Value = 0

		Player.Configuration.Moveset.Value = MovesetName
		Player:SetAttribute("Moveset", MovesetName)
		
		Player:LoadCharacter()
	end,

	BuyEmote = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		
		playerClass.TitlesProgress.Emotes += 1
		Player:SetAttribute("EmotesProgress", playerClass.TitlesProgress.Emotes)

		return true
	end,
	
	BuyVIP = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		local CurrentGold = playerClass.Gold

		if CurrentGold < 6000 or ownsGamepass(Player.UserId, "VIP") then
			if ownsGamepass(Player.UserId, "VIP") then
				ComSet:FireClient(Player, "SendNotification", { Text = "You already own VIP!" })
			elseif CurrentGold < 6000 then
				ComSet:FireClient(Player, "SendNotification", { Text = "You don't have enough Gold!" })
				
				MarketplaceService:PromptGamePassPurchase(Player, Passes.VIP)
			end
			
			return
		end
		playerClass.Gold = CurrentGold - 6000
		Player:SetAttribute("Gold", playerClass.Gold)

		ComSet:FireClient(Player, "SendNotification", { Text = "Unlocked VIP!" })
		if Passes["VIP"] and playerClass.OwnedPasses["VIP"] ~= true then
			playerClass.OwnedPasses["VIP"] = true
		end
		
		Player:SetAttribute("HasVIP", true)
		
		
		TitlesRemote:FireClient(Player, "UnlockTitle", "VIP")
		ComSet:FireClient(Player, 'AddEmoteSlots')
		ComSet:FireClient(Player, 'AddSecondPage')
		ComSet:FireClient(Player, 'PS+')
		
		
		table.insert(playerClass.OwnedTitles, "VIP")
		table.insert(playerClass.OwnedCosmetics, "Custom Cape")
		
		return true
	end,
	
	UnlockQuestMoveset = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		local CurrentGold = playerClass.Gold
		local UnlockingPrice = 3500
		
		if CurrentGold < UnlockingPrice or playerClass.CompletedQuest == true then
			if playerClass.CompletedQuest == true then
				ComSet:FireClient(Player, "SendNotification", { Text = "You already own the Moveset" })
				
			elseif CurrentGold < UnlockingPrice then
				ComSet:FireClient(Player, "SendNotification", { Text = "You don't have enough Gold!" })
			end
			
			return
		end
		
		playerClass.Gold = CurrentGold - UnlockingPrice
		Player:SetAttribute("Gold", playerClass.Gold)
		
		if playerClass.CompletedQuest ~= true then
			playerClass.CompletedQuest = true
			
			ComSet:FireClient(Player, "SendNotification", { Text = "Unlocked The Frozen Soul!" })
		end
		
		return true
	end,

	PlayEmote = function(Player: Player, AnimationName)
		local Character = Player.Character

		if Character:HasTag("Stunned") or not Character:FindFirstChild("HumanoidRootPart") or not table.find(shared.playerClasses[Player.UserId].OwnedEmotes, AnimationName) then return end

		local Humanoid: Humanoid = Character.Humanoid
		local Anim: Animation = EmotesFolder[AnimationName]

		AnimationService:stopAll(Character, 0)
		
		
		local Jantior = Trove.new()
		
		local Emoting = Jantior:Add(shared.cfolder({ Name = "Emoting" }))
		Emoting.Parent = Character
		
		
		if require(SvModules.Emotes)[AnimationName] ~= nil then
			require(SvModules.Emotes)[AnimationName](Player, Anim)
		else
			local Track: AnimationTrack = AnimationService:getAnimationTrack(Character, Anim)

			AnimationService:playAnimation(Character, Anim)
			Character:SetAttribute('DefaultRunSpeed', Anim:GetAttribute('WalkSpeed') or 0)
			Character:SetAttribute('DefaultWalkSpeed', Anim:GetAttribute('WalkSpeed') or 0)
			Character:SetAttribute('DefaultJumpPower', Anim:GetAttribute('JumpPower') or 0)

			Humanoid.WalkSpeed = Anim:GetAttribute('WalkSpeed') or 0
			Humanoid.JumpPower = Anim:GetAttribute('JumpPower') or 0
			if Anim:HasTag('NAR') then
				Character:AddTag("CantRotate")
			end


			local EmoteSound = Sounds.Emotes:FindFirstChild(Anim.Name)
			if EmoteSound then
				EmoteSound = SoundsModule:PlaySound(EmoteSound, Character.PrimaryPart)
			end

			local c
			c = Track.Stopped:Connect(function()
				if Jantior then
					Jantior:Destroy()
					Jantior = nil
				end
				c:Disconnect()

				if not Character:HasTag("Stunned") then
					Character:SetAttribute('DefaultRunSpeed', 25)
					Character:SetAttribute('DefaultWalkSpeed', 16)
					Character:SetAttribute('DefaultJumpPower', 50)
				end

				Character:RemoveTag("CantRotate")

				if EmoteSound then
					EmoteSound:Destroy()
				end
			end)
		end
	end,
	
	JoinServer = function(Player: Player, Parameters: { Type: string })
		local ServerType = Parameters.Type

		if ServerType == "Duels" then
			TpS:Teleport(workspace:GetAttribute("DuelsHubPlaceId"), Player)
			
		elseif ServerType == "Normal" then
			TpS:Teleport(workspace:GetAttribute("NormalServerPlaceId"), Player)
		end
	end,
	
	StopEmote = function(Player: Player)
		local Character = Player.Character
		if not Character then return end
		
		for _, Anim in EmotesFolder:GetDescendants() do
			if Anim:IsA("Animation") then
				AnimationService:stopAnimation(Character, Anim)
			end
		end
	end,
	
	SetKillSounds = function(Player: Player, Parameters: { string })
		if ownsGamepass(Player.UserId, "VIP") ~= true then return end
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end

		local KillSoundId: string = string.match(Parameters.Kill, "%d+")
		local DeathSoundId: string = string.match(Parameters.Death, "%d+")

		if KillSoundId then
			KillSoundId = tonumber(KillSoundId)

			playerClass.killSound = KillSoundId
			Player:SetAttribute("killSound", KillSoundId)

		else
			Player:SetAttribute("killSound", nil)
		end

		if DeathSoundId then
			DeathSoundId = tonumber(DeathSoundId)
			
			playerClass.deathSound = DeathSoundId
			Player:SetAttribute("deathSound", DeathSoundId)
			
		else
			Player:SetAttribute("deathSound", nil)
		end
	end,
	
	UpdateCape = function(Player: Player, Parameters: { any })
		local Character = Player.Character
		if not Character then return end
		if Parameters.Destroy then Player:SetAttribute("CustomizeVIPCape", nil) return end
		
		
		local success, err = pcall(function()
			local saveData = { 
				Color = {
					Parameters.Color.R, 
					Parameters.Color.G, 
					Parameters.Color.B 
				},
				
				Value = Parameters.Value,
				Decal = Parameters.Decal, 
				OldData = Parameters.OldData 
			}
			
			CapeStore:SetAsync("Cape_" .. Player.UserId, saveData)
			
			
			if Character:FindFirstChild("Custom Cape") then
				local success, data = pcall(function()
					return CapeStore:GetAsync("Cape_" .. Player.UserId)
				end)
				

				if success and data then
					Player:SetAttribute("CustomizeVIPCape", nil)
					
					
					local AccessoryClone = Character:FindFirstChild("Custom Cape")
					local Image = AccessoryClone["Plane.002"].Decal
					local Color = AccessoryClone["Plane.002"].Color
					

					if data.Decal then
						local DecalId = tonumber(data.Decal)
						
						if DecalId then
							local IsFound, Asset = pcall(function()
								return game:GetService("InsertService"):LoadAsset(DecalId)
							end)
							
							
							if IsFound and Asset then
								local FoundDecal = Asset:FindFirstChildWhichIsA("Decal", true)
								
								if FoundDecal then
									Image.Texture = FoundDecal.Texture
								else
									Image.Texture = "rbxassetid://" .. DecalId
								end
							else
								Image.Texture = "rbxassetid://" .. DecalId
							end
						else
							Image.Texture = tostring(data.Decal)
						end
					end
					

					if data.Color then
						Color = Color3.new(data.Color[1], data.Color[2], data.Color[3])
						AccessoryClone["Plane.002"].Color = Color
					end

					if data.Value then
						AccessoryClone:SetAttribute("Value", data.Value)
					end
					
					
					AccessoryClone.Parent = Character
				end
			end
		end)
		
		if not success then
			warn("Failed to save cape data for player "..Player.Name..": "..tostring(err))
		end
	end,
	
	UpdateSettings = function(Player: Player, Parameters: { any })
		local SettingName = rawget(Parameters, "SettingName")
		local Value = rawget(Parameters, "Value")
		
		if SettingName == "CustomizeVIPCape" then
			Player:SetAttribute(SettingName, not Value)
			
		elseif SettingName == "CustomizeKillSound" then
			Player:SetAttribute(SettingName, not Value)
			
		elseif SettingName == "CustomizeAwakeningOutfit" then
			Player:SetAttribute(SettingName, not Value)
			
		elseif SettingName == "Changelogs" then
			Player:SetAttribute(SettingName, not Value)
			
		else
			Player:SetAttribute(SettingName, not Value)
		end
	end,
	
	GetKillsForEmote = function(Player: Player)
		return shared.playerClasses[Player.UserId].KillsForEmote
	end,
	
	SpinEmote = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end
		
		if playerClass.KillsForEmote ~= 0 then return false end
		playerClass.KillsForEmote = 50

		SpinEmoteFunc(Player)

		Remotes.Emotes.Set:FireClient(Player, 'UpdateOwnedEmotes', { OwnedEmotes = playerClass.OwnedEmotes })
		
		return true
	end,

	GetOwnedEmotes = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then
			repeat 
				task.wait()
			until playerClass ~= nil
		end

		return playerClass.OwnedEmotes
	end,

	SetEmote = function(Player: Player, Params)
		local playerClass = shared.playerClasses[Player.UserId]
		if not table.find(playerClass.OwnedEmotes, Params.EmoteName) then return false end

		if Params.Page == 'Emotes' then
			Player.Emotes[Params.Slot].Value = Params.EmoteName
		else
			Player.Emotes2[Params.Slot].Value = Params.EmoteName
		end

		return true
	end,
	
	CloseLog = function(Player: Player)
		local playerClass = shared.playerClasses[Player.UserId]
		if not playerClass then return end
		
		if playerClass.Update_2_SawLog ~= true then
			playerClass.Update_2_SawLog = true
		end
		
		if Player.PlayerGui:FindFirstChild("Changelogs") then
			Player.PlayerGui.Changelogs:Destroy()
		end
	end,
}



local function AddStarterPlayer(Player: Player)
	if not Player then return end

	local userId = Player.UserId
	local playerClass = shared.playerClasses[userId]


	local ReceivedGifts = {}

	for Index, Info in playerClass.PendingGifts do
		table.insert(ReceivedGifts, Info[2])

		local gamePassName = Info[2]

		if Passes[gamePassName] and playerClass.OwnedPasses[gamePassName] ~= true then
			playerClass.OwnedPasses[gamePassName] = true
		end
		
		if gamePassName == "VIP" then
			Player:SetAttribute("HasVIP", true)


			TitlesRemote:FireClient(Player, "UnlockTitle", "VIP")
			ComSet:FireClient(Player, 'AddEmoteSlots')
			ComSet:FireClient(Player, 'AddSecondPage')
			ComSet:FireClient(Player, 'PS+')


			table.insert(playerClass.OwnedTitles, "VIP")
			table.insert(playerClass.OwnedCosmetics, "Custom Cape")
			
		elseif gamePassName == "Emote Page" then
			playerClass.EmotePages += 1

		elseif gamePassName == "500 Gold" then
			playerClass.Gold += 500

		elseif gamePassName == "1,000 Gold" then
			playerClass.Gold += 1000

		elseif gamePassName == "2,500 Gold" then
			playerClass.Gold += 2500

		elseif gamePassName == "5,000 Gold" then
			playerClass.Gold += 5000
			
		end
		
		ComSet:FireClient(Player, 'SendNotification', { Title = 'NOTIFICATION', Text = "Notify", "@" .. Info[1] .. " has gifted you \"" .. gamePassName .. "\"!" })
	end

	playerClass.ReceivedGifts = ReceivedGifts
	playerClass.PendingGifts = {}
	
	
	task.wait()
	
	
	for _, Object in StarterPlayerFolder:GetChildren() do
		Object:Clone().Parent = Player
	end
	

	Player.Chatted:Connect(function(msg)
		ChatCommands(Player, msg)
	end)
	
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		if not playerClass.Rank1v1 then
			playerClass.Rank1v1 = 0
		end
		
		if not playerClass.Rank2v2 then
			playerClass.Rank2v2 = 0
		end
	end
	
	
	local HasVIP = ownsGamepass(userId, "VIP")
	Player:SetAttribute("HasVIP", HasVIP)
	
	if HasVIP then
		table.insert(playerClass.OwnedTitles, "VIP")
		table.insert(playerClass.OwnedCosmetics, "Custom Cape")
	end
	
	
	task.spawn(function()
		if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") or game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
			local SoloRank: NumberValue = Player.leaderstats.Duels['Solo Rank']
			local DuoRank: NumberValue = Player.leaderstats.Duels['Duo Rank']
			local TotalKills: NumberValue = Player.leaderstats['Total Kills']
			local MonthlyKills: NumberValue = Player.leaderstats.Kills
			
			
			SoloRank.Parent = Player.leaderstats
			DuoRank.Parent = Player.leaderstats
			TotalKills.Parent = Player.leaderstats.Disabled
			MonthlyKills.Parent = Player.leaderstats.Disabled
			
			
			SoloRank.Value = playerClass.Rank1v1
			SoloRank:GetPropertyChangedSignal('Value'):Connect(function()
				playerClass.Rank1v1 = Player.leaderstats['Solo Rank'].Value
			end)

			DuoRank.Value = playerClass.Rank2v2
			DuoRank:GetPropertyChangedSignal('Value'):Connect(function()
				playerClass.Rank2v2 = Player.leaderstats['Duo Rank'].Value
			end)
			
		else
			Kills[userId] = {
				Total = TotalKillsDatastore:GetAsync(userId),
				Monthly = MonthlyKillsDatastore:GetAsync(userId)
			}
			
			local TotalKills: NumberValue = Player.leaderstats['Total Kills']
			local MonthlyKills: NumberValue = Player.leaderstats.Kills
			local Gold: NumberValue = Player.leaderstats.Gold
			
			
			TotalKills.Value = Kills[userId].Total or 0
			MonthlyKills.Value = Kills[userId].Monthly or 0
			Gold.Value = playerClass.Gold
			
			
			Player:SetAttribute("TotalKills", TotalKills.Value)
			Player:SetAttribute("Kills", MonthlyKills.Value)
			
			playerClass.TitlesProgress.Kills = TotalKills.Value
			
			
			TotalKills:GetPropertyChangedSignal('Value'):Connect(function()
				Player:SetAttribute("TotalKills", TotalKills.Value)
				Kills[userId].Total = TotalKills.Value
				playerClass.TitlesProgress.Kills = TotalKills.Value
			end)

			MonthlyKills:GetPropertyChangedSignal('Value'):Connect(function()
				Kills[userId].Monthly = MonthlyKills.Value
				Player:SetAttribute("Kills", MonthlyKills.Value)
			end)
			
			Player:GetAttributeChangedSignal("Gold"):Connect(function()
				Gold.Value = playerClass.Gold or Player:GetAttribute("Gold")
			end)
			
			
			if playerClass["Hide Kills"] == true and HasVIP then
				TotalKills.Parent = Player.leaderstats.Disabled
				MonthlyKills.Parent = Player.leaderstats.Disabled
			end
			
			if playerClass["Hide Gold"] == true then
				Gold.Parent = Player.leaderstats.Disabled
			end
			
			
			Player:SetAttribute("Hide_Kills", playerClass["Hide Kills"])
			Player:GetAttributeChangedSignal("Hide_Kills"):Connect(function()
				if Player:GetAttribute("Hide_Kills") ~= true or not Player:GetAttribute("HasVIP") then
					TotalKills.Parent = Player.leaderstats
					MonthlyKills.Parent = Player.leaderstats
				else
					TotalKills.Parent = Player.leaderstats.Disabled
					MonthlyKills.Parent = Player.leaderstats.Disabled
				end
			end)
			
			Player:SetAttribute("Hide_Gold", playerClass["Hide Gold"])
			Player:GetAttributeChangedSignal("Hide_Gold"):Connect(function()
				if Player:GetAttribute("Hide_Gold") ~= true then
					Gold.Parent = Player.leaderstats
				else
					Gold.Parent = Player.leaderstats.Disabled
				end
			end)
		end
	end)
	
	
	task.wait(0.1)
	
	
	for _, Config: BoolValue? in Player.Configuration:GetChildren() do
		local AttributeName = Config.Name:gsub(" ", "_")

		Player:SetAttribute(AttributeName, playerClass[Config.Name])
		Config.Value = playerClass[Config.Name]

		Config:GetPropertyChangedSignal('Value'):Connect(function()
			Player:SetAttribute(AttributeName, Config.Value)
			playerClass[Config.Name] = Config.Value
		end)
	end


	local Moveset = Player:GetAttribute("Moveset")
	if not Movesets[Moveset] then
		Player:SetAttribute("Moveset", "The Strongest Hero")
	end
	
	
	task.spawn(function()
		for PassName, PassId in Passes do
			if playerClass.OwnedPasses[PassName] ~= true and MarketplaceService:UserOwnsGamePassAsync(userId, PassId) then
				playerClass.OwnedPasses[PassName] = true
			end
		end
	end)
	
	task.spawn(function()
		playerClass.Gold = playerClass.Gold or 500
		
		if isAdmin(Player) or Player.UserId == 404769201 then
			playerClass.Gold = 9999

			Player:GetAttributeChangedSignal("Gold"):Connect(function()
				playerClass.Gold = 9999
				Player:SetAttribute("Gold", 9999)
			end)
		end
		
		for _, Emote in Player.Emotes:GetChildren() do
			Emote.Value = playerClass.Emotes[Emote.Name]
			Emote:GetPropertyChangedSignal('Value'):Connect(function()
				playerClass.Emotes[Emote.Name] = Emote.Value
			end)
		end

		for _, Emote in Player.Emotes2:GetChildren() do
			Emote.Value = playerClass.Emotes2[Emote.Name]
			Emote:GetPropertyChangedSignal('Value'):Connect(function()
				playerClass.Emotes2[Emote.Name] = Emote.Value
			end)
		end
		
		
		for _, Emote: Animation in EmotesFolder:GetChildren() do
			if table.find(playerClass.OwnedEmotes, Emote.Name) == nil then
				table.insert(playerClass.OwnedEmotes, Emote.Name)
			end
		end
		
		
		local OwnedEmotesCount = 0
		for _, Emote: Animation in EmotesFolder:GetChildren()  do
			if table.find(playerClass.OwnedEmotes, Emote.Name) then
				OwnedEmotesCount += 1

				continue
			end
			
			break
		end
		
		
		playerClass.TitlesProgress.Emotes = OwnedEmotesCount
		Player:SetAttribute("EmotesProgress", OwnedEmotesCount)
	end)
	
	
	task.wait(0.1)
	
	
	task.spawn(function()
		if Player.UserId == game.PrivateServerOwnerId or RNS:IsStudio() or isAdmin(Player) == true then
			Player:SetAttribute("IsServerOwner", true)
			
			shared.giveCommands(Player)
		end

		if HasVIP then
			local KillSoundId: string = playerClass.killSound
			local DeathSoundId: string = playerClass.deathSound

			if KillSoundId > 0 then
				Player:SetAttribute("killSound", KillSoundId)
			end

			if DeathSoundId > 0 then
				Player:SetAttribute("deathSound", DeathSoundId)
			end
			
			ComSet:FireClient(Player, 'AddEmoteSlots')
			ComSet:FireClient(Player, 'AddSecondPage')
			ComSet:FireClient(Player, 'PS+')
		end
	end)
	
	task.spawn(function()
		local CouldGet, TotalDonated = pcall(function()
			return TotalDonationsDatastore:GetAsync(tostring(userId)) or 0
		end)
		if CouldGet ~= true then return end

		playerClass.TitlesProgress.Robux = TotalDonated
		Player:SetAttribute("TotalDonated", TotalDonated)
	end)
	
	
	UpdateCosmetic(Player)
	
	
	task.wait(0.1)
	
	
	Player:SetAttribute("KillstreakProgress", playerClass.TitlesProgress.Killstreak)
	Player:SetAttribute("AwakensProgress", playerClass.TitlesProgress.Awakens)
	Player:SetAttribute("TreesDestroyedProgress", playerClass.TitlesProgress.TreesDestroyed)
	Player:SetAttribute("WallComboProgress", playerClass.TitlesProgress.WallCombo)
	Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.WallCombo)
	
	Player:SetAttribute("SaveSlots", playerClass.SaveSlots)
	Player:SetAttribute("Gold", playerClass.Gold)
	Player:SetAttribute("OwnedCosmetics", Http:JSONEncode(playerClass.OwnedCosmetics))
	Player:SetAttribute("DamageNeed", 0)
	
	
	task.delay(1, function()
		ComSet:FireClient(Player, "MobileButtons", playerClass.ButtonsInfo)
		
		if playerClass.Update_2_SawLog ~= true then
			playerClass.Update_2_SawLog = true
			
			local Changelogs = script.Screen.Changelogs:Clone()
			
			if Changelogs then
				Changelogs.Parent = Player.PlayerGui
				Changelogs.Enabled = true
			end
		end
	end)
	

	local loadedData = Instance.new('BoolValue')
	loadedData.Name = 'LoadedData'
	loadedData.Value = true
	loadedData.Parent = Player
	
	
	task.wait(0.1)
	
	
	task.spawn(function()
		for _,v in InfoModule.Titles do
			if v.Type ~= "Special" then continue end

			if v.ID == Player.UserId and not table.find(playerClass.OwnedTitles, v.Name) then
				table.insert(playerClass.OwnedTitles, v.Name)
			end
		end
		
		local AttributeNames = {}
		local AttributeToTitles = {}
		
		for _,v in InfoModule.Titles do
			if v.Name == "VIP" or v.Type == "Special" then continue end
			
			local AttributeName = v.Type .. "Progress"
			if v.Type == "Kills" then
				AttributeName = "TotalKills"
			elseif v.Type == "Robux" then
				AttributeName = "TotalDonated"
			end

			if not table.find(AttributeNames, AttributeName) then
				table.insert(AttributeNames, AttributeName)
				AttributeToTitles[AttributeName] = {}
			end
			table.insert(AttributeToTitles[AttributeName], v)

			local Progress = Player:GetAttribute(AttributeName)
			if not Progress then
				local Start = tick()
				repeat task.wait()
					Progress = Player:GetAttribute(AttributeName)
				until Progress
			end

			local Index = table.find(playerClass.OwnedTitles, v.Name)

			if Progress >= v.Requirement then
				if not Index then
					table.insert(playerClass.OwnedTitles, v.Name)
				end

			elseif Index then
				table.remove(playerClass.OwnedTitles, Index)

			end
		end

		local Seen = {}
		local i = 1
		while i <= #playerClass.OwnedTitles do
			local Title = playerClass.OwnedTitles[i]
			if Seen[Title] then
				table.remove(playerClass.OwnedTitles, i)
			else
				Seen[Title] = true
				i = i + 1
			end
		end

		TitlesRemote:FireClient(Player, "Initialize", {
			OwnedTitles = playerClass.OwnedTitles,
			EquippedTitle = playerClass.EquippedTitle
		})
		
		
		for _, AttributeName in AttributeNames do
			Player:GetAttributeChangedSignal(AttributeName):Connect(function()
				local Progress = Player:GetAttribute(AttributeName)
				
				for _, v in AttributeToTitles[AttributeName] do
					if v.Name == "VIP" or v.Type == "Special" then continue end
					
					if Progress >= v.Requirement and not table.find(playerClass.OwnedTitles, v.Name) then
						table.insert(playerClass.OwnedTitles, v.Name)
						
						TitlesRemote:FireClient(Player, "UnlockTitle", v.Name)
						TitlesRemote:FireClient(Player, "Initialize", { OwnedTitles = playerClass.OwnedTitles, ForChecking = true })
						
						shared.Announcement({ Title = "UNLOCKED TITLE", Message = "Unlocked the " .. v.Name .. " title!", Player = Player })
					end
				end
			end)
		end
	end)
	
	CollectionService:AddTag(Player, "DataLoaded")
end

local function PlayerAdded(Player: Player)
	if table.find(LocalBans, Player.UserId) ~= nil then
		Player:Kick("You are banned from this server")
	end

	if workspace.Configuration.LockServer.Value == true then
		Player:Kick("The owner of this private server has locked it.")

		return
	end
	
	if Player:GetAttribute('Added') == true then return end
	Player:SetAttribute('Added', true)


	local userId = Player.UserId
	
	
	CombatUtils:AddValue(Player, "NumberValue", 6, "RespawnTime")
	CombatUtils:AddValue(Player, "BoolValue", true, "CanRespawn")
	
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		Player:SetAttribute('TimesDied', 0)
		
		if RNS:IsStudio() then
			workspace:SetAttribute('GameType', 'Studio')
		else
			if Player:GetJoinData().TeleportData.Players == 2 then
				workspace:SetAttribute('GameType', 'Solo')
			else
				workspace:SetAttribute('GameType', 'Duo')
			end	
		end
		
	elseif game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		Player:SetAttribute('Teammate', 'nil')
		Player:SetAttribute('MainTeammate', false)
	end
	
	
	local data
	local success, emsg = pcall(function()
		data = DataStore:GetAsync(userId)
	end)

	if not success then
		warn(Player.Name .. '\'s data was not loaded: ' .. emsg)
	end


	local playerClass = nil
	if data == nil then
		playerClass = PlayerClass.new(Player)
	else
		playerClass = PlayerClass.new(Player, Http:JSONDecode(data))
	end

	if playerClass == nil then
		Player:Kick("Your data could not be loaded, please rejoin. \n If this keeps happening, please, contact a staff member.")

		return	
	end

	shared.playerClasses[userId] = playerClass

	local LoadedData, ErrorMessage = pcall(AddStarterPlayer, Player)
	if not LoadedData then
		Player:Kick("Couldn't load data, try again later.")

		if RNS:IsStudio() then
			warn(ErrorMessage)
		end

		return
	end
	
	Player:SetAttribute('Loaded', true)
	
	local Character = Player.Character
	if Character then
		CharacterAdded(Character)
	end

	Player.CharacterAdded:Connect(CharacterAdded)
	
	
	task.delay(1,function()
		if playerClass["Hide VIP Join Message"] ~= true and Player:GetAttribute("HasVIP") then
			ReplicateSet:FireAllClients("systemMessage", { Info = { Text = string.format("<font color='#0070dd' face='GothamBold'>[S]</font> <font color='#FFFFD8' face='GothamBold'>%s</font> <font color='#FFFFD8' face='GothamBold'>has arrived!</font>", Player.DisplayName) } })
		end
	end)
	
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		Player:GetAttributeChangedSignal('Teammate'):Connect(function()
			if Player:GetAttribute('MainTeammate') == true and Player:GetAttribute('Teammate') ~= 'nil' and Players:FindFirstChild(Player:GetAttribute('Teammate')) then
				local DuoPlayer: Player = Players:FindFirstChild(Player:GetAttribute('Teammate'))
			end
		end)
	end
	
	
	pcall(function()
		UpdateCosmetic(Player)
	end)
	
	Player:GetAttributeChangedSignal("TotalKills"):Connect(UpdateCosmetic)
	Player:GetAttributeChangedSignal("NewCosmetics"):Connect(UpdateCosmetic)
	
	
	local LoadedCape, CapeData = pcall(function()
		return CapeStore:GetAsync("Cape_" .. Player.UserId)
	end)
	
	
	local function OnAttributeChange(AttributeName, GuiName)
		Player:GetAttributeChangedSignal(AttributeName):Connect(function()
			local FoundGUI = Player:GetAttribute(AttributeName) and script.Screen[GuiName]:Clone()
			
			if FoundGUI then
				if FoundGUI.Name == "Cape Customization" then
					if success and data then
						FoundGUI:SetAttribute("Decal", data.Decal)
						FoundGUI:SetAttribute("Info", data.OldData)
					end
					
					FoundGUI.Parent = Player.PlayerGui
					FoundGUI.Enabled = true
					
				else
					FoundGUI.Parent = Player.PlayerGui
					FoundGUI.Enabled = true
				end
				
			elseif Player.PlayerGui:FindFirstChild(GuiName) then
				Player.PlayerGui[GuiName]:Destroy()
			end
		end)
	end
	
	OnAttributeChange("CustomizeVIPCape", "Cape Customization")
	OnAttributeChange("CustomizeKillSound", "Kill Sound")
	OnAttributeChange("CustomizeAwakeningOutfit", "Awakening Outfit")
	OnAttributeChange("Changelogs", "Changelogs")
end

function CharacterAdded(Character: Model)
	if not Character:IsDescendantOf(game) then
		repeat task.wait() until Character:IsDescendantOf(game)
	end
	
	Character:SetAttribute("JustSpawned", true)
	Character.Parent = workspace.Live
	

	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		if Character then
			Character:Destroy()
		end

		return
	end


	local userId = Player.UserId
	local playerClass = shared.playerClasses[userId]
	
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid') or Character:WaitForChild('Humanoid', 10)
	local Animator: Animator = Humanoid:FindFirstChild('Animator') or Humanoid:WaitForChild('Animator', 10)
	local Head: BasePart     = Character:FindFirstChild('Head') or Character:WaitForChild('Head', 10)
	local HumRP: BasePart    = Character:FindFirstChild('HumanoidRootPart') or Character:WaitForChild('HumanoidRootPart', 10)
	
	
	local Stun
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		if workspace:GetAttribute('Started') ~= true then
			Stun = StunHandler:Stun(Character, nil, true)
		end
	end
	
	
	local Died = false
	local TPInfo = Player:GetJoinData().TeleportData
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		if RNS:IsStudio() then
			TPInfo = { Players = 1; [Player.Name] = 'Spawn11' }
		else
			if TPInfo.Teams ~= nil then
				if Player.Name == TPInfo.Teams[1].Main then
					Player:SetAttribute('MainTeammate', true)
					Player:SetAttribute('Teammate', TPInfo.Teams[1].Teammate)

				elseif Player.Name == TPInfo.Teams[1].Teammate then
					Player:SetAttribute('MainTeammate', false)
					Player:SetAttribute('Teammate', TPInfo.Teams[1].Main)

				elseif Player.Name == TPInfo.Teams[2].Main then
					Player:SetAttribute('MainTeammate', true)
					Player:SetAttribute('Teammate', TPInfo.Teams[2].Teammate)

				elseif Player.Name == TPInfo.Teams[2].Teammate then
					Player:SetAttribute('MainTeammate', false)
					Player:SetAttribute('Teammate', TPInfo.Teams[2].Main)
				end
			end
		end
		
		
		task.defer(workspace.PivotTo, Character, workspace.Miscellaneous.Spawns[TPInfo[Player.Name]].CFrame)
	end
	
	
	-- Spawn Handler
	
	if Player:GetAttribute("Awakened") then
		Player.AwakeningProgress.Value = 0
	end
	
	Player:SetAttribute("Awakened", false)
	
	
	iFramesService:AddAlliFrames(Character)
	AnimationService:loadAnimations(Character)
	
	
	ReplicateSet:FireAllClients('WhiteAura', { Time = 4, Plr = Player, Light = false })
	task.delay(4, function()
		Character:SetAttribute("JustSpawned", nil)
		iFramesService:RemoveAlliFrames(Character)
	end)
	
	
	if Humanoid.MoveDirection.Magnitude == 0 and SpawnAnims[Player:GetAttribute("Moveset")] ~= nil and Player:GetAttribute('DoSpawnAnim') ~= false then
		SpawnAnims[Player:GetAttribute("Moveset")](Player)

		Humanoid:GetPropertyChangedSignal('MoveDirection'):Once(function()
			if Humanoid.MoveDirection.Magnitude ~= 0 then
				AnimationService:stopAll(Character)
			end
		end)
	end
	
	
	
	-- Appareance Handler

	task.spawn(function()
		shared.AddAppareance(Player, Character)
	end)
	
	
	
	
	-- Setup
	
	if Player:GetAttribute('DidSetup') ~= true then
		Player:SetAttribute('DidSetup', true)


		task.spawn(function()
			local MostTotalDonated = TotalDonationsDatastore:GetSortedAsync(false, 1):GetCurrentPage()[1]
			local MostMonthlyDonated = DonationsDatastore:GetSortedAsync(false, 1):GetCurrentPage()[1]

			if MostTotalDonated and MostMonthlyDonated then
				MostTotalDonated = MostTotalDonated.key
				MostMonthlyDonated = MostMonthlyDonated.key

				if userId == tonumber(MostTotalDonated) or userId == tonumber(MostMonthlyDonated) then
					pcall(function()
						repeat task.wait() until Player:FindFirstChild('loadedTopBar')

						ComSet:FireClient(Player, 'GiveAdminChar')
					end)
					
					Player:SetAttribute("HasAdminMoveset", true)
				end
			end
		end)
	end



	-- Humanoid 

	Humanoid.Died:Once(function()
		if Died == false then
			Died = true

			HumanoidDied(Player)
		end
	end)

	Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
		if Humanoid.Health <= 0 then
			if Died == false then
				Died = true

				HumanoidDied(Player)
			end
		end
	end)

	HumRP:GetPropertyChangedSignal('Parent'):Connect(function()
		if Died == false and HumRP.Position.Y <= workspace.FallenPartsDestroyHeight then
			Died = true

			HumanoidDied(Player)
		end
	end)

	Humanoid.DisplayName = Player.DisplayName



	-- Moveset

	MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
	
	
	
	-- Anim Loader

	AnimationService:loadAnimations(Character)



	-- Collisions Handler --

	CollisionsModule:SetCollisionGroup(Character, 'Players')

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)



	-- Extra --

	task.delay(1, function()
		for Type, Table: { string } in playerClass.Cosmetics do
			for _, Name in Table do
				CosmeticsBindable:Fire(Player, { Type = Type; State = true; Name = Name; })
			end
		end
	end)
	
	ComunicatorFunctions.EquipTitle(Player, playerClass.EquippedTitle)
	
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		if workspace:GetAttribute('Started') ~= true then
			LoadedPlayers[Player.Name] = true

			repeat task.wait() until GetTableSize(LoadedPlayers) == TPInfo.Players

			task.wait(5)

			workspace:SetAttribute("DuelsCountdown", true)

			task.wait(3)

			workspace:SetAttribute('Started', true)
			StunHandler:Unstun(Character, Stun)
		end
	end
	
	
	
	-- Attributes --

	Character:SetAttribute("Moveset", Player:GetAttribute("Moveset"))
end

function PlayerRemoving(Player: Player)
	local userId = Player.UserId
	
	if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
		if not workspace:HasTag('Finished') then
			local playerClass = shared.playerClasses[userId]
			if not playerClass then return end
			
			if workspace:GetAttribute('GameType') == 'Duo' then
				playerClass.Rank2v2 -= 5
				if playerClass.Rank2v2 < 0 then
					playerClass.Rank2v2 = 0
				end

				local Teammate = Player:GetAttribute('Teammate')
				if Teammate then
					if not Players:FindFirstChild(Teammate) or (Players:FindFirstChild(Teammate) and Players[Teammate]:GetAttribute('TimesDied') == 2) then
						FinishGame()

						for _, Winner in Players:GetPlayers() do
							if Winner ~= Player and Winner ~= Players:FindFirstChild(Teammate) then
								local WinnerplayerClass = shared.playerClasses[Winner.UserId]
								if not WinnerplayerClass then return end
								
								WinnerplayerClass.Rank2v2 += 5
							end
						end
					end
				end
			elseif workspace:GetAttribute('GameType') == 'Solo' then
				FinishGame()


				playerClass.Rank1v1 -= 5
				if playerClass.Rank1v1 < 0 then
					playerClass.Rank1v1 = 0
				end

				for _, Winner in Players:GetPlayers() do
					if Winner ~= Player then
						local WinnerplayerClass = shared.playerClasses[Winner.UserId]
						if not WinnerplayerClass then return end
						
						WinnerplayerClass.Rank1v1 += 5
					end
				end
			end
		end
		
	elseif game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		if Player:GetAttribute('Teammate') ~= 'nil' and Players:FindFirstChild(Player:GetAttribute('Teammate')) then
			local TeammatePlayer = Players:FindFirstChild(Player:GetAttribute('Teammate'))

			if Player:GetAttribute('MainTeammate') == true then
				QeueModule.DuoQeueTable[Player] = nil
			else
				QeueModule.DuoQeueTable[TeammatePlayer] = nil
			end

			TeammatePlayer:SetAttribute('Teammate', 'nil')
			TeammatePlayer.Character:PivotTo(workspace.Miscellaneous.SpawnLocations.SpawnLocation.CFrame)
			ComSet:FireClient(TeammatePlayer, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = true; })
		end
	end
	
	shared.playerClasses[userId].Emotes = { ['1'] = Player.Emotes['1'].Value; ['2'] = Player.Emotes['2'].Value; ['3'] = Player.Emotes['3'].Value; ['4'] = Player.Emotes['4'].Value; ['5'] = Player.Emotes['5'].Value; ['6'] = Player.Emotes['6'].Value; ['7'] = Player.Emotes['7'].Value; ['8'] = Player.Emotes['8'].Value; }
	
	SaveData(userId)
end




--Main
for _,v in Players:GetPlayers() do
	if not v:GetAttribute('Added') then
		task.spawn(function()
			PlayerAdded(v)
		end)
	end
end


Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

game:BindToClose(function()
	if RNS:IsStudio() then
		for userId, playerClass in shared.playerClasses do
			task.spawn(SaveData, userId, playerClass)
		end
	end

	task.spawn(function()
		pcall(function()
			local GoalCycle = workspace.Terrain.Time:GetAttribute("Cycle")

			local CurrentDayTimeCicle = DayTimeCycleDatastore:GetAsync("Cycle")
			if CurrentDayTimeCicle and CurrentDayTimeCicle >= GoalCycle then return end

			DayTimeCycleDatastore:SetAsync("Value", GoalCycle)
		end)
	end)
	
	if (PS_OwnerId > 0 or RNS:IsStudio()) and workspace.Built:GetAttribute("LoadedLastBuilt") then
		LastBuiltDatastore:UpdateAsync((RNS:IsStudio() and -1 or PS_OwnerId), function()
			local BuiltTable = {}

			for _, Part: Part in workspace.Built:GetChildren() do
				BuiltTable[Part.Name] = {
					Class = Part.Name == "Trashcan" and "Trashcan" or Part.ClassName,
					Position = { Part.Position.X, Part.Position.Y, Part.Position.Z },
					Orientation = { Part.Orientation.X, Part.Orientation.Y, Part.Orientation.Z },
					Size = { Part.Size.X, Part.Size.Y, Part.Size.Z },
					Color = { Part.Color.R, Part.Color.G, Part.Color.B },
					Material = Part.Material.Name,
					Transparency = Part.Transparency,
					EmitLight = Part:GetAttribute("EmitLight"),
					Range = Part:GetAttribute("Range") or 8,
					Brightness = Part:GetAttribute("Brightness") or 1,
					CastShadow = Part.CastShadow,
					CanCollide = Part.CanCollide,
					NoAttack = Part:GetAttribute("NoAttack"),
					GivesAwakening = Part:GetAttribute("GivesAwakening"),
					ResetsCooldowns = Part:GetAttribute("ResetsCooldowns"),
					Heals = Part:GetAttribute("Heals"),
					Bouncy = Part:GetAttribute("Bouncy"),
					Deadly = Part:GetAttribute("Deadly"),
					Destructible = Part:GetAttribute("Destructible"),
					Fragile = Part:GetAttribute("Fragile"),
					TextOutline = Part.BuildText.TextLabel.TextStrokeTransparency < 1,
					Text = Part.BuildText.TextLabel.Text,
					TextTransparency = Part.BuildText.TextLabel.TextTransparency,
					TextFont = Part.BuildText.TextLabel.Font.Name,
					TextColor = { Part.BuildText.TextLabel.TextColor3.R, Part.BuildText.TextLabel.TextColor3.G, Part.BuildText.TextLabel.TextColor3.B },
					CurrentMoves = Part:GetAttribute("CurrentMoves")
				}
			end

			return BuiltTable
		end)
	end
end)

Remotes.Emotes.Get.OnServerInvoke = function(plr)
	return shared.playerClasses[plr.UserId].Emotes, shared.playerClasses[plr.UserId].Emotes2
end

MessagingService:SubscribeAsync('Announcement', function(Params)
	for _, Player in ipairs(Players:GetPlayers()) do
		shared.Announcement({
			Message = Params.Data,
			Player = Player
		})
	end
end)

MessagingService:SubscribeAsync('resetPlayers', function()
	for _, plr in Players:GetPlayers() do
		task.spawn(function()
			repeat task.wait() until plr:GetAttribute('Loaded') == true or plr.Parent == nil

			if plr.Parent ~= nil then
				plr.leaderstats.Kills.Value = 0
			end
		end)
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player: Player, purchasePassId, isPurchased)
	if isPurchased == true then
		local playerClass = shared.playerClasses[Player.UserId]

		if playerClass then
			for PassName, PassId in Passes do
				if PassId == purchasePassId then
					playerClass.OwnedPasses[PassName] = true
				end
			end
		end


		
		if purchasePassId == Passes["VIP"] then
			Player:SetAttribute("HasVIP", true)
			
			
			TitlesRemote:FireClient(Player, "UnlockTitle", "VIP")
			ComSet:FireClient(Player, 'AddEmoteSlots')
			ComSet:FireClient(Player, 'AddSecondPage')
			ComSet:FireClient(Player, 'PS+')
			
			
			table.insert(playerClass.OwnedTitles, "VIP")
			table.insert(playerClass.OwnedCosmetics, "Custom Cape")
		end
		
		ComSet:FireClient(Player, "SendNotification", { Text = "Successfully purchased GamePass!" })
	end
end)

ComGet.OnServerInvoke = function(Player, Function, Params)
	return ComunicatorFunctions[Function](Player, Params)
end

ComSet.OnServerEvent:Connect(function(Player, _Function, Params)
	if _Function == 'InputDetected' then
		for _, AnimationTrack: AnimationTrack in AnimationService:getLoadedAnimations(Player.Character) do
			if AnimationTrack.IsPlaying == true and AnimationTrack.Animation.Parent == Animations["Spawn Animations"] then
				AnimationService:stopAnimation(Player.Character, AnimationTrack.Animation)
			end
		end

		Player:SetAttribute('DoSpawnAnim', false)
	else
		ComunicatorFunctions[_Function](Player, Params)
	end
end)

MarketplaceService.ProcessReceipt = function(receiptInfo: ReceiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local productPrice = receiptInfo.CurrencySpent

	local Player = Players:GetPlayerByUserId(userId)

	local couldGiveProduct, Value = pcall(function()
		if table.find(Donations, productId) then
			if not Player then return Enum.ProductPurchaseDecision.NotProcessedYet end
			if productPrice < 1 then return Enum.ProductPurchaseDecision.PurchaseGranted end

			local TotalDonated, MonthlyDonated = nil
			local datastoreKey = tostring(userId)

			TotalDonationsDatastore:UpdateAsync(datastoreKey, function(oldData)
				local newData
				if oldData and typeof(oldData) == "number" then
					newData = oldData + productPrice
				else
					newData = productPrice
				end

				TotalDonated = newData

				return newData
			end)

			DonationsDatastore:UpdateAsync(datastoreKey, function(oldData)
				local newData
				if oldData and typeof(oldData) == "number" then
					newData = oldData + productPrice
				else
					newData = productPrice
				end

				MonthlyDonated = newData

				return newData
			end)


			local playerClass = shared.playerClasses[userId]
			if playerClass then
				playerClass.TitlesProgress.Robux = TotalDonated
			end

			Player:SetAttribute("TotalDonated", TotalDonated)


			local firstTotalDonorRobux = TotalDonationsDatastore:GetSortedAsync(false, 1):GetCurrentPage()[1]


			if firstTotalDonorRobux then
				firstTotalDonorRobux = firstTotalDonorRobux.value
				if TotalDonated > firstTotalDonorRobux then
					pcall(function()
						repeat task.wait() until Player:FindFirstChild('loadedTopBar')
						
						ComSet:FireClient(Player, 'GiveAdminChar')
					end)
					
					Player:SetAttribute("HasAdminMoveset", true)
				end

			else
				local firstMonthlyDonorRobux = DonationsDatastore:GetSortedAsync(false, 1):GetCurrentPage()[1]

				if firstMonthlyDonorRobux then
					firstMonthlyDonorRobux = firstMonthlyDonorRobux.value

					if MonthlyDonated > firstMonthlyDonorRobux then
						pcall(function()
							repeat task.wait() until Player:FindFirstChild('loadedTopBar')

							ComSet:FireClient(Player, 'GiveAdminChar')
						end)
						
						Player:SetAttribute("HasAdminMoveset", true)
					end
				end
			end
			
			for _, GoalPlayer in ipairs(Players:GetPlayers()) do
				shared.Announcement({ Title = "THANK YOU!", Message = "Your donation of " .. tostring(productPrice) .. " Robux is appreciated and helps us out. Thank you!", Player = GoalPlayer })
			end
			
			return Enum.ProductPurchaseDecision.PurchaseGranted

		else
			local CouldGetInfo, productInfo = pcall(function()
				return MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
			end)
			if not CouldGetInfo or not productInfo or typeof(productInfo) ~= "table" or not productInfo.Name then return Enum.ProductPurchaseDecision.NotProcessedYet end

			local productName: string = productInfo.Name

			if Products[productName] == productId then
				local playerClass = shared.playerClasses[userId]
				if not playerClass then return Enum.ProductPurchaseDecision.NotProcessedYet end
				
				
				if productName:match("Random Emote") then
					if productName == 'Random Emote' then
						SpinEmoteFunc(Player)
						
					elseif productName == 'Random Emote x5' then
						for i = 1, 5 do
							SpinEmoteFunc(Player)
						end
						
					elseif productName == 'Random Emote x10' then
						for i = 1, 10 do
							SpinEmoteFunc(Player)
						end
						
					end
					
					Remotes.Emotes.Set:FireClient(Player, 'UpdateOwnedEmotes', { OwnedEmotes = playerClass.OwnedEmotes; })
					
				elseif productName:match(" Cosmetic") then
					local NewCosmetics = {}

					if productName == '1 Cosmetic' then
						table.insert(NewCosmetics, SpinCosmeticFunc(Player))
					elseif productName == '3 Cosmetics' then
						for i = 1, 3 do
							table.insert(NewCosmetics, SpinCosmeticFunc(Player))
						end
					elseif productName == '5 Cosmetics' then
						for i = 1, 5 do
							table.insert(NewCosmetics, SpinCosmeticFunc(Player))
						end
					end

					Player:SetAttribute("NewCosmetics", Http:JSONEncode(NewCosmetics))
					Player:SetAttribute("OwnedCosmetics", Http:JSONEncode(playerClass.OwnedCosmetics))
					
				elseif productId == Products["500 Gold"] then
					playerClass.Gold += 500

					if not Player then return Enum.ProductPurchaseDecision.PurchaseGranted end
					Player:SetAttribute("Gold", playerClass.Gold)
					ComSet:FireClient(Player, "BoughtGold", "500")

				elseif productId == Products["1,000 Gold"] then
					playerClass.Gold += 1000

					if not Player then return Enum.ProductPurchaseDecision.PurchaseGranted end
					Player:SetAttribute("Gold", playerClass.Gold)
					ComSet:FireClient(Player, "BoughtGold", "1,000")

				elseif productId == Products["2,500 Gold"] then
					playerClass.Gold += 2500

					if not Player then return Enum.ProductPurchaseDecision.PurchaseGranted end
					Player:SetAttribute("Gold", playerClass.Gold)
					ComSet:FireClient(Player, "BoughtGold", "2,500")

				elseif productId == Products["5,000 Gold"] then
					playerClass.Gold += 5000

					if not Player then return Enum.ProductPurchaseDecision.PurchaseGranted end
					Player:SetAttribute("Gold", playerClass.Gold)
					ComSet:FireClient(Player, "BoughtGold", "5,000")
					
				end

				return Enum.ProductPurchaseDecision.PurchaseGranted

			elseif Gifts[productName:gsub(" %- Gift", "")] and Player:GetAttribute("GiftingPass") and Player:GetAttribute("GiftingPlayer") then
				if not Player then return Enum.ProductPurchaseDecision.NotProcessedYet end
				if Player:GetAttribute("Gifting") then
					return ComSet:FireClient(Player, "SendNotification", { Text = "Please don't purchase other things while gifting." })
				end
				Player:GetAttribute("Gifting", true)


				local gamePassName = Player:GetAttribute("GiftingPass")
				local goalUserId = Player:GetAttribute("GiftingPlayer")

				local userExists = pcall(function()
					goalUserId = tonumber(goalUserId)
					assert(Players:GetNameFromUserIdAsync(goalUserId), "User doesn't exist.")
				end)

				if not userExists or not Gifts[gamePassName] then return Enum.ProductPurchaseDecision.NotProcessedYet end

				local GoalPlayer = Players:GetPlayerByUserId(goalUserId)

				local function AddPass(playerClass)
					if Passes[gamePassName] then
						if playerClass.OwnedPasses[gamePassName] ~= true then
							playerClass.OwnedPasses[gamePassName] = true
						else
							return Enum.ProductPurchaseDecision.NotProcessedYet
						end

						if GoalPlayer then
							ComSet:FireClient(GoalPlayer, "SendNotification", { Text = "@" .. Player.Name .. " has gifted you \"" .. gamePassName .. "\"!" })
						else
							table.insert(playerClass.PendingGifts, { Player.Name, gamePassName })
							return Enum.ProductPurchaseDecision.PurchaseGranted, playerClass
						end

						if productId == Gifts["VIP"] then
							Player:SetAttribute("HasVIP", true)


							TitlesRemote:FireClient(Player, "UnlockTitle", "VIP")
							ComSet:FireClient(Player, 'AddEmoteSlots')
							ComSet:FireClient(Player, 'AddSecondPage')
							ComSet:FireClient(Player, 'PS+')


							table.insert(playerClass.OwnedTitles, "VIP")
							table.insert(playerClass.OwnedCosmetics, "Custom Cape")
						else
							return Enum.ProductPurchaseDecision.NotProcessedYet
						end

					elseif InfoModule.Products[gamePassName] then
						if GoalPlayer then
							ComSet:FireClient(GoalPlayer, "SendNotification", { Text = "@" .. Player.Name .. " has gifted you \"" .. gamePassName .. "\"!" })
						else
							table.insert(playerClass.PendingGifts, { Player.Name, gamePassName })
							return Enum.ProductPurchaseDecision.PurchaseGranted, playerClass
						end

						if productId == Gifts["500 Gold"] then
							playerClass.Gold += 500

							GoalPlayer:SetAttribute("Gold", playerClass.Gold)
							ComSet:FireClient(GoalPlayer, "BoughtGold", "500")

						elseif productId == Gifts["1,000 Gold"] then
							playerClass.Gold += 1000

							GoalPlayer:SetAttribute("Gold", playerClass.Gold)
							ComSet:FireClient(GoalPlayer, "BoughtGold", "1,000")

						elseif productId == Gifts["2,500 Gold"] then
							playerClass.Gold += 2500

							GoalPlayer:SetAttribute("Gold", playerClass.Gold)
							ComSet:FireClient(GoalPlayer, "BoughtGold", "2,500")

						elseif productId == Gifts["5,000 Gold"] then
							playerClass.Gold += 5000

							GoalPlayer:SetAttribute("Gold", playerClass.Gold)
							ComSet:FireClient(GoalPlayer, "BoughtGold", "5,000")
							
						else
							return Enum.ProductPurchaseDecision.NotProcessedYet
						end

					else
						return Enum.ProductPurchaseDecision.NotProcessedYet
					end
				end

				local playerClass = shared.playerClasses[goalUserId]
				if playerClass and Players:GetPlayerByUserId(goalUserId) then
					local State = AddPass(playerClass)
					if State == Enum.ProductPurchaseDecision.PurchaseGranted then
						ComSet:FireClient(Player, { Text = "Successfully sent \"" .. gamePassName .. "\" gift!" })
					end

					return State

				else
					ComSet:FireClient(Player, "SendNotification", { Text = "DO NOT LEAVE." })

					local PublishData = nil
					DataStore:UpdateAsync(goalUserId, function(oldData)
						local newData
						if not oldData then
							newData = DefaultData
						else
							newData = Http:JSONDecode(oldData)
						end

						for Index, Value in DefaultData do
							if newData[Index] then continue end

							newData[Index] = Value
						end


						local _, newPassData = AddPass(newData, true)
						if newPassData then
							newData = newPassData
						end

						PublishData = Http:JSONEncode(newData)

						return PublishData
					end)

					ComSet:FireClient(Player, "SendNotification", { Text = "Successfully sent \"" .. gamePassName .. "\" gift!" })

					return Enum.ProductPurchaseDecision.PurchaseGranted

				end

			end
		end
	end)

	if couldGiveProduct then
		Player:GetAttribute("Gifting", nil)

		return typeof(Value) == "EnumItem" and Value or Enum.ProductPurchaseDecision.NotProcessedYet
	else
		warn("Couldn't give product to id " .. userId .. ". Because of: " .. Value)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end


shared.fireAllExcept = function(RemoteEvent: RemoteEvent, Blacklist: { Players }, Parameters: { any })
	for _, Player: Player in Players:GetPlayers() do
		if not table.find(Blacklist, Player) then
			RemoteEvent:FireClient(Player, table.unpack(Parameters))
		end
	end
end

shared.fireTo = function(RemoteEvent: RemoteEvent, Whitelist: { Players }, Parameters: { any })
	for _, Player: Player in Whitelist do
		RemoteEvent:FireClient(Player, table.unpack(Parameters))
	end
end

shared.VoxelDestruction = function(detectFunction, params, DestroyParams, Voxels)
	if typeof(DestroyParams) == "table" or typeof(Voxels) == "table" then

		local Parameters = {}
		if DestroyParams then
			local Parts = detectFunction(params, DestroyableOParams)

			local Player = DestroyParams.Owner
			local playerClass = shared.playerClasses[Player.UserId]
			if playerClass then
				local DestroyedTrees = {}

				for _, Part: Part in Parts do
					if not Part or not Part.Parent or Part.Parent.Name ~= "Tree" or table.find(DestroyedTrees, Part.Parent) then continue end

					table.insert(DestroyedTrees, Part.Parent)
				end

				playerClass.TitlesProgress.TreesDestroyed += #DestroyedTrees
				Player:SetAttribute("TreesDestroyedProgress", playerClass.TitlesProgress.TreesDestroyed)
			end

			Parameters.Parts = Parts
			Parameters.Burn = DestroyParams.Burn
			Parameters.Velocity = DestroyParams.Velocity
			Parameters.LookAt = DestroyParams.LookAt

		else
			for Index, Value in Voxels do
				Parameters[Index] = Value
			end
			Parameters.Voxels = true

		end

		ReplicateSet:FireAllClients("destroyAmbient", Parameters)
	end
end


CollectionService:GetInstanceAddedSignal("CantRotate"):Connect(function(Character: Model)
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.AutoRotate = false
	end
end)

CollectionService:GetInstanceRemovedSignal("CantRotate"):Connect(function(Character: Model)
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		if Character:HasTag("Ragdolled") then
			Character:AddTag("CantRotate")
		else
			Humanoid.AutoRotate = true
		end
	end
end)

task.spawn(function()
	pcall(function()
		local CurrentDayTimeCicle = DayTimeCycleDatastore:GetAsync("Cycle")
		if CurrentDayTimeCicle then
			TimeValue:SetAttribute("Cycle", CurrentDayTimeCicle)
		end
	end)
end)


local updateStartTime = time()
RNS.Heartbeat:Connect(function(DeltaTime)
	if time() - updateStartTime > 300 then
		updateStartTime = time()

		for _,v in updateFunctions do
			task.spawn(v)
		end
	end


	local GoalTime = TimeValue.Value + 0.00075
	if GoalTime >= 24 then
		GoalTime = 0


		local GoalCycle = TimeValue:GetAttribute("Cycle") + 1

		TimeValue:SetAttribute("Cycle", GoalCycle)
	end

	TimeValue.Value = GoalTime
end)
for _,v in updateFunctions do
	task.spawn(v)
end


if not DataStore:GetAsync('LastMonthReset') then
	DataStore:SetAsync('LastMonthReset', os.time())
else
	if os.time() - DataStore:GetAsync('LastMonthReset') >= 2629800 then
		DataStore:SetAsync('LastMonthReset', os.time())

		task.spawn(function()
			local Kills = MonthlyKillsDatastore:GetSortedAsync(false, 100)

			repeat
				for _,data in Kills:GetCurrentPage() do
					MonthlyKillsDatastore:SetAsync(data.key, 0)
				end

				if Kills.IsFinished == false then
					Kills:AdvanceToNextPageAsync()
				end
			until Kills.IsFinished == true
		end)

		task.spawn(function()
			local DonationsSort = DonationsDatastore:GetSortedAsync(false, 100)

			repeat
				for _,data in DonationsSort:GetCurrentPage() do
					DonationsDatastore:SetAsync(data.key, 0)
				end

				if DonationsSort.IsFinished == false then
					DonationsSort:AdvanceToNextPageAsync()
				end
			until DonationsSort.IsFinished == true
		end)

		MessagingService:PublishAsync('resetPlayers')

		for _, plr in Players:GetPlayers() do
			task.spawn(function()
				repeat task.wait() until plr:GetAttribute('Loaded') == true or plr.Parent == nil

				if plr.Parent ~= nil then
					local Kills: NumberValue = plr.leaderstats:FindFirstChild("Kills", true)
					if Kills then
						Kills.Value = 0
					end
				end
			end)
		end
	end
end



if PS_OwnerId > 0 or RNS:IsStudio() then
	local CouldGet, BuildTable = pcall(function()
		return LastBuiltDatastore:GetAsync((RNS:IsStudio() and -1 or PS_OwnerId))
	end)

	if CouldGet and typeof(BuildTable) == "table" then
		workspace.Built:SetAttribute("LoadedLastBuilt", true)

		for Serial, PartInfo in BuildTable do
			local Part: Part?

			if PartInfo.Class == "Throwable" then
				Part = RS.Resources.Trashcan:Clone()

				Part:AddTag("Throwable")

			else
				Part = Instance.new(PartInfo.Class)

				Part:AddTag("Combeable")

			end


			Part:AddTag("PSBuilt")

			local BuildText = script.Screen.BuildText:Clone()
			BuildText.Parent = Part

			for Name, Value in PartInfo do
				if Name == "Class" or Name == "Range" or Name == "Brightness" then continue end

				if Name == "Position" or Name == "Orientation" or Name == "Size" or Name == "Color" then
					local Constructor = Name == "Color" and Color3.new or Vector3.new
					Value = Constructor(Value[1], Value[2], Value[3])

					Part[Name] = Value

				elseif Name == "Material" then
					Part.Material = Enum.Material[Value]

				elseif Name == "Transparency" then
					Part.Transparency = Value

				elseif Name == "EmitLight" then
					if Value == true then
						local PointLight = Instance.new("PointLight")
						PointLight.Range = PartInfo.Range
						PointLight.Brightness = PartInfo.Brightness
						PointLight.Parent = Part
					end

				elseif Name == "CastShadow" or Name == "CanCollide" then
					Part[Name] = Value

				elseif Name == "TextOutline" then
					BuildText.TextLabel.TextStrokeTransparency = Value == true and 0 or 1

				elseif Name == "Text" then
					BuildText.TextLabel.Text = Value

				elseif Name == "TextTransparency" then
					BuildText.TextLabel.TextTransparency = Value

				elseif Name == "TextFont" then
					BuildText.TextLabel.Font = Enum.Font[Value]

				elseif Name == "TextColor" then
					Value = Color3.new(Value[1], Value[2], Value[3])

					BuildText.TextLabel.TextColor3 = Value

				end

				Part:SetAttribute(Name, Value)
			end

			Part.Anchored = true
			Part.Name = Serial
			Part.Parent = workspace.Built


			local LiveOverlapParameters = OverlapParams.new()
			LiveOverlapParameters.FilterType = Enum.RaycastFilterType.Include
			LiveOverlapParameters.FilterDescendantsInstances = { workspace.Live }

			local TouchedCharacters = {}
			local LastCharacters = {}
			local Touched = RNS.Heartbeat:Connect(function()
				LastCharacters = {}

				for _, otherPart in workspace:GetPartsInPart(Part, LiveOverlapParameters) do
					local Character = otherPart.Parent
					if not Character:FindFirstChild("Humanoid") or not Character:FindFirstChild("HumanoidRootPart") then continue end
					local Player = Players:GetPlayerFromCharacter(Character)
					if not Player or table.find(TouchedCharacters, Character) or table.find(LastCharacters, Character) or iFramesService:HasiFrame(Character, "M1") then continue end
					table.insert(TouchedCharacters, Character)
					table.insert(LastCharacters, Character)

					local Humanoid: Humanoid = Character.Humanoid
					local HumRP: BasePart = Character.HumanoidRootPart

					if Part:GetAttribute("NoAttack") then
						Character:SetAttribute("NoAttack", not (Character:GetAttribute("NoAttack") or false))
					end

					if Part:GetAttribute("GivesAwakening") then
						Player.AwakeningProgress.Value = 100
					end

					if Part:GetAttribute("ResetsCooldowns") then
						Player.Commands.NoCooldown.Value = true
						Player.Commands.NoCooldown.Value = false
					end

					if Part:GetAttribute("Heals") and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Humanoid.Health > 0 then
						Humanoid.Health = Humanoid.MaxHealth
					end

					if Part:GetAttribute("Bouncy") then
						task.spawn(function()
							Knockback:Knockback(Character, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = -CFrame.lookAt(HumRP.Position, Part.Position).LookVector * 75 })
							RagdollHandler.ragdoll(Humanoid, 1)
						end)
					end

					if Part:GetAttribute("Deadly") then
						Humanoid.Health = 0
					end

					if Part:GetAttribute("CurrentMoves") then
						local CurrentMoves = Http:JSONDecode(Part:GetAttribute("CurrentMoves"))
						local ClearPrevious, RandomMoveset = table.find(CurrentMoves, "Clear Previous"), table.find(CurrentMoves, "Random Moveset")						

						if ClearPrevious then
							table.remove(CurrentMoves, ClearPrevious)

							for _,v in Player.Moveset:GetChildren() do
								v:Destroy()
							end
						end

						if RandomMoveset then
							table.remove(CurrentMoves, RandomMoveset)

							MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"), true)

						else
							MovesetHandlerModule:AddCustomMoveset(Player, CurrentMoves)

						end
					end
				end

				for Index, Character: Model in TouchedCharacters do
					if table.find(LastCharacters, Character) then continue end

					table.remove(TouchedCharacters, Index)
				end
			end)

			Part.Destroying:Once(function()
				Touched:Disconnect()
			end)
		end
	end
end



for _, Prompt: ProximityPrompt in pairs(CollectionService:GetTagged("SnowballPrompt")) do
	Prompt.Triggered:Connect(function(Player: Player)
		local Character = Player.Character
		if not Character or not Character.Parent or not Character.PrimaryPart or Character:HasTag("Ragdolled") or Character:HasTag("Stunned") then return end
		local PrimaryPart = Character.PrimaryPart

		local Humanoid: Humanoid = Character.Humanoid
		if Humanoid.Health <= 0 or Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local BodyVelocity

		local State = Instance.new("Accessory")
		State.Name = "HasSnowball"
		State.Parent = Character

		local StunObject = Instance.new("ObjectValue")
		StunObject.Value = Stun
		StunObject.Name = "Stun"
		StunObject.Parent = State


		local Snowball = Assets.Models.Projectiles.Snowball:Clone()
		Snowball.Snowball.Part0 = Character["Right Arm"]
		Snowball.Parent = Character
		Snowball:SetNetworkOwner(Player)


		local Animation
		if Humanoid.MoveDirection ~= Vector3.zero then
			Animation = Animations.Other["Run Collect Snowball"]

			BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
			BodyVelocity.Name = "moveme"
			BodyVelocity:SetAttribute("Speed", 17)
			BodyVelocity:SetAttribute("Fallout", 0.98)
			BodyVelocity:SetAttribute("End", 1)
			BodyVelocity.Parent = PrimaryPart
		else
			Animation = Animations.Other["Collect Snowball"]
		end

		local AnimationTrack, AnimationEvents = AnimationService:getAnimationTrack(Character, Animation)

		table.insert(AnimationEvents, AnimationTrack:GetMarkerReachedSignal("end"):Once(function()
			State:SetAttribute("Done", true)

			StunHandler:Unstun(Character, Stun)

			if BodyVelocity then
				BodyVelocity:Destroy()
			end


			Stun = StunHandler:Stun(Character, nil, true, 12.8, 0, true)
			StunObject.Value = Stun
		end))

		AnimationTrack.Stopped:Once(function()
			if not State:GetAttribute("Done") then
				StunHandler:Unstun(Character, Stun)

				Snowball:Destroy()
				State:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, Animation)

		SoundsModule:PlaySound(Sounds.Other["Snowball Collect"], PrimaryPart)
	end)
end



if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
	local SoloPvpZone = ZonesModule.new(workspace.Miscellaneous.PvP.Hitbox)
	SoloPvpZone.playerEntered:Connect(function(Player: Player)
		local PlayerRank = Player.leaderstats['Solo Rank'].Value

		QeueModule:AddPlayerToQeue(Player)

		for _, Player2: Player in QeueModule.SoloQeueTable do
			if not table.find(game.Players:GetPlayers(), Player2) then QeueModule.SoloQeueTable[Player2] = nil continue end

			local Player2Rank = Player2.leaderstats['Solo Rank'].Value
			if Player2 ~= Player and Player2:GetAttribute('Matched') ~= true and math.max(PlayerRank, Player2Rank) - math.min(PlayerRank, Player2Rank) <= 10 then
				Player:SetAttribute('Matched', true)
				Player2:SetAttribute('Matched', true)

				local matchCode = TpS:ReserveServer(workspace:GetAttribute("DuelsPlaceId"))
				TpS:TeleportToPrivateServer(workspace:GetAttribute("DuelsPlaceId"), matchCode, { Player, Player2 }, nil, { Players = 2; [Player.Name] = 'Spawn11'; [Player2.Name] = 'Spawn21'; })	

				ComSet:FireClient(Player, 'MatchFound', { Exceptions = { [Player2.Character] = true } })
				ComSet:FireClient(Player2, 'MatchFound', { Exceptions = { [Player.Character] = true } })

				break
			end
		end
	end)
	
	SoloPvpZone.playerExited:Connect(function(Player: Player)
		QeueModule:RemovePlayerFromQeue(Player)
	end)


	local DuoPvpZone = ZonesModule.new(workspace.Miscellaneous["PvP Twos"].Hitbox)
	DuoPvpZone.playerEntered:Connect(function(Player: Player)
		if Player:GetAttribute('MainTeammate') == false then return end

		if Player:GetAttribute('Teammate') == 'nil' or not Players:FindFirstChild(Player:GetAttribute('Teammate')) then
			ComSet:FireClient(Player, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = true; })

			return
		end


		local PlayerRank = Player.leaderstats['Duo Rank'].Value
		local MainDuoTable = QeueModule:AddDuoToQeue(Player, Players:FindFirstChild(Player:GetAttribute('Teammate')))

		for _, DuoTable: { Player } in QeueModule.DuoQeueTable do
			local Player2: Player = DuoTable.Main

			if not table.find(game.Players:GetPlayers(), Player2) then QeueModule.DuoQeueTable[Player2] = nil continue end

			local Player2Rank = Player2.leaderstats['Duo Rank'].Value
			if Player2 ~= Player and Player2:GetAttribute('Matched') ~= true and math.max(PlayerRank, Player2Rank) - math.min(PlayerRank, Player2Rank) <= 10 then
				Player:SetAttribute('Matched', true)
				Player2:SetAttribute('Matched', true)

				local matchCode = TpS:ReserveServer(workspace:GetAttribute("DuelsPlaceId"))
				TpS:TeleportToPrivateServer(workspace:GetAttribute("DuelsPlaceId"), matchCode, { MainDuoTable.Main, MainDuoTable.Teammate, DuoTable.Main, DuoTable.Teammate }, nil, { Teams = { [1] = { Main = MainDuoTable.Main.Name; Teammate = MainDuoTable.Teammate.Name; }; [2] = { Main = DuoTable.Main.Name; Teammate = DuoTable.Teammate.Name; }; }; Players = 4; [MainDuoTable.Main.Name] = 'Spawn11'; [MainDuoTable.Teammate.Name] = 'Spawn12'; [DuoTable.Main.Name] = 'Spawn21'; [DuoTable.Teammate.Name] = 'Spawn22'; })	

				ComSet:FireClient(Player, 'MatchFound', { Exceptions = { [MainDuoTable.Teammate.Character] = true; [Player2.Character] = true; [DuoTable.Teammate.Character] = true; } })
				ComSet:FireClient(MainDuoTable.Teammate, 'MatchFound', { Exceptions = { [Player.Character] = true; [Player2.Character] = true; [DuoTable.Teammate.Character] = true; } })

				ComSet:FireClient(Player2, 'MatchFound', { Exceptions = { [DuoTable.Teammate.Character] = true; [Player.Character] = true; [MainDuoTable.Teammate.Character] = true; } })
				ComSet:FireClient(DuoTable.Teammate, 'MatchFound', { Exceptions = { [Player.Character] = true; [Player2.Character] = true; [DuoTable.Teammate.Character] = true; } })

				break
			end
		end
	end)
	
	DuoPvpZone.playerExited:Connect(function(Player: Player)
		local lastTeammate = Player:GetAttribute('Teammate')
		Player:SetAttribute('Teammate', 'nil')
		ComSet:FireClient(Player, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = true; })

		local duoplayer: Player = Players:FindFirstChild(lastTeammate)
		local IndexName = Player
		if Player:GetAttribute('MainTeammate') == false then
			IndexName = duoplayer
			if not IndexName then return end
		end

		if duoplayer then
			duoplayer:SetAttribute('Teammate', 'nil')
			duoplayer.Character:PivotTo(workspace.Miscellaneous.SpawnLocations.SpawnLocation.CFrame)
			ComSet:FireClient(duoplayer, 'TriggerPartsCollide', { model = workspace.Miscellaneous["PvP Twos"].Hitbox, state = true; })
		end

		QeueModule:RemoveDuoFromQeue(IndexName)
	end)
end



print("SERVER LOADED " .. tick() - LoadStart)