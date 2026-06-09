local Debris            = game:GetService("Debris")
local TweenService      = game:GetService("TweenService")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules    = ServerStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)

local MoveAnims            = ServerStorage.Assets.Animations.Moves
local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local function freezeWorld(exceptCharacter)
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= exceptCharacter and model:FindFirstChild("HumanoidRootPart") then
			for _, part in pairs(model:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored then
					part.Anchored = true
				elseif part:IsA("Humanoid") then
					part.WalkSpeed = 0
					part.JumpPower = 0
					local animator = part:FindFirstChildOfClass("Animator")
					if animator then
						for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
							track:AdjustSpeed(0)
						end
					end
				end
			end
		end
	end
end

local function unfreezeWorld()
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
			for _, part in pairs(model:GetDescendants()) do
				if part:IsA("BasePart") and part.Anchored then
					part.Anchored = false
				elseif part:IsA("Humanoid") then
					part.WalkSpeed = 16
					part.JumpPower = 50
					local animator = part:FindFirstChildOfClass("Animator")
					if animator then
						for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
							track:AdjustSpeed(1)
						end
					end
				end
			end
		end
	end
end

return {
	Start = function(Player: Player, Tool: Tool)
		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Dio.Timestop.Start
		local StartTrack     = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents    = {}

		StartEvents["Emit"] = StartTrack:GetMarkerReachedSignal("Emit"):Once(function()

			-- Freeze all other characters
			freezeWorld(Character)
			iFramesService:AddAlliFrames(Character)

			-- Tell all clients to show VFX + B&W filter
			ReplicateEffects_Set:FireAllClients("DioTimestop", {
				Stage = "stop",
				char  = Character,
				hrpCF = HumRP.CFrame,
			})

			-- Unfreeze after 5s + 2s buffer
			task.delay(5, function()
				ReplicateEffects_Set:FireAllClients("DioTimestop", {
					Stage = "end",
					char  = Character,
				})

				task.wait(2)
				unfreezeWorld()
				iFramesService:RemoveAlliFrames(Character)
			end)
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("DioTimestop", {
			Stage = "startup",
			char  = Character,
			hrpCF = HumRP.CFrame,
		})
	end,
}