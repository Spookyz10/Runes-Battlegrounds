local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Thrown = workspace:FindFirstChild("Thrown")
local Live = workspace:FindFirstChild("Live")


local Module = {
	["default_raycast_params"] = RaycastParams.new()
}


Module.default_raycast_params.IgnoreWater = true
Module.default_raycast_params.CollisionGroup = "Map"
Module.default_raycast_params.FilterDescendantsInstances = {
	Thrown,
	Live
}
Module.default_raycast_params.FilterType = Enum.RaycastFilterType.Exclude


function Module.Raycast(Origin, Direction, Params)
	local RayResult = workspace:Raycast(Origin, Direction, Params)
	return RayResult
end


function Module.TweenPart(Part, CF, Size, WaitTime, GoalTime, Value)
	coroutine.wrap(function()
		local OriginalTransparency = Part.Transparency
		
		for i = 1, GoalTime do
			if not Part then
				break
			end
			
			if CF then
				Part.CFrame = Part.CFrame:Lerp(CF, i / GoalTime)
			end
			
			if Size then
				Part.Size = Part.Size:Lerp(Size, i / GoalTime)
			end
			
			if Value then
				Part.Transparency = OriginalTransparency + (Value - OriginalTransparency) * i / GoalTime
			end
			
			task.wait(WaitTime / GoalTime)
		end
	end)()
end


function Module.CreatePart(p40, p41, p42)
	if p41 then
		if p40 then
			return p40:Clone()
		end
		
		local v43 = script.PartTemplate:Clone()
		if p41.Anchored == nil then
			v43.Anchored = true
		else
			v43.Anchored = p41.Anchored
		end
		
		if p41.CastShadow == nil then
			v43.CastShadow = false
		else
			v43.CastShadow = p41.CastShadow
		end
		
		if p41.CanQuery == nil then
			v43.CanQuery = true
		else
			v43.CanQuery = p41.CanQuery
		end
		
		if p41.CanTouch == nil then
			v43.CanTouch = true
		else
			v43.CanTouch = p41.CanTouch
		end

		if p41.Massless == nil then
			v43.Massless = false
		else
			v43.Massless = p41.Massless
		end
		
		if p41.CanCollide == nil then
			v43.CanCollide = true
		else
			v43.CanCollide = p41.CanCollide
		end
		
		v43.CollisionGroup = p41.CollisionGroup or "NonPColDebri"
		if p41.RandomLava and math.random(1, 5) == 1 then
			v43.Material = Enum.Material.Neon
			v43.Color = Color3.fromRGB(255, 85, 0)
			v43.BackSurface = p42.Instance.BackSurface
			v43.BottomSurface = p42.Instance.BottomSurface
			v43.FrontSurface = p42.Instance.FrontSurface
			v43.LeftSurface = p42.Instance.LeftSurface
			v43.RightSurface = p42.Instance.RightSurface
			v43.TopSurface = p42.Instance.TopSurface
			
		elseif p41.MatchRaycastBehavior then
			v43.Material = p42.Material
			v43.Color = p42.Instance.Color
			v43.BackSurface = p42.Instance.BackSurface
			v43.BottomSurface = p42.Instance.BottomSurface
			v43.FrontSurface = p42.Instance.FrontSurface
			v43.LeftSurface = p42.Instance.LeftSurface
			v43.RightSurface = p42.Instance.RightSurface
			v43.TopSurface = p42.Instance.TopSurface
			
		else
			v43.Material = p41.Material or Enum.Material.Rock
			v43.Color = p41.Color or Color3.fromRGB(100, 100, 100)
		end
		
		
		v43.Parent = Thrown
		
		
		return v43
	end
end


