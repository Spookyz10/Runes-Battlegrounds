local v_u_1 = {}
v_u_1.__index = v_u_1

local v_u_2 = game:GetService("TweenService")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Debris")

require(script.Types)


local function v_u_16(p_u_5, p_u_6, p7, p8, p9)
	local v_u_10 = Instance.new("NumberValue")
	v_u_10.Value = 1
	local v11 = v_u_2:Create(v_u_10, TweenInfo.new(p7, p8, p9), {
		["Value"] = #p_u_5
	})
	v11:Play()
	
	local v_u_15 = v_u_10.Changed:Connect(function(_)
		local v12 = p_u_6
		local v13 = p_u_5
		local v14 = v_u_10.Value
		v12.Texture = v13[math.round(v14)]
	end)
	
	v11.Completed:Connect(function(_)
		v_u_15:Disconnect()
	end)
end

local function v_u_20(p17)
	local v18 = {}
	if (p17:IsA("Part") and p17:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh") == "SpecialMesh" then
		local v19 = p17:FindFirstChildOfClass("SpecialMesh")
		
		if not v19 then
			return {}
		end
		
		v18.Scale = v19.Scale
	else
		v18.Size = p17.Size
	end
	
	v18.Position = p17.CFrame.Position
	return v18
end


local function v_u_25(p21)
	local v22 = {}
	for v23 = 1, #p21:GetChildren() do
		local v24 = p21[tostring(v23)].Texture
		table.insert(v22, v24)
	end
	
	return v22
end

function v_u_1.new(p26)
	local v27 = {
		["Model"] = p26,
		["Type"] = p26.Start:IsA("Part") and p26.Start:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh",
		["Properities"] = v_u_20(p26.Start),
		["EndProperities"] = v_u_20(p26.End),
		["Settings"] = p26:GetAttributes(),
		["__connections"] = {}
	}
	local v28 = v_u_1
	return setmetatable(v27, v28)
end

function v_u_1.SetFlipbook(p29, p30)
	if typeof(p30) == "table" then
		p29.__Flipbook = p30
	else
		p29.__Flipbook = require(p30)
	end
end

function v_u_1.ClearFlipbook(p31)
	p31.__Flipbook = nil
end

function v_u_1.DisconnectAll(p32)
	for _, v33 in ipairs(p32.__connections) do
		if v33.Connected then
			v33:Disconnect()
		end
	end
	table.clear(p32.__connections)
end

function v_u_1.RandomizeSize(p34, p35, p36)
	if p34.Type == "SpecialMesh" then
		local v37 = p34.EndProperities
		local v38 = math.random(p35.X, p36.X)
		local v39 = math.random(p35.Y, p36.Y)
		local v40 = math.random
		local v41 = p35.Z
		local v42 = p36.Z
		v37.Scale = Vector3.new(v38, v39, v40(v41, v42))
	else
		local v43 = p34.EndProperities
		local v44 = math.random(p35.X, p36.X)
		local v45 = math.random(p35.Y, p36.Y)
		local v46 = math.random
		local v47 = p35.Z
		local v48 = p36.Z
		v43.Size = Vector3.new(v44, v45, v46(v47, v48))
	end
end

function v_u_1.PlayFlipbook(p49, p50)
	-- upvalues: (copy) v_u_16
	if p49.__Flipbook then
		local v51 = p50:FindFirstChildOfClass("Decal")
		local v52 = Enum.EasingStyle[p49.Settings.EasingStyle]
		local v53 = Enum.EasingDirection[p49.Settings.EasingDirection]
		v_u_16(p49.__Flipbook, v51, p49.Settings.Lifetime, v52, v53)
	end
end

function v_u_1.Emit(p_u_54, p55)
	-- upvalues: (copy) v_u_25, (copy) v_u_4, (copy) v_u_2
	local v56 = p_u_54.Settings.Lifetime
	local v57 = Enum.EasingStyle[p_u_54.Settings.EasingStyle]
	local v58 = Enum.EasingDirection[p_u_54.Settings.EasingDirection]
	local v59 = p_u_54.Settings.Transparency or 1
	local v60 = p_u_54.Settings.StartTransparency or 1
	local v61 = p_u_54.Settings.RotationX
	local v62 = not v61 and 0 or math.random(v61.Min, v61.Max)
	local v63 = p_u_54.Settings.RotationY
	local v64 = not v63 and 0 or math.random(v63.Min, v63.Max)
	local v65 = p_u_54.Settings.RotationZ
	local v66 = not v65 and 0 or math.random(v65.Min, v65.Max)
	local v67 = TweenInfo.new(v56, v57, v58)
	local v_u_68 = p_u_54.Model.Start:Clone()
	if p_u_54.Model:FindFirstChildOfClass("Folder") or p_u_54.Model:FindFirstChildOfClass("ModuleScript") then
		p_u_54:SetFlipbook(p_u_54.Model:FindFirstChildOfClass("ModuleScript") or v_u_25(p_u_54.Model:FindFirstChildOfClass("Folder")))
	end
	p_u_54:PlayFlipbook(v_u_68)
	if not v_u_68:FindFirstChildOfClass("Weld") then
		v_u_68.CFrame = typeof(p55) == "CFrame" and p55 and p55 or p55.CFrame
	end
	v_u_68.Parent = workspace.Thrown
	v_u_4:AddItem(v_u_68, v56)
	local v69 = v_u_68:FindFirstChildWhichIsA("Weld", true) or v_u_68:FindFirstChildWhichIsA("WeldConstraint", true)
	local v70 = p_u_54.Model.Start.CFrame:ToObjectSpace(p_u_54.Model.End.CFrame)
	p_u_54.EndProperities.Position = nil
	local v71 = v_u_68.CFrame * v70 * CFrame.Angles(math.rad(v62), math.rad(v64), (math.rad(v66)))
	if p_u_54.Type == "SpecialMesh" then
		local v_u_72 = v_u_68:FindFirstChildOfClass("SpecialMesh")
		if v_u_72 and not v69 then
			local v73 = v_u_2:Create(v_u_72, v67, p_u_54.EndProperities)
			local v74 = v_u_2:Create(v_u_68, v67, {
				["CFrame"] = v71
			})
			local v_u_75 = nil
			v_u_75 = v73.Completed:Connect(function()
				-- upvalues: (copy) v_u_72, (copy) p_u_54, (copy) v_u_68, (ref) v_u_75
				v_u_72.Scale = p_u_54.Properities.Scale or Vector3.new(1, 1, 1)
				v_u_68.Transparency = 1
				if v_u_75 and v_u_75.Connected then
					v_u_75:Disconnect()
				end
			end)
			v73:Play()
			v74:Play()
		end
	elseif not v69 then
		if p_u_54.Settings.Movement then
			p_u_54.EndProperities.CFrame = v71
		end
		p_u_54.EndProperities.Transparency = v59
		local v76 = v_u_2:Create(v_u_68, v67, p_u_54.EndProperities)
		local v_u_77 = nil
		v_u_77 = v76.Completed:Connect(function()
			-- upvalues: (copy) v_u_68, (copy) p_u_54, (ref) v_u_77
			v_u_68.Size = p_u_54.Properities.Size or Vector3.new(1, 1, 1)
			v_u_68.Transparency = 1
			if v_u_77 and v_u_77.Connected then
				v_u_77:Disconnect()
			end
		end)
		v76:Play()
	end
	local v78 = TweenInfo.new(v56, Enum.EasingStyle[p_u_54.Settings.TransparencyEasingStyle], Enum.EasingDirection[p_u_54.Settings.TransparencyEasingDirection])
	local v79 = v_u_68:GetDescendants()
	local v80 = false
	for _, v81 in ipairs(v79) do
		if v81:IsA("Decal") then
			v80 = true
			v81.Transparency = v60
			local v82 = p_u_54.Model.End:FindFirstChildOfClass("Decal")
			local v83 = {
				["Transparency"] = v59
			}
			if v82 then
				v83.Color3 = v82.Color3
			end
			v_u_2:Create(v81, v78, v83):Play()
		end
	end
	if not v80 then
		v_u_68.Transparency = v60
		v_u_2:Create(v_u_68, v78, {
			["Transparency"] = v59
		}):Play()
	end
end
function v_u_1.EmitRate(p_u_84, p_u_85, p86, p_u_87)
	-- upvalues: (copy) v_u_3
	local v_u_88 = 0
	local v90 = v_u_3.Heartbeat:Connect(function(p89)
		-- upvalues: (ref) v_u_88, (copy) p_u_85, (copy) p_u_84, (copy) p_u_87
		v_u_88 = v_u_88 + p89
		if v_u_88 > p_u_85 / 60 then
			v_u_88 = 0
			p_u_84:Emit(p_u_87)
		end
	end)
	local v91 = p_u_84.__connections
	table.insert(v91, v90)
	local v_u_92 = v90
	task.delay(p86, function()
		-- upvalues: (ref) v_u_92
		if v_u_92.Connected then
			v_u_92:Disconnect()
		end
	end)
end
return v_u_1
