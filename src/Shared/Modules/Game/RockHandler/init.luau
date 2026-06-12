local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local l_TweenService_0 = game:GetService("TweenService")
local v2 = {}
local v4 = require(l_ReplicatedStorage_0.Modules.Game.Utility)
local v5 = Random.new()
local l_Assets_0 = script.Assets
local v7 = require(script.Presets)
local v8 = {
	Barrier = true
}

local v9 = {
	Amount = 6, 
	Timing = {
		In = {
			Min = 0.1, 
			Max = 0.2
		}, 
		Idle = {
			Min = 4.7, 
			Max = 5.1
		}, 
		Out = {
			Min = 1.6, 
			Max = 2.2
		}
	}, 
	Distance = 3, 
	Exposure = {
		Min = 0.6, 
		Max = 0.8
	}, 
	Angle = {
		Min = -30, 
		Max = 30
	}, 
	LookAt = {
		Min = -3, 
		Max = 3
	}, 
	BaseX = 3, 
	BaseY = 1.5, 
	BaseZ = 2.1, 
	SizeMultiplier = 1, 
	CastShadow = true, 
	CraterSmoke = true, 
	Rotation = {
		Min = {
			X = -0.20943951023931956, 
			Y = -0.20943951023931956, 
			Z = -0.20943951023931956
		}, 
		Max = {
			X = 0.20943951023931956, 
			Y = 0.20943951023931956, 
			Z = 0.20943951023931956
		}
	}
}

v9.__index = v9
v2.GetAdorneeCFrame = function(v10)
	if typeof(v10) == "CFrame" then
		return v10
	elseif typeof(v10) == "Instance" then
		return v10.CFrame
	elseif typeof(v10) == "Vector3" then
		return CFrame.new(v10)
	else
		error("Could not get CFrame from Adornee")
		return
	end
end

v2.SlightlyBrightenColor = function(v11)
	return v11
end

v2.GenerateRandomOrientation = function(v12)
	local v13 = v5:NextUnitVector() * 360
	if v12 then
		return CFrame.Angles(v13.X, v13.Y, v13.Z)
	else
		return v13
	end
end

v2.MatchWithRay = function(v14, v15)
	local l_Instance_0 = v15.Instance
	if not l_Instance_0:GetAttribute("RockIgnoreTransparency") then
		v14.Transparency = l_Instance_0.Transparency
	end
	v14.Reflectance = l_Instance_0.Reflectance
	v14.Color = v2.SlightlyBrightenColor(l_Instance_0.Color)
	v14.Material = l_Instance_0.Material
	v14.MaterialVariant = l_Instance_0.MaterialVariant
end

v2.Rocks = function(v17, v18)
	local v19 = v7[v17]
	if not v19 then
		return
	else
		local v20 = v2.GetAdorneeCFrame(v18)
		for v21 = -1, 1, 2 do
			local v22 = nil
			v22 = if v19.Messy then v20 * CFrame.new(v5:NextNumber(-v19.Spacing, v19.Spacing), 0, v5:NextNumber(-v19.Spacing, v19.Spacing)) else v20 * CFrame.new(v19.Spacing * v21, 0, 0)
			local v23 = workspace:Raycast(v22.Position + Vector3.new(0, 2, 0, 0), Vector3.new(-0, -1, -0, -0) * (v19.RaycastDistance + 2), v4.VisualParams)

			if v23 then
				local v24 = l_Assets_0.Debree:Clone()
				v2.MatchWithRay(v24, v23)
				if v19.Size then
					v24.Size = Vector3.new(1, 1, 1, 0) * v19.Size
				end
				local l_Position_0 = v23.Position
				local v26 = l_Position_0 - Vector3.new(0, 1, 0, 0) * v24.Size.Y
				v24.Position = v26
				v24.Orientation = v2.GenerateRandomOrientation()
				v24.Parent = workspace.Thrown
				local v27 = TweenInfo.new(v19.FadeInTime or v5:NextNumber(0.25, 0.4))
				l_TweenService_0:Create(v24, v27, {
					Position = l_Position_0
				}):Play()
				task.delay(3 + v5:NextNumber(-0.5, 0.5), function() --[[ Line: 163 ]]
					-- upvalues: v5 (ref), l_TweenService_0 (ref), v24 (copy), v26 (copy)
					local v28 = TweenInfo.new(v5:NextNumber(1, 2))
					local v29 = l_TweenService_0:Create(v24, v28, {
						Position = v26
					})
					v29:Play()
					v29.Completed:Wait()
					v24:Destroy()
				end)
			end
		end
		return
	end
