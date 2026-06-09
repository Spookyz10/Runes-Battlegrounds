return {
	Start = function(Player: Player, Tool: Tool)
		local Debris = game:GetService("Debris")
		local ServerStorage = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		local ServerModules    = ServerStorage.Modules
		local RemotesContainer = ReplicatedStorage.Remotes

		local StunHandler      = require(ServerModules.StunHandler)
		local DamageHandler    = require(ServerModules.DamageHandler)
		local AnimationService = require(ServerModules.AnimationService)
		local iFramesService   = require(ServerModules.iFramesService)

		local MoveAnims            = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		-- [[ Caster animation ]]:
		local SliceAnim = MoveAnims.Sukuna["Quadruple Dismantle"].Slice
		AnimationService:playAnimation(Character, SliceAnim)

		-- [[ Notify clients — wind-up VFX ]]:
		ReplicateEffects_Set:FireAllClients("SukunaQuadDismantle", {
			char  = Character,
			stage = "Start",
			hrpCF = HumRP.CFrame,
		})

		-- [[ Helper — single strike: hitbox scan + damage + VFX fire ]]:
		local function doStrike(strikeIndex, offset, size)
			local hitContent = workspace:GetPartBoundsInBox(
				HumRP.CFrame * CFrame.new(0, 0, offset),
				size
			)
			local hitList = {}

			for _, v in pairs(hitContent) do
				local EnemyCharacter = v.Parent
				local EnemyHumanoid  = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP     = EnemyCharacter:FindFirstChild("HumanoidRootPart")

				if EnemyHumanoid and EnemyHumRP
					and EnemyCharacter ~= Character
					and not hitList[EnemyHumanoid]
					and not iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
				then
					hitList[EnemyHumanoid] = true

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, false, false, false, nil, nil)

					AnimationService:playAnimation(EnemyCharacter, MoveAnims.Sukuna["Quadruple Dismantle"].Hit)

					ReplicateEffects_Set:FireAllClients("SukunaQuadDismantle", {
						char        = Character,
						enemy       = EnemyCharacter,
						stage       = "Hit",
						strikeIndex = strikeIndex,
						hrpCF       = HumRP.CFrame,
						enemyHrpCF  = EnemyHumRP.CFrame,
					})
				end
			end
		end

		-- [[ 4 strikes — timings match original: 0.2, 0.6, 1.05, 1.35 ]]:
		task.delay(0.2,  function() doStrike(1, -3, Vector3.new(7, 7, 7))  end)
		task.delay(0.6,  function() doStrike(2, -3, Vector3.new(9, 9, 9))  end)
		task.delay(1.05, function() doStrike(3, -3, Vector3.new(7, 7, 7))  end)
		task.delay(1.35, function() doStrike(4, -3, Vector3.new(9, 9, 9))  end)

		-- [[ Cleanup ]]:
		task.delay(2.0, function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)

			ReplicateEffects_Set:FireAllClients("SukunaQuadDismantle", {
				char  = Character,
				stage = "End",
			})
		end)
	end,
}