-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
local v_u_2 = game:GetService("TweenService")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Debris")
require(script.Types)
local function v_u_11(p_u_5, p_u_6, p7)
	-- upvalues: (copy) v_u_3
	local v_u_10 = v_u_3.Heartbeat:Connect(function(_)
		-- upvalues: (copy) p_u_5, (copy) p_u_6
		local v8 = p_u_5
		local v9 = p_u_6
		v8.CFrame = v8.CFrame * CFrame.Angles(0, math.rad(v9), 0)
	end)
	task.delay(p7, function()
		-- upvalues: (copy) v_u_10
		v_u_10:Disconnect()
	end)
end
local function v_u_15(p12)
	local v13 = {}
	if (p12:IsA("Part") and p12:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh") == "SpecialMesh" then
		local v14 = p12:FindFirstChildOfClass("SpecialMesh")
		if not v14 then
			return {}
		end
		v13.Scale = v14.Scale
	else
		v13.Size = p12.Size
	end
	v13.Position = p12.CFrame.Position
	return v13
end
function v_u_1.new(p16)
	-- upvalues: (copy) v_u_15, (copy) v_u_1
	local v17 = {
		["Model"] = p16,
		["Type"] = p16.Start:IsA("Part") and p16.Start:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh",
		["Properities"] = v_u_15(p16.Start),
		["EndProperities"] = v_u_15(p16.End),
		["Settings"] = p16:GetAttributes()
	}
	local v18 = v_u_1
	return setmetatable(v17, v18)
end
function v_u_1.SetFlipbook(p19, p20)
	p19.__Flipbook = require(p20)
end
function v_u_1.RandomizeSize(p21, p22, p23)
	if p21.Type == "SpecialMesh" then
		local v24 = p21.EndProperities
		local v25 = math.random(p22.X, p23.X)
		local v26 = math.random(p22.Y, p23.Y)
		local v27 = math.random
		local v28 = p22.Z
		local v29 = p23.Z
		v24.Scale = Vector3.new(v25, v26, v27(v28, v29))
	else
		local v30 = p21.EndProperities
		local v31 = math.random(p22.X, p23.X)
		local v32 = math.random(p22.Y, p23.Y)
		local v33 = math.random
		local v34 = p22.Z
		local v35 = p23.Z
		v30.Size = Vector3.new(v31, v32, v33(v34, v35))
	end
end
function v_u_1.PlayFlipbook(p_u_36, p_u_37)
	-- upvalues: (copy) v_u_3
	local v_u_38 = p_u_36.__Flipbook
	if v_u_38 then
		local v_u_39 = 1
		local v_u_40 = 0
		local v_u_41 = nil
		v_u_41 = v_u_3.Heartbeat:Connect(function(p42)
			-- upvalues: (ref) v_u_40, (copy) p_u_36, (ref) v_u_39, (copy) v_u_38, (ref) v_u_41, (copy) p_u_37
			v_u_40 = v_u_40 + p42
			if v_u_40 >= (1 / p_u_36.Settings.FlipbookRate or 0.016666666666666666) then
				v_u_39 = v_u_39 + 1
				if v_u_39 > #v_u_38 then
					v_u_41:Disconnect()
					return
				end
				if p_u_36.Type == "SpecialMesh" then
					local v43 = p_u_37:FindFirstChildOfClass("Decal")
					if not v43 then
						return
					end
					v43.Texture = v_u_38[v_u_39]
				else
					p_u_37.TextureId = v_u_38[v_u_39]
				end
				v_u_40 = 0
			end
		end)
	end
end
function v_u_1.Emit(p_u_44, p45)
	-- upvalues: (copy) v_u_4, (copy) v_u_11, (copy) v_u_2
	local v46 = p_u_44.Settings.Lifetime
	local v47 = Enum.EasingStyle[p_u_44.Settings.EasingStyle]
	local v48 = Enum.EasingDirection[p_u_44.Settings.EasingDirection]
	local v49 = p_u_44.Settings.Transparency or 1
	local v50 = p_u_44.Settings.StartTransparency or 1
	local v51 = p_u_44.Settings.RotationX
	local v52 = not v51 and 0 or math.random(v51.Min, v51.Max)
	local v53 = p_u_44.Settings.RotationY
	local v54 = not v53 and 0 or math.random(v53.Min, v53.Max)
	local v55 = p_u_44.Settings.RotationZ
	local v56 = not v55 and 0 or math.random(v55.Min, v55.Max)
	local v57 = TweenInfo.new(v46, v47, v48)
	local v_u_58 = p_u_44.Model.Start:Clone()
	v_u_4:AddItem(v_u_58, v46)
	p_u_44:PlayFlipbook(v_u_58)
	v_u_58.CFrame = (typeof(p45) == "CFrame" and p45 and p45 or p45.CFrame) * CFrame.Angles(math.rad(v52), math.rad(v54), (math.rad(v56)))
	v_u_58.Parent = workspace.Thrown
	local v59 = p_u_44.Model.Start.CFrame:ToObjectSpace(p_u_44.Model.End.CFrame)
	p_u_44.EndProperities.Position = nil
	if p_u_44.Settings.RotationSpeed then
		v_u_11(v_u_58, p_u_44.Settings.RotationSpeed, v46)
	end
	if p_u_44.Type == "SpecialMesh" then
		local v_u_60 = v_u_58:FindFirstChildOfClass("SpecialMesh")
		local v61 = v_u_58:FindFirstChildOfClass("Decal")
		if v_u_60 then
			local v62 = v_u_2:Create(v_u_60, v57, p_u_44.EndProperities)
			local v63 = v_u_2:Create(v_u_58, v57, {
				["CFrame"] = v_u_58.CFrame * v59
			})
			v62:Play()
			v63:Play()
			v62.Completed:Once(function()
				-- upvalues: (copy) v_u_60, (copy) p_u_44, (copy) v_u_58
				v_u_60.Scale = p_u_44.Properities.Scale or Vector3.new(1, 1, 1)
				v_u_58.Transparency = 1
			end)
		end
		if v61 then
			v61.Transparency = v50
			v_u_2:Create(v61, TweenInfo.new(v46, Enum.EasingStyle[p_u_44.Settings.TransparencyEasingStyle], Enum.EasingDirection[p_u_44.Settings.TransparencyEasingDirection]), {
				["Transparency"] = v49,
				["Color3"] = p_u_44.Model.End:FindFirstChildOfClass("Decal").Color3
			}):Play()
			return
		end
	else
		v_u_58.Transparency = v50
		TweenInfo.new(v46, Enum.EasingStyle[p_u_44.Settings.TransparencyEasingStyle], Enum.EasingDirection[p_u_44.Settings.TransparencyEasingDirection])
		if p_u_44.Settings.Movement then
			p_u_44.EndProperities.CFrame = v_u_58.CFrame * v59
		end
		p_u_44.EndProperities.Transparency = v49
		local v64 = v_u_2:Create(v_u_58, v57, p_u_44.EndProperities)
		v64:Play()
		v64.Completed:Once(function()
			-- upvalues: (copy) v_u_58, (copy) p_u_44
			v_u_58.Size = p_u_44.Properities.Size or Vector3.new(1, 1, 1)
			v_u_58.Transparency = 1
		end)
	end
end
function v_u_1.EmitRate(p_u_65, p_u_66, p67, p_u_68)
	-- upvalues: (copy) v_u_3
	local v_u_69 = 0
	local v_u_71 = v_u_3.Heartbeat:Connect(function(p70)
		-- upvalues: (ref) v_u_69, (copy) p_u_66, (copy) p_u_65, (copy) p_u_68
		v_u_69 = v_u_69 + p70
		if v_u_69 > p_u_66 / 60 then
			v_u_69 = 0
			p_u_65:Emit(p_u_68)
		end
	end)
	return task.delay(p67, function()
		-- upvalues: (copy) v_u_71
		v_u_71:Disconnect()
	end)
end
return v_u_1