end

v2.Rockst = function(v30, v31, v32)
	local v33 = workspace:Raycast(v30 - v31 / 2, v31, v4.VisualParams)
	if v33 ~= nil then
		local v34 = v32.Count or 5
		local v35 = v32.XZVelocity or NumberRange.new(0.75, 1)
		local v36 = v32.YVelocity or NumberRange.new(0.75, 1.25)
		for _ = 1, v34 do
			local v38 = l_Assets_0.FlyingDebree:Clone()
			v2.MatchWithRay(v38, v33)
			v38.Size = Vector3.new(1, 1, 1, 0) * v5:NextNumber(table.unpack(v32.Size))
			v38.CFrame = CFrame.lookAt(v33.Position, v33.Position - v33.Normal) + Vector3.new(0, 1.5, 0, 0) + Vector3.new(v5:NextNumber(-1, 1), 0, v5:NextNumber(-1, 1)) * (v32.SpawnVariance or 5)
			v32.Velocity = v32.Velocity * v5:NextNumber(0.75, 1)
			local l_v38_Mass_0 = v38:GetMass()
			local l_Unit_0 = (v5:NextUnitVector() + Vector3.new(0, 1, 0, 0)).Unit
			v38.AssemblyLinearVelocity = l_v38_Mass_0 * Vector3.new(l_Unit_0.X * v5:NextNumber(v35.Min, v35.Max) * v32.Velocity, l_Unit_0.Y * v5:NextNumber(v36.Min, v36.Max) * v32.Velocity, l_Unit_0.Z * v5:NextNumber(v35.Min, v35.Max) * v32.Velocity)
			v38.AssemblyAngularVelocity = l_v38_Mass_0 * Vector3.new(v5:NextNumber(-5, 5), v5:NextNumber(-5, 5), v5:NextNumber(-5, 5))
			v38.Parent = workspace.Thrown
			task.delay((v32.Lifetime or 3) + v5:NextNumber(-0.5, 0.5), function()
				local v41 = TweenInfo.new(v5:NextNumber(1, 2))
				local v42 = l_TweenService_0:Create(v38, v41, {
					Size = Vector3.new(0, 0, 0, 0)
				})
				v42:Play()
				v42.Completed:Wait()
				v38:Destroy()
			end)
		end
	end
end

local function v44(v43)
	return CFrame.Angles(v5:NextNumber(v43.Min.X, v43.Max.X), v5:NextNumber(v43.Min.Y, v43.Max.Y), v5:NextNumber(v43.Min.Z, v43.Max.Z))
end

