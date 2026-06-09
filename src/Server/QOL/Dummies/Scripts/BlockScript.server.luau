local Character = script.Parent
local Humanoid = Character.Humanoid
local RNS = game["Run Service"]
local ServerStorage = game.ServerStorage
local AnimationService = require(ServerStorage.Modules.AnimationService)
local Animations = ServerStorage.Assets.Animations


RNS.Heartbeat:Connect(function()
	if Character:HasTag('CantBlock') or Character:HasTag('Blocking') or Character:HasTag('Stunned') then return end
	
	local Anim = Animations.Combat.Block
	local BlockAnimTrack = AnimationService:getAnimationTrack(Character, Anim)
	
	
	BlockAnimTrack.Stopped:Once(function()
		Character:RemoveTag('Blocking')
	end)
	
	local Died = Humanoid.Died:Connect(function()
		Character:RemoveTag('Blocking')
	end)
	
	
	AnimationService:playAnimation(Character, Anim)
	Character:AddTag('Blocking')
end)