function Module.CircularSmash(p44, p45, p46, p47, p48, p49, p50, p51, p52, p53, p54, p_u_55, p56)
	if p44 then
		if p46 then
			if p47 then
				local v57 = p56 or 1
				local v58 = p51 or Module.default_raycast_params
				local v59 = math.max(p45, 1) + p_u_55
				local v60 = p44 * CFrame.new(0, 0, p49 / 2)
				
				if Module.Raycast(v60.Position, p44.LookVector * p49, v58) then
					for v61 = 1, p47 do
						local v62 = p53.segments(v61, p47)
						if v62 ~= 0 then
							for v63 = 1, v62 do
								for v64 = 1, v57 do
									local v_u_65 = p44 * p53.rotation_offset(v61, p47, v64, v62, v63) * CFrame.new(0, 0, p46 * v61)
									local v_u_66 = workspace:Raycast((v_u_65 * CFrame.new(0, 0, p49 / 2) * p53.part_offset(v63, v61, p47, v64)).Position, p44.LookVector * p49, v58)
									
									if v_u_66 then
										local v_u_67 = Module.CreatePart(p50, p52, v_u_66)
										
										if v_u_67 then
											v_u_67.CFrame = CFrame.new(v_u_66.Position) * p53.part_offset2(v63, v61, p47, v64) * CFrame.Angles(v_u_65:ToEulerAnglesXYZ()) * CFrame.Angles(p53.part_offset(v63, v61, p47, v64):ToEulerAnglesXYZ())
											v_u_67.Size = p53.part_size(v63, v61, p47, v64)
											local v68 = v_u_67.CFrame
											local v_u_69 = CFrame.new(v_u_66.Position) * p53.part_offset2(v63, v61, p47, v64) * CFrame.Angles(v_u_65:ToEulerAnglesXYZ()) * CFrame.new(0, -v_u_67.Size.Magnitude, 0) * CFrame.Angles(p53.part_offset(v63, v61, p47, v64):ToEulerAnglesXYZ())
											v_u_67.Position = v_u_69.Position
											Module.TweenPart(v_u_67, v68, v_u_67.Size, p54, 50)
											
											task.delay(v59 - p_u_55, function()
												Module.TweenPart(v_u_67, v_u_69, Vector3.new(0, 0, 0), p_u_55, 50)
											end)
											
											Debris:AddItem(v_u_67, v59)
											task.delay(v59, function()
												v_u_67 = nil
												v_u_66 = nil
												v_u_65 = nil
											end)
										end
									end
								end
							end
							
							task.wait(p48)
						end
					end
				end
			else
				
				return
			end
		else
			
			return
		end
	else
		
		return
	end
end

function Module.ParticleImpact(p_u_94, p95, p_u_96, p_u_97, p_u_98, p_u_99, p100, p_u_101, p102, p_u_103, p_u_104, _, p_u_105)
	if p_u_94 then
		if LocalPlayer:FindFirstChild("GameplaySettings") and (LocalPlayer.GameplaySettings:FindFirstChild("Decorations") and not LocalPlayer.GameplaySettings.Decorations.Value) then
			return
		else
			if not p_u_104.j then
				p_u_104.j = 1
			end
			
			if p_u_96 then
				local v_u_106 = p102 or Module.default_raycast_params
				local v107 = (not p100 or p100 == "") and "Cubic" or p100
				local v_u_108 = math.max(p95, 1) + p_u_105
				local v109 = p_u_94 * CFrame.new(0, 0, p_u_99 / 2)
				if Module.Raycast(v109.Position, p_u_94.LookVector * p_u_99, v_u_106) then
					if v107 == "Cubic" then
						for v_u_110 = -p_u_96, p_u_96, p_u_104.j do
							task.delay(p_u_98 * (math.abs(v_u_110) / p_u_96), function()
								for v_u_111 = -p_u_96, p_u_96, p_u_104.j do
									task.delay(p_u_98 * (math.abs(v_u_111) / p_u_96), function()
										local v_u_112 = p_u_94 * CFrame.new(v_u_110 * (p_u_104.part_size(v_u_110, v_u_111, p_u_96).X * p_u_97), v_u_111 * (p_u_104.part_size(v_u_110, v_u_111, p_u_96).Z * p_u_97), 0)
										local v_u_113 = Module.Raycast((v_u_112 * CFrame.new(0, 0, p_u_99 / 2)).Position, p_u_94.LookVector * p_u_99, v_u_106)
										
										if v_u_113 then
											local v_u_114 = Module.CreatePart(p_u_101, p_u_103, v_u_113)
											if v_u_114 then
												v_u_114.CFrame = v_u_112
												v_u_114.Position = v_u_113.Position
												v_u_114.CFrame = v_u_114.CFrame * p_u_104.part_offset(v_u_110, v_u_111, p_u_96)
												v_u_114.Size = p_u_104.part_size(v_u_110, v_u_111, p_u_96)
												v_u_114:ApplyImpulse(p_u_104.force(v_u_112) * v_u_114.AssemblyMass)
												v_u_114:ApplyAngularImpulse(p_u_104.angular_force() * v_u_114:GetMass())
												task.delay(v_u_108 - p_u_105, function()
													Module.TweenPart(v_u_114, nil, nil, p_u_105, 30, 1)
												end)
												
												Debris:AddItem(v_u_114, v_u_108)
												task.delay(v_u_108, function()
													v_u_114 = nil
													v_u_113 = nil
													v_u_112 = nil
												end)
											end
										else
											return
										end
									end)
								end
							end)
						end
					elseif v107 ~= "Circular" then
						local _ = v107 == "Line"
					end
				end
			else
				return
			end
		end
	else
		return
	end
end

return Module