v2.Crater = function(v57, v58, v59)
	local v60 = setmetatable(v59 or {}, v9)
	local v61 = workspace:Raycast(v57 - v58 / 2, v58, v4.VisualParams)
	local v62 = false
	if v61 then
		v62 = v61.Instance:HasTag("DestructibleDescendant") or v61.Instance:HasTag("Destructible")
	end
	local v63 = false
	if v61 ~= nil then
		v63 = v61.Instance.CanCollide and not v62 and not v8[v61.Instance.Name]
	end
	if not v63 then
		return
	else
		v63 = if v58.Magnitude < 1.0E-7 then Vector3.new(0, 0, 0, 0) else v58.Unit
		local l_Distance_0 = v60.Distance
		v62 = v63 * ((if typeof(l_Distance_0) == "table" then l_Distance_0.Max else l_Distance_0) + v58.Magnitude - v61.Distance)
		for v65 = 1, v60.Amount do
			local l_Normal_0 = v61.Normal
			local l_Distance_1 = v60.Distance
			l_Distance_0 = l_Normal_0 * if typeof(l_Distance_1) == "table" then if typeof(l_Distance_1) == "table" then v5:NextNumber(l_Distance_1.Min, l_Distance_1.Max) else l_Distance_1 else l_Distance_1
				l_Normal_0 = v61.Position + l_Distance_0
				local v68 = CFrame.lookAt(l_Normal_0, l_Normal_0 - l_Distance_0)
				local l_Angles_0 = CFrame.Angles
				local v70 = 1.5707963267948966
				local v71 = v65 * (360 / v60.Amount)
				local l_Angle_0 = v60.Angle
				local v73 = v68 * l_Angles_0(v70, math.rad(v71 + if typeof(l_Angle_0) == "table" then v5:NextNumber(l_Angle_0.Min, l_Angle_0.Max) else l_Angle_0), 0) * CFrame.new(0, -l_Distance_0.Magnitude - v58.Magnitude, l_Distance_0.Magnitude + v58.Magnitude)
				l_Distance_1 = workspace:Raycast(l_Normal_0, v73.Position - l_Normal_0, v4.VisualParams)
				l_Angles_0 = false
				if l_Distance_1 then
					l_Angles_0 = l_Distance_1.Instance:HasTag("DestructibleDescendant") or l_Distance_1.Instance:HasTag("Destructible")
				end
				v68 = false
				if l_Distance_1 ~= nil then
					v68 = l_Distance_1.Instance.CanCollide and not l_Angles_0 and not v8[l_Distance_1.Instance.Name]
				end
				if v68 then
					v68 = Vector3.new(v60.BaseX, v60.BaseY, v60.BaseZ) * v60.SizeMultiplier
					l_Angles_0 = v44(v60.Rotation)
					local l_Position_1 = l_Distance_1.Position
					v71 = l_Distance_1.Normal
					l_Angle_0 = v60.Exposure
					v70 = l_Position_1 - v71 * if typeof(l_Angle_0) == "table" then if typeof(l_Angle_0) == "table" then v5:NextNumber(l_Angle_0.Min, l_Angle_0.Max) else l_Angle_0 else l_Angle_0
						local l_Position_2 = v61.Position
						local l_Normal_1 = l_Distance_1.Normal
						local l_LookAt_0 = v60.LookAt
						l_Position_1 = l_Position_2 - l_Normal_1 * if typeof(l_LookAt_0) == "table" then v5:NextNumber(l_LookAt_0.Min, l_LookAt_0.Max) else l_LookAt_0
						l_Position_2 = CFrame.lookAt(v70, l_Position_1, l_Distance_1.Normal)
						v71 = l_Position_2 - l_Distance_1.Normal * v68
						l_Normal_1 = v60.Timing.In ~= 0
						l_Angle_0 = l_Assets_0.Debree:Clone()
						v2.MatchWithRay(l_Angle_0, l_Distance_1)
						l_Angle_0.CFrame = l_Normal_1 and v71 or l_Position_2
						l_Angle_0.Size = v68
						l_Angle_0.CastShadow = v60.CastShadow
						if v60.CraterSmoke then
							l_LookAt_0 = v68.X + v68.Y + v68.Z
							local v78 = l_Assets_0.Smoke:Clone()
							v78.Size = NumberSequence.new(l_LookAt_0)
							v78.Speed = NumberRange.new(l_LookAt_0 * 10)
							v78.Color = ColorSequence.new(l_Angle_0.Color)
							v78.Parent = l_Angle_0
							v78:Emit((math.clamp(math.round(l_LookAt_0) - 1, 1, 10)))
						end
						l_Angle_0.Parent = workspace.Thrown
						if l_Normal_1 then
							l_LookAt_0 = l_TweenService_0
							local l_l_Angle_0_0 = l_Angle_0
							local l_new_0 = TweenInfo.new
							local l_In_0 = v60.Timing.In
							l_LookAt_0:Create(l_l_Angle_0_0, l_new_0(if typeof(l_In_0) == "table" then v5:NextNumber(l_In_0.Min, l_In_0.Max) else l_In_0), {
								CFrame = l_Position_2
							}):Play()
						end
						l_LookAt_0 = task.delay
						local l_Idle_0 = v60.Timing.Idle
						l_LookAt_0(if typeof(l_Idle_0) == "table" then v5:NextNumber(l_Idle_0.Min, l_Idle_0.Max) else l_Idle_0, function() --[[ Line: 321 ]]
							-- upvalues: l_TweenService_0 (ref), l_Angle_0 (copy), v60 (copy), v5 (ref), v71 (copy)
							local l_l_TweenService_0_0 = l_TweenService_0
							local l_l_Angle_0_1 = l_Angle_0
							local l_new_1 = TweenInfo.new
							local l_Out_0 = v60.Timing.Out
							l_l_TweenService_0_0 = l_l_TweenService_0_0:Create(l_l_Angle_0_1, l_new_1(if typeof(l_Out_0) == "table" then v5:NextNumber(l_Out_0.Min, l_Out_0.Max) else l_Out_0), {
								CFrame = v71, 
								Size = Vector3.new(0, 0, 0, 0)
							})
							l_l_TweenService_0_0:Play()
							l_l_TweenService_0_0.Completed:Once(function() --[[ Line: 328 ]]
								-- upvalues: l_Angle_0 (ref)
								l_Angle_0:Destroy()
							end)
						end)
					end
				end
				return
			end
		end
		local v87 = {
			Amount = 15, 
			Spacing = 1.5, 
			Angle = 1.9198621771937625, 
			Size = 1, 
			SizeIndex = 0.2, 
			RandomJitter = 1.25, 
			ExposeLevel = -0.5
		}
		v87.__index = v87
		local function v98(v88, v89, v90, v91)
			local v92 = v89 * CFrame.Angles(0, v88.Angle * v90 / 2, 0) * CFrame.new(v5:NextNumber(-v88.RandomJitter, v88.RandomJitter), 0, -v88.Spacing * v91)
			local v93 = workspace:Raycast(v92.Position + Vector3.new(0, 2, 0, 0), Vector3.new(-0, -25, -0, -0), v4.VisualParams)
			if v93 then
				local v94 = l_Assets_0.RockLine:Clone()
				v2.MatchWithRay(v94, v93)
				v94.Position = v93.Position - Vector3.new(0, 1, 0, 0) * -v88.ExposeLevel
				v94.Orientation = v2.GenerateRandomOrientation()
				local v95 = Vector3.new(1, 1, 1, 0) * (v88.Size + v91 * v88.SizeIndex)
				if v88.NoTween then
					v94.Size = v95
				else
					l_TweenService_0:Create(v94, TweenInfo.new(0.3), {
						Size = v95
					}):Play()
				end
				if not v88.NoSmoke then
					local v96 = l_Assets_0.Smoke:Clone()
					v96.Color = ColorSequence.new(v94.Color)
					v96.Parent = v94
					v96:Emit(v95.X * v95.Y * v95.Z / 4)
				end
				v94.Parent = workspace.Thrown
				task.delay(2, function()
					local v97 = l_TweenService_0:Create(v94, TweenInfo.new(3), {
						Size = Vector3.new(0, 0, 0, 0)
					})
					v97:Play()
					v97.Completed:Wait()
					v94:Destroy()
				end)
			end
		end	
		v2.RockLines = function(v99, v100)
			setmetatable(v100, v87)
			for v101 = 1, v100.Amount do
				v98(v100, v99, -1, v101)
				v98(v100, v99, 1, v101)
				if v100.TimeTilNextRock then
					task.wait(v100.TimeTilNextRock)
				end
			end
		end

		local v102 = {
			Amount = 15, 
			Spacing = 3, 
			Angle = 1.9198621771937625, 
			Size = 1, 
			SizeIndex = 0.2, 
			RandomJitter = 1.25, 
			ExposeLevel = -0.5, 
			SideSpacing = 8
		}
		v102.__index = v102
		v2.RegularRockLines = function(v103, v104)
			setmetatable(v104, v102)
			for v105 = 1, v104.Amount do
				for v106 = -1, 1, 2 do
					local v107 = v103 * CFrame.Angles(0, v104.Angle * v106 / 2, 0) * CFrame.new(v104.SideSpacing * v106 + v5:NextNumber(-v104.RandomJitter, v104.RandomJitter), 0, -v104.Spacing * v105)
					local v108 = workspace:Raycast(v107.Position + Vector3.new(0, 2, 0, 0), Vector3.new(-0, -25, -0, -0), v4.VisualParams)
					if v108 then
						local v109 = l_Assets_0.RockLine:Clone()
						v2.MatchWithRay(v109, v108)
						v109.Position = v108.Position - Vector3.new(0, 1, 0, 0) * -v104.ExposeLevel
						v109.Orientation = v2.GenerateRandomOrientation()
						local v110 = Vector3.new(1, 1, 1, 0) * (v104.Size + v105 * v104.SizeIndex)
						if v104.NoTween then
							v109.Size = v110
						else
							l_TweenService_0:Create(v109, TweenInfo.new(0.3), {
								Size = v110
							}):Play()
						end
						if not v104.NoSmoke then
							local v111 = l_Assets_0.Smoke:Clone()
							v111.Color = ColorSequence.new(v109.Color)
							v111.Parent = v109
							v111:Emit(v110.X * v110.Y * v110.Z / 4)
						end
						v109.Parent = workspace.Thrown
						task.delay(2, function() --[[ Line: 443 ]]
							-- upvalues: l_TweenService_0 (ref), v109 (copy)
							local v112 = l_TweenService_0:Create(v109, TweenInfo.new(3), {
								Size = Vector3.new(0, 0, 0, 0)
							})
							v112:Play()
							v112.Completed:Wait()
							v109:Destroy()
						end)
					end
				end
				if v104.TimeTilNextRock then
					task.wait(v104.TimeTilNextRock)
				end
			end
		end
		v2.OldJSDRocks = function(v117, v118) --[[ Line: 472 ]] --[[ Name: OldJSDRocks ]]
			-- upvalues: v4 (copy), l_TweenService_0 (copy)
			v118 = v118 or {}
			local v119 = (typeof(v117) == "CFrame" and v117.Position or v117) + Vector3.new(0, 2, 0, 0)
			local v120 = workspace:Raycast(v119, Vector3.new(-0, -10, -0, -0), v4.VisualParams)
			local v121 = if not v120 then nil else {
				Position = v120.Position, 
				Normal = v120.Normal, 
				Color = v120.Instance.Color, 
				Material = v120.Instance.Material, 
				Raw = v120
			}
			if not v121 then
				return
			else
				v119 = typeof(v117) == "CFrame" and v117 - v117.Position + v121.Position or CFrame.new(v121.Position, v121.Position + v121.Normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
				v120 = v118.Rocks or 4
				local v122 = v118.Distance or 3
				local v123 = v118.SizeMagnitude or 1
				local v124 = v118.BaseDuration or 2
				local v125 = v118.ExposeLevel or 0
				local v126 = v118.OpenSpaces or 0
				local v127 = v118.Layers or 1
				local v128 = typeof(v123) == "number"
				local v129 = {}
				if v128 then
					v129.X = v123
					v129.Y = v123
					v129.Z = v123
				else
					v129.X = v123.X
					v129.Y = v123.Y
					v129.Z = v123.Z
				end
				local v130 = v118.VariationMin or 0.95
				local v131 = v118.VariationMax or 1.05
				local v132 = v118.SizeVariationMin or 0.95
				local v133 = v118.SizeVariationMax or 1.05
				local _ = v118.MinAngleVariation or -30
				local _ = v118.MaxAngleVariation or 30
				local v136 = Vector3.new(v118.BaseX or 3, v118.BaseY or 1.5, v118.BaseZ or 2.1) * Vector3.new(v129.X, v129.Y, v129.Z)
				local function _() --[[ Line: 523 ]] --[[ Name: FetchVariatedSize ]]
					-- upvalues: v136 (ref), v4 (ref), v132 (copy), v133 (copy)
					return v136 * v4.Seed:NextNumber(v132, v133)
				end
				local v139 = v120 + v126
				local function v152(v140) --[[ Line: 535 ]] --[[ Name: CreatePiece ]]
					-- upvalues: v139 (copy), v4 (ref), v122 (copy), v130 (copy), v131 (copy), v119 (copy), v127 (copy), v118 (ref), v136 (ref), v132 (copy), v133 (copy), v125 (copy), l_TweenService_0 (ref), v124 (copy)
					local v141 = v140 * (6.283185307179586 / v139) + math.rad((v4.Seed:NextNumber(-30, 30)))
					local v142 = math.sin(v141)
					local v143 = math.cos(v141)
					v142 = v142 * (v122 * v4.Seed:NextNumber(v130, v131))
					v143 = v143 * (v122 * v4.Seed:NextNumber(v130, v131))
					local v144 = v119.Position + Vector3.new(v142, 0, v143)
					local v145 = workspace:Raycast(v144 + Vector3.new(0, 2, 0, 0), Vector3.new(-0, -7, -0, -0), v4.VisualParams)
					if not v145 then
						return
					elseif v145.Normal:Dot((Vector3.new(0, 1, 0, 0))) < 1 then
						return
					else
						for v146 = 1, v127 do
							task.spawn(function() --[[ Line: 549 ]]
								-- upvalues: v146 (copy), v118 (ref), v145 (copy), v136 (ref), v4 (ref), v132 (ref), v133 (ref), v144 (copy), v119 (ref), v125 (ref), l_TweenService_0 (ref), v124 (ref)
								local v147 = v146 == 1 and 1 or 1 + v146 * 0.05
								local l_Part_0 = Instance.new("Part")
								local v149 = true
								if v118.CanCollide == nil then

								end
								local l_CanCollide_0 = v118.CanCollide
								l_Part_0.Anchored = v149
								l_Part_0.CanCollide = l_CanCollide_0
								v149 = v145.Instance.Color
								l_CanCollide_0 = v145.Instance.Material
								l_Part_0.Color = v149
								l_Part_0.Material = l_CanCollide_0
								l_Part_0.Size = v136 * v4.Seed:NextNumber(v132, v133) * v147
								v149 = math.rad(v4.Seed:NextNumber(40, 45) * v147)
								if v118.Inverted then
									v149 = -v149
								end
								local v151 = CFrame.new(v144, v119.Position) * CFrame.new(0, 0, v146 == 1 and 0 or v147 * v4.Seed:NextNumber(1.2, 1.7)) * CFrame.Angles(v149, 0, 0) * CFrame.new(0, l_Part_0.Size.Y * 0.05 + v125, 0)
								l_Part_0.CFrame = v151
								l_Part_0.Position = l_Part_0.Position - Vector3.new(0, 4, 0, 0)
								l_Part_0.Parent = workspace.Thrown
								l_TweenService_0:Create(l_Part_0, TweenInfo.new(v4.Seed:NextNumber(0.1, 0.15), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
									CFrame = v151
								}):Play()
								task.wait(v124 * v4.Seed:NextNumber(0.9, 1.1))
								l_TweenService_0:Create(l_Part_0, TweenInfo.new(v4.Seed:NextNumber(1.1, 1.5), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
									Position = l_Part_0.Position - Vector3.new(0, 1, 0, 0) * l_Part_0.Size.Y
								}):Play()
								task.delay(2, l_Part_0.Destroy, l_Part_0)
							end)
						end
						return
					end
				end
				for v153 = 1, v120 do
					task.spawn(v152, v153)
				end
				return
			end
		end
		return v2