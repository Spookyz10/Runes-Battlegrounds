local module = {}

local ModulesFolder = script.Parent

local StunHandler = require(ModulesFolder.StunHandler)
local Bodymover = require(ModulesFolder.BodymoverService)
local AnimationService = require(ModulesFolder.AnimationService)

local knockAnim = ModulesFolder.Parent.Assets.Animations.Other.Knockback

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

function module:Knockback(
	Character,
	Velocity,
	LookAtCharacter,
	CustomAnimation,
	customTime,
	to,
	ringFX,
	waitForFloor,
	checkAir
)
	local HumRP: BasePart = Character.HumanoidRootPart
	local Humanoid: Humanoid = Character.Humanoid

	local tweenTime
	if Humanoid.Health > 0 then
		local AnimTrack: AnimationTrack
		local AnimEvents: { RBXScriptConnection }

		if CustomAnimation then
			AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, CustomAnimation)
			tweenTime = AnimTrack.Length
			StunHandler:Stun(Character, tweenTime, true, 0, 0, true)
		else
			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, knockAnim)

			tweenTime = 0.6

			table.insert(
				AnimEvents,
				AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
					local inAir = Character:FindFirstChild("inAir")
					if inAir and checkAir ~= false then
						AnimTrack:AdjustSpeed(0)

						inAir.Destroying:Once(function()
							if AnimTrack.IsPlaying == false then
								return
							end

							AnimTrack:AdjustSpeed(1)

							if waitForFloor ~= false and typeof(Velocity) == "Vector3" then
								Bodymover:Knockback(Character, {
									KnockbackType = "VelocityTweenDown",
									MaxForce = Vector3.new(1, 0, 1) * 100000,
									Velocity = Velocity,
									Time = customTime or tweenTime,
								})
							end
						end)
					else
						if waitForFloor ~= false then
							Bodymover:Knockback(Character, {
								KnockbackType = "VelocityTweenDown",
								MaxForce = Vector3.new(1, 0, 1) * 100000,
								Velocity = Velocity,
								Time = customTime or tweenTime,
							})
						end
					end
				end)
			)

			table.insert(
				AnimEvents,
				AnimTrack.Stopped:Once(function()
					Character:RemoveTag("Knockbacked")
					Character:RemoveTag("CantRotate")

					if Stun then
						StunHandler:Unstun(Character, Stun)
						Stun = nil
					end

					for _, v in HumRP:GetChildren() do
						if v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end
				end)
			)
		end

		if LookAtCharacter then
			Bodymover:makeEnemyFaceCharacter(Character, LookAtCharacter, to)
		end
		if typeof(Velocity) == "Vector3" then
			if waitForFloor ~= false then
				Bodymover:Knockback(
					Character,
					{ KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = Velocity }
				)
			else
				Bodymover:Knockback(Character, {
					KnockbackType = "VelocityTweenDown",
					MaxForce = Vector3.new(1, 1, 1) * 100000,
					Velocity = Velocity,
					Time = customTime or tweenTime,
				})
			end
		end

		if not CustomAnimation and checkAir ~= false then
			ModulesFolder.Parent.Bindables.AirDetector:Fire(Character, nil, nil, -3)
		end
	elseif typeof(Velocity) == "Vector3" then
		Bodymover:Knockback(
			Character,
			{ KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = Velocity }
		)
	end

	Character:AddTag("Knockbacked")
	Character:AddTag("CantRotate")
	task.delay(tweenTime, function()
		Character:RemoveTag("CantRotate")
	end)
end

return module
