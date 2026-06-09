-- Modules
local IFramesService = require(script.Parent.iFramesService)
local AnimationService = require(script.Parent.AnimationService)
local StunHandler = require(script.Parent.StunHandler)

-- Functions
return {
	UsingMove = function(
		Tag: number,
		Player: Player,
		EnemyPlayer: Player,
		Parameters: {
			Weld: any,
			UserIFrames: any,
			VictimIFrames: any,
			UserRotate: any,
			EnemyRotate: any,
			UserAnimation: any,
			VictimAnimation: any,
			UserStun: any,
			VictimStun: any,
		}
	)
		local Character = Player.Character
		local EnemyCharacter
		if EnemyPlayer then
			EnemyCharacter = EnemyPlayer.Character
		end

		local Bind = Instance.new("Folder")
		Bind.Name = Tag
		Bind.Parent = workspace.Thrown

		local Weld = Parameters.Weld

		local UserIFrames = Parameters.UserIFrames
		local VictimIFrames = Parameters.VictimIFrames

		local UserRotate = Parameters.UserRotate
		local EnemyRotate = Parameters.EnemyRotate

		local UserAnimation = Parameters.UserAnimation
		local VictimAnimation = Parameters.VictimAnimation

		local UserStun = Parameters.UserStun
		local VictimStun = Parameters.VictimStun

		local PlayerConnection = Player.Destroying:Once(function()
			Bind:Destroy()

			if Weld then
				pcall(function()
					Weld:Stop()
				end)
			end

			if VictimIFrames then
				if typeof(VictimIFrames) == "table" then
					IFramesService:RemoveiFrames(EnemyCharacter, VictimIFrames)
				else
					IFramesService:RemoveAlliFrames(EnemyCharacter)
				end
			end

			if EnemyRotate then
				EnemyCharacter:RemoveTag("CantRotate")
			end

			if VictimAnimation then
				local AnimationTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				if AnimationTrack then
					AnimationTrack:Stop()
				end
			end

			if VictimStun then
				StunHandler:Unstun(EnemyCharacter, VictimStun)
			end
		end)

		local EnemyPlayerConnection
		if EnemyPlayer then
			EnemyPlayerConnection = EnemyPlayer.Destroying:Once(function()
				Bind:Destroy()

				if Weld then
					pcall(function()
						Weld:Stop()
					end)
				end

				if UserIFrames then
					if typeof(UserIFrames) == "table" then
						IFramesService:RemoveiFrames(Character, UserIFrames)
					else
						IFramesService:RemoveAlliFrames(Character)
					end
				end

				if UserRotate then
					Character:RemoveTag("CantRotate")
				end

				if UserAnimation then
					local AnimationTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
					if AnimationTrack then
						AnimationTrack:Stop()
					end
				end

				if UserStun then
					StunHandler:Unstun(Character, UserStun)
				end
			end)
		end

		Bind.Destroying:Once(function()
			PlayerConnection:Disconnect()
			if EnemyPlayerConnection then
				EnemyPlayerConnection:Disconnect()
			end
		end)

		return Bind
	end,

	DoEndLag = function(Player: Player, Stun: any, Time: number)
		local Character = Player.Character
		if not Character then
			return
		end

		task.delay(Time or 0.3, function()
			StunHandler:Unstun(Character, Stun)
			IFramesService:RemoveAlliFrames(Character)
		end)
	end,

	SkillText = function(Player: Player, Name)
		print("RemovedSkilltexts")
	end,
}
