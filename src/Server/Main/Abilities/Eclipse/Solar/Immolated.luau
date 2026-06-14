local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)

local DURATION = 8
local REFLECT_DAMAGE = 10
local SLOW_MULT = 0.55
local INFERNO_DURATION = 3

local function applyInferno(EnemyCharacter)
	local existing = EnemyCharacter:GetAttribute("Inferno")
	EnemyCharacter:SetAttribute("Inferno", true)
	if existing then
		return
	end

	local tickStart = tick()
	local duration = INFERNO_DURATION
	local dotInterval = 0.5
	local dotDamage = 3

	task.spawn(function()
		while EnemyCharacter and EnemyCharacter.Parent and EnemyCharacter:GetAttribute("Inferno") do
			if tick() - tickStart >= duration then
				break
			end
			local Hum = EnemyCharacter:FindFirstChild("Humanoid")
			if not Hum or Hum.Health <= 0 then
				break
			end
			Hum:TakeDamage(dotDamage)
			task.wait(dotInterval)
		end
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)

	task.delay(duration, function()
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)
end

local function cleanUp(Character, Humanoid, baseWalkSpeed, damageLogConnection, diedConnection)
	if damageLogConnection then
		damageLogConnection:Disconnect()
	end
	if diedConnection then
		diedConnection:Disconnect()
	end

	Character:SetAttribute("Immolated", nil)
	iFramesService:RemoveiFrames(Character, "Strong")

	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = baseWalkSpeed
	end
end

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		if Character:GetAttribute("Immolated") then
			return
		end

		local baseWalkSpeed = Humanoid.WalkSpeed

		Character:SetAttribute("Immolated", true)
		iFramesService:AddStrongiFrames(Character)
		Humanoid.WalkSpeed = baseWalkSpeed * SLOW_MULT

		local damageLogConnection
		local diedConnection

		damageLogConnection = Character.ChildAdded:Connect(function(Child)
			if Child.Name ~= "DamagedLog" then
				return
			end
			if not Child:IsA("ObjectValue") then
				return
			end
			if not Character:GetAttribute("Immolated") then
				return
			end

			local Attacker = Child.Value
			if not Attacker or not Attacker.Parent then
				return
			end

			local AttackerHumanoid = Attacker:FindFirstChild("Humanoid")
			local AttackerHumRP = Attacker:FindFirstChild("HumanoidRootPart")
			if not AttackerHumanoid or not AttackerHumRP then
				return
			end
			if AttackerHumanoid.Health <= 0 then
				return
			end

			if (AttackerHumRP.Position - HumRP.Position).Magnitude > 12 then
				return
			end

			DamageHandler:TakeDamage(
				Character,
				AttackerHumanoid,
				REFLECT_DAMAGE,
				nil,
				nil,
				false,
				false,
				true,
				false,
				false,
				nil,
				nil
			)

			applyInferno(Attacker)
		end)

		diedConnection = Humanoid.Died:Once(function()
			cleanUp(Character, Humanoid, baseWalkSpeed, damageLogConnection, diedConnection)
		end)

		task.delay(DURATION, function()
			if not Character or not Character.Parent then
				return
			end
			if not Character:GetAttribute("Immolated") then
				return
			end
			cleanUp(Character, Humanoid, baseWalkSpeed, damageLogConnection, diedConnection)
		end)
	end,
}
