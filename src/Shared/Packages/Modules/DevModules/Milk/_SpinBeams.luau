local v_u_1 = game:GetService("TweenService")
local v_u_2 = game:GetService("RunService")
local v_u_3 = game:GetService("Debris")


return function(p4, p_u_5, p6)
	local v_u_7 = p4:Clone()
	v_u_7.Parent = workspace.Thrown
	local v_u_8 = p6 or v_u_7.CFrame
	local v_u_9 = p_u_5.WeldTo
	local v_u_10 = p_u_5.WeldOffset
	
	if v_u_9 and not v_u_10 then
		v_u_10 = CFrame.new(Vector3.new(0, 0, 0))
	end
	
	for _, v_u_11 in v_u_7:GetDescendants() do
		if v_u_11:IsA("Beam") then
			v_u_11.Enabled = true
			local v_u_12 = {
				["Width0"] = v_u_11.Width0,
				["Width1"] = v_u_11.Width1,
				["TextureSpeed"] = v_u_11.TextureSpeed,
				["Brightness"] = v_u_11.Brightness,
				["LightEmission"] = v_u_11.LightEmission
			}
			local v13 = v_u_1:Create(v_u_11, TweenInfo.new(p_u_5.Duration, Enum.EasingStyle[p_u_5.Easing], Enum.EasingDirection[p_u_5.EasingDirection]), p_u_5.Properties)
			v13:Play()
			v13.Completed:Once(function()
				-- upvalues: (copy) v_u_11, (ref) v_u_12
				v_u_11.Enabled = false
				for v14, v15 in v_u_12 do
					v_u_11[v14] = v15
				end
				v_u_12 = nil
			end)
		end
	end
	
	
	local v_u_16 = nil
	local v_u_17 = 0
	v_u_16 = v_u_2.Heartbeat:Connect(function(p18)
		-- upvalues: (ref) v_u_17, (copy) v_u_7, (copy) p_u_5, (copy) v_u_9, (ref) v_u_10, (ref) v_u_8, (ref) v_u_1, (ref) v_u_16
		v_u_17 = v_u_17 + p18
		local v19 = v_u_7
		local v20 = v19.CFrame
		local v21 = CFrame.Angles
		local v22 = p_u_5.RotationSpeed
		v19.CFrame = v20 * v21(0, 0, (math.rad(v22)))
		local v23
		if v_u_9 then
			v23 = (v_u_9.CFrame * v_u_10 * p_u_5.Offset).Position
		else
			v23 = (v_u_8 * p_u_5.Offset).Position
		end
		local v24 = v_u_1
		local v25 = v_u_7
		local v26 = TweenInfo.new
		local v27 = p_u_5.Duration - v_u_17
		v24:Create(v25, v26(math.max(v27, 0.001), Enum.EasingStyle[p_u_5.Easing], Enum.EasingDirection[p_u_5.EasingDirection]), {
			["Position"] = v23
		}):Play()
		if v_u_17 > p_u_5.Duration and v_u_16 then
			v_u_16:Disconnect()
			v_u_16 = nil
		end
	end)
	v_u_3:AddItem(v_u_7, p_u_5.Duration)
end
