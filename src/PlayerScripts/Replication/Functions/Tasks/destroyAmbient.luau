local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local TS = Constants.TS
local CollectionService = Constants.CollectionService
local VoxBreaker = Constants.VoxBreaker
local LocalPlayer = Constants.LocalPlayer
local MapOverlapParams = Constants.MapOverlapParams

local DestroyedParts = {}
shared.DestroyedParts = DestroyedParts

return function(Params)
	local CF: CFrame = Params.CFrame
	if typeof(CF) == "Instance" then
		CF = CF.CFrame * (Params.Offset or CFrame.new(0, 0, 0))
	end

	local Size = Params.Size

	local Velocity = Params.Velocity
	local LookAt = Params.LookAt
	local Multiplier = Params.Multiplier

	local function Destroy(Part, WaitTime)
		table.insert(DestroyedParts, Part)

		local RealVelocity = Velocity
		if LookAt then
			local LookVector = -CFrame.lookAt(Part.Position, LookAt).LookVector
			RealVelocity = Vector3.new(LookVector.X * Velocity.X, Velocity.Y, LookVector.Z * Velocity.Z)
		end

		local Clone = Part:Clone()

		Clone.CanCollide = false

		CollectionService:RemoveTag(Clone, "WindShake")
		Clone.CanTouch = false
		Clone.CanQuery = false
		Clone.CollisionGroup = "NonPColDebri"
		Clone.Parent = workspace.Debris
		Clone.Anchored = false
		Clone.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
		Debris:AddItem(Clone, 5)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity.Velocity = RealVelocity
		BodyVelocity.Parent = Clone
		Debris:AddItem(BodyVelocity, 0.1)

		task.delay(2.5, function()
			TS:Create(Clone, TweenInfo.new(2.5), { Size = Vector3.zero }):Play()
		end)

		Part.Transparency = 1
		Part.CanCollide = false
		Part.CanQuery = false

		task.delay(WaitTime or math.random(10, 18), function()
			TS:Create(Part, TweenInfo.new(1), { Transparency = 0 }):Play()
			if Part.Name ~= "Leaves" then
				Part.CanCollide = true
			end
			Part.CanQuery = true

			task.delay(1, function()
				local Index = table.find(DestroyedParts, Part)
				if Index then
					table.remove(DestroyedParts, Index)
				end
			end)
		end)
	end

	if Params.Voxels == true and LocalPlayer.Configuration["Destruction Physics"].Value == true then
		local DestroyableOverlapParams = OverlapParams.new()
		DestroyableOverlapParams.FilterType = Enum.RaycastFilterType.Include
		DestroyableOverlapParams.FilterDescendantsInstances = { workspace.Map.Destroyables }

		local PartsInBounds = VoxBreaker:CreateHitbox(Size, CF, Enum.PartType.Block, 2.5, 10)

		if #PartsInBounds > 0 then
			local GlassSoundCFrame, RockSoundCFrame, WoodSoundCFrame

			for _, Part: Part in PartsInBounds do
				if typeof(GlassSoundCFrame) ~= "CFrame" and Part.Material == Enum.Material.Glass then
					GlassSoundCFrame = Part.CFrame
				end
				if
					typeof(RockSoundCFrame) ~= "CFrame"
					and (Part.Material == Enum.Material.Slate or Part.Material == Enum.Material.DiamondPlate)
				then
					RockSoundCFrame = Part.CFrame
				end
				if
					typeof(WoodSoundCFrame) ~= "CFrame"
					and (Part.Material == Enum.Material.Wood or Part.Material == Enum.Material.WoodPlanks)
				then
					WoodSoundCFrame = Part.CFrame
				end

				Part.Anchored = false
				Part.CollisionGroup = "NonPColDebri"
				Part.CanQuery = false

				local GoalVelocity = Velocity
				if typeof(Multiplier) == "table" then
					GoalVelocity *= math.random(Multiplier[1], Multiplier[2])
				elseif typeof(Multiplier) == "number" then
					GoalVelocity *= Multiplier
				end

				Part.AssemblyLinearVelocity = GoalVelocity
				Part.AssemblyAngularVelocity = Vector3.new(
					math.random(Multiplier[1], Multiplier[2]),
					math.random(Multiplier[1], Multiplier[2]),
					math.random(Multiplier[1], Multiplier[2])
				)
			end
		end

		return
	end

	local PartsInBounds = Params.Parts or workspace:GetPartBoundsInBox(CF, Size, MapOverlapParams)
	if #PartsInBounds > 0 then
		for _, Part: Part in PartsInBounds do
			if Part and Part.Parent then
				if
					Part:IsDescendantOf(workspace.Map.Destroyables)
					and (not Params.CategoryOnly or Part:FindFirstAncestor(Params.CategoryOnly))
					and not table.find(DestroyedParts, Part)
				then
					if Part.Parent.Name == "Tree" then
						local WaitTime = math.random(10, 18)

						for _, TreePart in Part.Parent:GetChildren() do
							local Index = table.find(PartsInBounds, TreePart)
							if Index then
								table.remove(PartsInBounds, Index)
							end

							Destroy(TreePart, WaitTime)
						end
					else
						Destroy(Part)
					end
				end
			end
		end
	end
end
