-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("TweenService")
local v_u_2 = game:GetService("RunService")
local v_u_3 = game:GetService("Debris")
return function(p4, p_u_5, p6)
	-- upvalues: (copy) v_u_3, (copy) v_u_1, (copy) v_u_2
	local v_u_7 = p4:Clone()
	v_u_3:AddItem(v_u_7, p_u_5.Duration)
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
				-- upvalues: (copy) v_u_11, (copy) v_u_12
				v_u_11.Enabled = false
				for v14, v15 in v_u_12 do
					v_u_11[v14] = v15
				end
			end)
		end
	end
	local v_u_16 = nil
	local v_u_17 = 0
	local v_u_18 = 0
	v_u_16 = v_u_2.Heartbeat:Connect(function(p19)
		-- upvalues: (ref) v_u_17, (ref) v_u_18, (copy) p_u_5, (copy) v_u_9, (ref) v_u_10, (ref) v_u_8, (copy) v_u_7, (ref) v_u_16
		v_u_17 = v_u_17 + p19
		v_u_18 = v_u_18 + p_u_5.RotationSpeed
		local v20
		if v_u_9 then
			v20 = v_u_9.CFrame * v_u_10
		else
			v20 = v_u_8
		end
		local v21
		if v_u_9 then
			v21 = v_u_9.CFrame * v_u_10 * p_u_5.Offset
		else
			v21 = v_u_8 * p_u_5.Offset
		end
		local v22 = v_u_17 / p_u_5.Duration
		local v23 = v_u_18
		v_u_7.CFrame = v20:Lerp(v21, (math.min(v22, 1))) * CFrame.Angles(0, 0, (math.rad(v23)))
		if v_u_17 > p_u_5.Duration and v_u_16 then
			v_u_16:Disconnect()
			v_u_16 = nil
		end
	end)
	return v_u_7, v_u_16
end
