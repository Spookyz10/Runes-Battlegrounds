local v_u_1 = {}
local v_u_2 = game:GetService("TweenService")

local function v_u_17(p3, p4, p5, p6)
	local v7 = p3:GetAttribute(p5 .. "_TweenParams")
	local v8 = {
		{ "TweenStyle", p6 },
		{ "TweenDirection", Enum.EasingDirection.Out }
	}
	
	local v_u_9 = {}
	
	if typeof(v7) == "string" then
		local v10 = { v7:match("(%a+),(%a+)") }
		for v11 = 1, 2 do
			local v_u_12 = v10[v11]
			local v13 = v8[v11]
			local v_u_14 = v13[1]
			local v15 = v13[2]
			
			if v_u_12 then
				if not pcall(function()
					v_u_9[v_u_14] = Enum[v_u_14][v_u_12]
				end) then
					v_u_9[v_u_14] = v15
				end
			else
				v_u_9[v_u_14] = v15
			end
		end
	else
		for _, v16 in v8 do
			v_u_9[v16[1]] = v16[2]
		end
	end
	
	return TweenInfo.new(p4, v_u_9.TweenStyle, v_u_9.TweenDirection)
end

return function(p18, p19)
	if p18 and p19 then
		local v20 = p18.Parent:FindFirstChild("End")
		if v20 then
			local v21 = p18:Clone()
			local v22 = p18.Parent
			local v23 = tonumber(v22:GetAttribute("StartTransparency")) or 0
			local v24 = p18.Parent
			local v25 = tonumber(v24:GetAttribute("GoalTransparency")) or 1
			
			if v21:IsA("MeshPart") then
				v21.Transparency = v23
			elseif v21:IsA("BasePart") and v21:FindFirstChildOfClass("Decal") then
				v21.Transparency = 1
			end
			
			v21.Parent = workspace.CurrentCamera
			v21.CFrame = p19
			local v26 = p18.Parent
			local v27 = tonumber(v26:GetAttribute("Duration")) or 0.1
			local v28 = p19 * p18.CFrame:ToObjectSpace(v20.CFrame)
			
			if v21:FindFirstChildOfClass("Decal") then
				v_u_2:Create(v21, v_u_17(p18.Parent, v27, "Part", Enum.EasingStyle.Cubic), {
					["Size"] = v20.Size,
					["CFrame"] = v28
				}):Play()
			else
				v_u_2:Create(v21, v_u_17(p18.Parent, v27, "Part", Enum.EasingStyle.Cubic), {
					["Size"] = v20.Size,
					["CFrame"] = v28,
					["Transparency"] = v25
				}):Play()
			end
			
			local v29 = v21:FindFirstChildOfClass("SpecialMesh")
			local v30 = v20:FindFirstChildOfClass("SpecialMesh")
			if v29 and v30 then
				v_u_2:Create(v29, v_u_17(p18.Parent, v27, "Mesh", Enum.EasingStyle.Sine), {
					["Scale"] = v30.Scale
				}):Play()
			end
			
			local v31 = v21:FindFirstChildOfClass("Decal")
			local v32 = v20:FindFirstChildOfClass("Decal")
			
			if v31 and v32 then
				v31.Transparency = v23
				v_u_2:Create(v31, v_u_17(p18.Parent, v27, "Decal", Enum.EasingStyle.Cubic), {
					["Transparency"] = v32.Transparency,
					["Color3"] = v32.Color3
				}):Play()
			end
			
			task.delay(v27, v21.Destroy, v21)
			return v_u_1, v21
		end
		
		warn("Goal is not defined.")
	end
end
