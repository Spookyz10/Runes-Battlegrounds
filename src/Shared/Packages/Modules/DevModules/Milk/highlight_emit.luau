-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("Debris")
local v_u_2 = game:GetService("TweenService")
game:GetService("RunService")
return {
	["tweenHighlight"] = function(p3, p4, p5, p6, p7, p8, p9)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		local v10 = p6 or 1
		local v11 = Instance.new("Highlight")
		v11.Adornee = p3
		v11.DepthMode = p7 or Enum.HighlightDepthMode.Occluded
		v11.FillColor = p4 or Color3.new(1, 1, 1)
		v11.OutlineColor = p5 or Color3.new(1, 1, 1)
		v11.OutlineTransparency = 0
		local v12, v13
		if p8 == "Out" then
			v12 = 1
			v13 = 0
		else
			v12 = p9 or 0
			v13 = 1
		end
		v11.FillTransparency = v12
		v11.OutlineTransparency = v12
		v11.Parent = p3
		v_u_2:Create(v11, TweenInfo.new(v10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			["FillTransparency"] = v13,
			["OutlineTransparency"] = v13
		}):Play()
		v_u_1:AddItem(v11, v10)
		return v11
	end,
	["pulseHighlight"] = function(p14, p15, p16, p17, p18, p19, p20, p21)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		local v_u_22 = Instance.new("Highlight")
		v_u_22.Adornee = p14
		v_u_22.DepthMode = p18 or Enum.HighlightDepthMode.Occluded
		v_u_22.FillColor = p15 or Color3.new(1, 1, 1)
		v_u_22.OutlineColor = p16 or Color3.new(1, 1, 1)
		local v23 = p17 or 0.5
		local v24 = p20 or 0
		local v25 = p21 or 1
		v_u_22.FillTransparency = v24
		v_u_22.OutlineTransparency = v24
		v_u_22.Parent = p14
		local v26 = TweenInfo.new(v23, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local v27 = TweenInfo.new(v23, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local v_u_28 = v_u_2:Create(v_u_22, v26, {
			["FillTransparency"] = v25,
			["OutlineTransparency"] = v25
		})
		local v_u_29 = v_u_2:Create(v_u_22, v27, {
			["FillTransparency"] = v24,
			["OutlineTransparency"] = v24
		})
		local v_u_30 = 0
		local v_u_31 = p19 or 0
		local function v_u_32()
			-- upvalues: (copy) v_u_22, (copy) v_u_28, (copy) v_u_29, (ref) v_u_30, (copy) v_u_31, (copy) v_u_32, (ref) v_u_1
			if v_u_22 and v_u_22.Parent then
				v_u_28:Play()
				v_u_28.Completed:Wait()
				if v_u_22 and v_u_22.Parent then
					v_u_29:Play()
					v_u_29.Completed:Wait()
					v_u_30 = v_u_30 + 1
					if v_u_31 == 0 or v_u_30 < v_u_31 then
						task.spawn(v_u_32)
					else
						v_u_1:AddItem(v_u_22, 0.1)
					end
				else
					return
				end
			else
				return
			end
		end
		task.spawn(v_u_32)
		return v_u_22
	end,
	["flashHighlight"] = function(p33, p34, p35, p36, p37, p38, p39)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		local v_u_40 = Instance.new("Highlight")
		v_u_40.Adornee = p33
		v_u_40.DepthMode = p38 or Enum.HighlightDepthMode.Occluded
		v_u_40.FillColor = p34 or Color3.new(1, 1, 1)
		v_u_40.OutlineColor = p35 or Color3.new(1, 1, 1)
		v_u_40.FillTransparency = p39
		v_u_40.OutlineTransparency = p39
		v_u_40.Parent = p33
		local v41 = p37 or 0.1
		local v_u_42 = p36 or 1
		local v43 = TweenInfo.new(v41 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local v44 = TweenInfo.new(v41 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v_u_45 = v_u_2:Create(v_u_40, v43, {
			["FillTransparency"] = p39,
			["OutlineTransparency"] = p39
		})
		local v_u_46 = v_u_2:Create(v_u_40, v44, {
			["FillTransparency"] = 1,
			["OutlineTransparency"] = 1
		})
		local v_u_47 = os.clock()
		local function v_u_48()
			-- upvalues: (copy) v_u_40, (copy) v_u_47, (copy) v_u_42, (ref) v_u_1, (copy) v_u_45, (copy) v_u_46, (copy) v_u_48
			if v_u_40 and v_u_40.Parent then
				if v_u_42 <= os.clock() - v_u_47 then
					v_u_1:AddItem(v_u_40, 0.1)
					return
				else
					v_u_45:Play()
					v_u_45.Completed:Wait()
					if v_u_40 and v_u_40.Parent then
						v_u_46:Play()
						v_u_46.Completed:Wait()
						task.spawn(v_u_48)
					end
				end
			else
				return
			end
		end
		task.spawn(v_u_48)
		v_u_1:AddItem(v_u_40, v_u_42 + 0.5)
		return v_u_40
	end
}
