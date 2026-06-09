return {
	Start = function(Player: Player, Tool: Tool)
		local Debris = game:GetService("Debris")
		local ServerStorage = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		local ServerModules = ServerStorage.Modules
		local ReplicatedModules = ReplicatedStorage.Modules
		local RemotesContainer = ReplicatedStorage.Remotes

		local StunHandler      = require(ServerModules.StunHandler)
		local HitboxHandler    = require(ServerModules.HitboxHandler)
		local DamageHandler    = require(ServerModules.DamageHandler)
		local AnimationService = require(ServerModules.AnimationService)
		local iFramesService   = require(ServerModules.iFramesService)

		local MoveAnims            = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		-- [[ Stun + lock caster ]]:
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		-- [[ Caster animation ]]:
		local SliceAnim = MoveAnims.Sukuna["Cleave Rush"].Slice
		AnimationService:playAnimation(Character, SliceAnim)

		-- [[ Notify clients — start VFX ]]:
		ReplicateEffects_Set:FireAllClients("SukunaSlice", {
			char  = Character,
			stage = "Start",
			hrpCF = HumRP.CFrame,
		})

		-- [[ Continuous hit loop — fires every 0.2s for the duration of the anim ]]:
		local active = true

		task.delay(0.35, function()
			task.spawn(function()
				while active do
					task.wait(0.2)
					if not active then break end

					local hitContent = workspace:GetPartBoundsInBox(
						HumRP.CFrame * CFrame.new(0, 0, -3),
						Vector3.new(7, 7, 7)
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

							-- [[ Per-hit damage ]]:
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, false, false, true, nil, nil)

							-- [[ Random hit animation ]]:
							local hitAnims   = MoveAnims.Sukuna["Cleave Rush"]
							local roll       = math.random(1, 2)
							local chosenAnim = roll == 1 and hitAnims.Hit1 or hitAnims.Hit2
							AnimationService:playAnimation(EnemyCharacter, chosenAnim)

							-- [[ Per-hit VFX ]]:
							ReplicateEffects_Set:FireAllClients("SukunaSlice", {
								char       = Character,
								enemy      = EnemyCharacter,
								stage      = "Hit",
								hrpCF      = HumRP.CFrame,
								enemyHrpCF = EnemyHumRP.CFrame,
							})
						end
					end
				end
			end)
		end)

		-- [[ Cleanup — stop loop, unstun, fire End ]]:
		task.delay(2.85, function()
			active = false

			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)

			ReplicateEffects_Set:FireAllClients("SukunaSlice", {
				char  = Character,
				stage = "End",
			})
		end)
	end,
}