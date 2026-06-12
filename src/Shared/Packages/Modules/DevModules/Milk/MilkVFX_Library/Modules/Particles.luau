local v_u_1 = game:GetService("Workspace")
local v_u_2 = game:GetService("Players")

local v_u_3 = Color3.fromRGB(128, 128, 128)

local function v_u_6(p4)
	if p4:IsA("BasePart") then
		return p4
	end
	if p4:IsA("Model") then
		if p4.PrimaryPart then
			return p4.PrimaryPart
		end
		for _, v5 in ipairs(p4:GetDescendants()) do
			if v5:IsA("BasePart") then
				return v5
			end
		end
	end
	return nil
end

local function v_u_12(p7)
	local v8 = { p7 }
	for _, v9 in ipairs(v_u_2:GetPlayers()) do
		if v9.Character then
			local v10 = v9.Character
			table.insert(v8, v10)
		end
	end
	
	local v11 = v_u_1:FindFirstChild("Thrown")
	
	if v11 then
		table.insert(v8, v11)
	end
	
	return v8
end
local function v_u_23(p13, p14, p15)
	if not p13 then
		return {
			["Color"] = v_u_3,
			["Material"] = Enum.Material.Air,
			["Hit"] = false
		}
	end
	
	local v16 = RaycastParams.new()
	v16.FilterType = Enum.RaycastFilterType.Exclude
	v16.FilterDescendantsInstances = v_u_12(p15)
	
	local v17 = p13.Position + Vector3.new(0, -0.25, 0)
	local v18 = -math.max(p14, 1)
	local v19 = v_u_1:Raycast(v17, Vector3.new(0, v18, 0), v16)
	
	if v19 and v19.Instance then
		return {
			["Color"] = v19.Instance.Color,
			["Material"] = v19.Material,
			["Hit"] = true
		}
	end
	
	local v20 = v_u_3
	local v21 = p15.GetAttribute
	local v22
	
	if typeof(v21) == "function" then
		v22 = p15:GetAttribute("GroundFallbackColor")
		if typeof(v22) ~= "Color3" then
			v22 = v20
		end
	else
		v22 = v20
	end
	
	return {
		["Color"] = v22,
		["Material"] = Enum.Material.Air,
		["Hit"] = false
	}
end

local v_u_24 = {
	["Rock"] = { Enum.Material.Slate, Enum.Material.Concrete, Enum.Material.Rock },
	["Grass"] = { Enum.Material.Grass }
}

local function v_u_27(p25, p26)
	if p25.Name == "Smoke" then
		p25.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p26), ColorSequenceKeypoint.new(1, p26) })
	end
end

return {
	["emitParticles"] = function(p28)
		local v29 = v_u_23(v_u_6(p28), 20, p28)
		for _, v_u_30 in p28:GetDescendants() do
			if v_u_30:IsA("ParticleEmitter") then
				local v31 = v_u_30.Name
				local v32 = v29.Material
				local v33 = v_u_24[v31]
				local v35 = true
				
				if v33 then
					for _, v34 in ipairs(v33) do
						if v34 == v32 then
							v35 = true
						end
					end
					
					v35 = false
				end
				
				local v35 = true
				if v35 then
					v_u_27(v_u_30, v29.Color)
					local v36 = v_u_30:GetAttribute("EmitDelay")
					local v_u_37 = v_u_30:GetAttribute("EmitCount") or 0
					local v_u_38 = v_u_30:GetAttribute("EmitDuration")
					
					if v_u_37 > 0 then
						if v36 then
							task.delay(v36, function()
								if v_u_30.Parent then
									v_u_30:Emit(v_u_37)
								end
							end)
						elseif v_u_30.Parent then
							v_u_30:Emit(v_u_37)
						end
					end
					
					if v_u_38 then
						if v36 then
							task.delay(v36, function()
								if v_u_30.Parent then
									v_u_30.Enabled = true
									task.wait(v_u_38)
									if v_u_30.Parent then
										v_u_30.Enabled = false
									end
								end
							end)
						else
							v_u_30.Enabled = true
							
							task.delay(v_u_38, function()
								if v_u_30.Parent then
									v_u_30.Enabled = false
								end
							end)
						end
					end
				else
					v_u_30.Enabled = false
				end
			end
		end
	end,
	
	["enableParticles"] = function(p39)
		local v_u_40 = v_u_23(v_u_6(p39), 20, p39)
		local function v47(p41)
			if not p41:IsA("ParticleEmitter") then
				if p41:IsA("Trail") or p41:IsA("Beam") then
					p41.Enabled = true
				end
				return
			end
			
			local v42 = p41.Name
			local v43 = v_u_40.Material
			local v44 = v_u_24[v42]
			local v45
			if v44 then
				for _, v46 in ipairs(v44) do
					if v46 == v43 then
						v45 = true
					end
				end
				v45 = false
			else
				v45 = true
				if v45 then
					v_u_27(p41, v_u_40.Color)
					p41.Enabled = true
				else
					p41.Enabled = false
				end
			end
		end
		
		v47(p39)
		for _, v48 in p39:GetDescendants() do
			v47(v48)
		end
	end,
	
	["disableParticles"] = function(p49)
		if p49:IsA("ParticleEmitter") or (p49:IsA("Trail") or p49:IsA("Beam")) then
			p49.Enabled = false
		end
		
		for _, v50 in p49:GetDescendants() do
			if v50:IsA("ParticleEmitter") or (v50:IsA("Trail") or v50:IsA("Beam")) then
				v50.Enabled = false
			end
		end
	end
}
