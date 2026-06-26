local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)

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

		iFramesService:AddAlliFrames(Character)

		local hitList = {}

		HitboxHandler:SimpleOnce(
			HumRP.CFrame,
			Vector3.new(30, 30, 30),
			CFrame.new(0, 0, 0),
			{ Character },
			nil,
			nil,
			function(enemyChar)
				if table.find(hitList, enemyChar) then
					return
				end
				local EnemyHum = enemyChar:FindFirstChild("Humanoid")
				if not EnemyHum or EnemyHum.Health <= 0 then
					return
				end
				if iFramesService:HasiFrame(enemyChar, Tool.Name) then
					return
				end
				table.insert(hitList, enemyChar)
			end
		)

		for _, enemyChar in hitList do
			local EnemyHum = enemyChar:FindFirstChild("Humanoid")
			if EnemyHum and EnemyHum.Health > 0 then
				DamageHandler:TakeDamage(Character, EnemyHum, 20, 3, nil, false, false, true, true, false, nil, nil)
			end
		end
	end,
}
