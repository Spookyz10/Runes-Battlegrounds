local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("TweenService")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Players")
local v_u_5 = game:GetService("Debris")
local v_u_6 = game:GetService("SoundService")
local v_u_7 = v_u_1.Resources

local v_u_9 = require(v_u_1.Shared.Services.Package.RocksService)

local v_u_13 = RaycastParams.new()
v_u_13.IgnoreWater = true
v_u_13.FilterDescendantsInstances = { workspace.Map }
v_u_13.FilterType = Enum.RaycastFilterType.Include
v_u_13.CollisionGroup = "Map"

local function EmitEffects(p_u_110)
	if p_u_110 then
		if p_u_110:IsA("ParticleEmitter") or p_u_110:IsA("Beam") then
			if p_u_110:IsA("ParticleEmitter") then
				if p_u_110:GetAttribute("EmitCount") and p_u_110:GetAttribute("EmitCount") > 0 then
					if not (p_u_110:GetAttribute("EmitDelay") or p_u_110:GetAttribute("EmitDuration")) then
						p_u_110:Emit(p_u_110:GetAttribute("EmitCount"))
						return
					end

					if p_u_110:GetAttribute("EmitDelay") then
						task.delay(p_u_110:GetAttribute("EmitDelay"), function()
							p_u_110:Emit(p_u_110:GetAttribute("EmitCount"))
						end)
					else
						p_u_110:Emit(p_u_110:GetAttribute("EmitCount"))
					end

					if p_u_110:GetAttribute("EmitDuration") then
						p_u_110.Enabled = true
						task.delay(p_u_110:GetAttribute("EmitDuration"), function()
							p_u_110.Enabled = false
						end)
						return
					end
				else
					if p_u_110:GetAttribute("EmitDuration") and p_u_110:GetAttribute("EmitDuration") > 0 then
						p_u_110.Enabled = true
						task.delay(p_u_110:GetAttribute("EmitDuration"), function()
							p_u_110.Enabled = false
						end)
						return
					end
					if p_u_110:GetAttribute("SetEnabled") then
						p_u_110.Enabled = true
						return
					end
				end
			elseif p_u_110:IsA("Beam") and (p_u_110:GetAttribute("EmitDuration") and p_u_110:GetAttribute("EmitDuration") > 0) then
				p_u_110.Enabled = true
				task.delay(p_u_110:GetAttribute("EmitDuration"), function()
					p_u_110.Enabled = false
				end)
			end
		end
	else
		return
	end
end

local v_u_161 = {
	["get2nd_delayNum"] = function(p27, p28, p29)
		local v30 = p27 - p29
		local v31 = math.min(v30, 0)
		local v32 = p28 - math.abs(v31)
		return math.max(v32, 0)
	end,
	["emitRocksTrail"] = function(p_u_91, p_u_92, p_u_93, p_u_94, p95)
		if v_u_3:IsServer() then
			script.replication:FireAllClients("emitRocksTrail", p_u_91, p_u_92, p_u_93, p_u_94, p95)
		else
			local v_u_96 = tick()
			local v_u_97 = p95 or v_u_13
			coroutine.wrap(function()
				while true do
					local v_u_98 = workspace:Raycast(p_u_91.Position, -p_u_91.CFrame.UpVector * 5, v_u_97)
					if v_u_98 then
						local v_u_99 = v_u_7.VFX.HK_Smoke:Clone()
						v_u_99.Parent = workspace.Thrown
						v_u_99.CFrame = CFrame.new(v_u_98.Position, v_u_98.Position + p_u_91.CFrame.LookVector) * CFrame.new(0, 0.3, 0)
						task.delay(0.01, function()
							v_u_99.ParticleEmitter.Color = ColorSequence.new(v_u_98.Instance.Color)
							v_u_99.ParticleEmitter:Emit(math.random(4, 5))
							v_u_5:AddItem(v_u_99, v_u_99.ParticleEmitter.Lifetime.Max)
						end)
					end
					task.wait(1 / p_u_93)
					if p_u_92 < tick() - v_u_96 then
						return
					end
				end
			end)()

			coroutine.wrap(function()
				while true do
					for v100 = -1, 1, 2 do
						local v_u_101 = v_u_9.Raycast((p_u_91.CFrame * CFrame.new(math.random(2, 3) * v100, 0, math.random(50, 150) / 100 * v100)).Position, Vector3.new(0, -6, 0), v_u_97)
						if v_u_101 then
							local v_u_102 = v_u_9.CreatePart(nil, {
								["Anchored"] = true,
								["CanCollide"] = false,
								["MatchRaycastBehavior"] = true
							}, v_u_101)
							local v103 = CFrame.new(v_u_101.Position)
							local v104 = CFrame.Angles
							local v105 = math.random(-360, 360)
							local v106 = math.rad(v105)
							local v107 = math.random(-360, 360)
							local v108 = math.rad(v107)
							local v109 = math.random(-360, 360)
							v_u_102.CFrame = v103 * v104(v106, v108, (math.rad(v109)))
							v_u_102.Size = Vector3.new(0, 0, 0)

							v_u_9.TweenPart(v_u_102, nil, Vector3.new(1, 1, 1) * math.random(50, 100) / 100, 0.2, 50)
							task.delay(2, function()
								v_u_9.TweenPart(v_u_102, CFrame.new(v_u_101.Position + Vector3.new(0, -1, 0)), Vector3.new(0, 0, 0), 1, 50)
								task.delay(1, function()
									v_u_102:Destroy()
									v_u_102 = nil
									v_u_101 = nil
								end)
							end)
						end
					end

					task.wait(1 / p_u_94)
					if p_u_92 < tick() - v_u_96 then
						return
					end
				end
			end)()
		end
	end,
	
	["hideAreaInRadius"] = function(p_u_142, p_u_143, p_u_144, p_u_145)
		local v_u_146 = tick()
		coroutine.wrap(function()
			local v147 = {}
			for _ = 1, 50 do
				for _, v_u_148 in workspace:GetPartBoundsInRadius(p_u_142, p_u_144, p_u_145) do
					if not v147[v_u_148] then
						v147[v_u_148] = true
						local v_u_149 = v_u_148.Transparency
						v_u_148.Transparency = 1
						local v_u_150 = false
						local v_u_151 = v_u_148:GetPropertyChangedSignal("Transparency"):Connect(function()
							v_u_150 = true
							v_u_148.Transparency = 1
						end)
						
						task.delay(p_u_143, function()
							if v_u_151 then
								v_u_151:Disconnect()
								v_u_151 = nil
							end
							if v_u_149 > 0 and not v_u_150 then
								v_u_148.Transparency = 1
								return
							elseif v_u_149 <= 0 and v_u_150 then
								v_u_148.Transparency = 1
							else
								v_u_148.Transparency = 0
							end
						end)
					end
				end
				task.wait(p_u_143 / 50)
			end
			table.clear(v147)
		end)()
		
		local function v154(p152)
			if table.find(p_u_145.FilterDescendantsInstances, p152) then
				return
			else
				local v153 = p_u_143 - (tick() - v_u_146)
				if v153 > 0 then
					p152:SetAttribute("Invisible", true)
					task.delay(v153, function()
						p152:SetAttribute("Invisible", false)
					end)
				end
			end
		end
		
		for _, v157 in workspace.Live:GetChildren() do
			if not table.find(p_u_145.FilterDescendantsInstances, v157) then
				local v158 = p_u_143 - (tick() - v_u_146)
				if v158 > 0 then
					v157:SetAttribute("Invisible", true)
					task.delay(v158, function()
						v157:SetAttribute("Invisible", false)
					end)
				end
			end
		end
		
		local v_u_159 = workspace.Live.ChildAdded:Connect(v154)
		
		task.delay(p_u_143, function()
			v_u_159:Disconnect()
			v_u_159 = nil
		end)
	end,

	["moveBP_Forward"] = function(p_u_35, p_u_36, p_u_37, p38, p39, p40)
		local v_u_41 = p40 or Vector3.new(0, 0, 0)
		local v_u_42 = script.LinearVelocity:Clone()
		
		
		v_u_5:AddItem(v_u_42, p_u_36)
		v_u_42.Parent = p_u_35
		v_u_42.ForceLimitsEnabled = true
		v_u_42.MaxAxesForce = p38 or Vector3.new(100000, 100000, 100000)
		v_u_42.Attachment0 = p_u_35.RootAttachment
		
		
		if p39 then
			pcall(function()
				for v43 = 1, 10 do
					p_u_35.CFrame = CFrame.new(p_u_35.CFrame.Position, p_u_35.CFrame.Position + p_u_35.CFrame.LookVector * Vector3.new(1, 0, 1))
					local v44 = p_u_35.CFrame.Position
					local v45 = p_u_35.CFrame.LookVector + v_u_41
					local v46 = p_u_37
					local v47 = workspace:Raycast(v44, v45 * v46, v_u_13)
					
					if v47 then
						v_u_42.VectorVelocity = (p_u_35.CFrame.LookVector + v_u_41) * (v47.Distance / 2) * 10
					else
						v_u_42.VectorVelocity = (p_u_35.CFrame.LookVector + v_u_41) * p_u_37 * 10
					end
					
					v_u_42.VectorVelocity = v_u_42.VectorVelocity:Lerp(Vector3.new(0, 0, 0), v43 / 10)
					task.wait((p_u_36 or 0.3) / 10)
				end
			end)
		else
			local v48 = p_u_35.CFrame.Position
			local v49 = p_u_35.CFrame.LookVector + v_u_41
			local v50 = workspace:Raycast(v48, v49 * p_u_37, v_u_13)
			
			if v50 then
				v_u_42.VectorVelocity = (p_u_35.CFrame.LookVector + v_u_41) * (v50.Distance / 2) * 10
			else
				v_u_42.VectorVelocity = (p_u_35.CFrame.LookVector + v_u_41) * p_u_37 * 10
			end
			
			local v_u_51 = v_u_42.VectorVelocity
			pcall(function()
				for v52 = 1, 10 do
					p_u_35.CFrame = CFrame.new(p_u_35.CFrame.Position, p_u_35.CFrame.Position + p_u_35.CFrame.LookVector * Vector3.new(1, 0, 1))
					v_u_42.VectorVelocity = v_u_51:Lerp(Vector3.new(0, 0, 0), v52 / 10)
					task.wait((p_u_36 or 0.3) / 10)
				end
			end)
		end
	end,
	
	["loadCutsceneCamera"] = function(p53, p54)
		if p53 and p53:FindFirstChild("HumanoidRootPart") then
			local v55 = p53.HumanoidRootPart
			local v56 = v_u_7.CutsceneCamera:Clone()
			v_u_5:AddItem(v56, p54)
			v56.Parent = p53
			v56.root_part.CFrame = v55.CFrame
			v56.root_part.Weld.Part0 = v55
			return v56
		end
	end,
	
	["PlayMeshAnimation"] = function(p60, p61, p62)
		if p60 then
			if not p62 then
				local _ = workspace.Thrown
			end
			
			local v_u_63 = p60:Clone()
			v_u_63.Parent = workspace.Thrown
			local v_u_64 = v_u_63.Start
			local v_u_65 = v_u_63.End
			local v_u_66 = v_u_64.CFrame:ToObjectSpace(v_u_65.CFrame)
			local v_u_67 = p61 * v_u_64.Offset.C0
			v_u_64.CFrame = v_u_67
			
			task.delay(0.02, function()
				v_u_2:Create(v_u_64, TweenInfo.new(v_u_64:GetAttribute("TweenTime")), {
					["Size"] = v_u_65.Size,
					["CFrame"] = v_u_67 * v_u_66,
					["Transparency"] = v_u_65.Transparency,
					["Color"] = v_u_65.Color
				}):Play()
				v_u_5:AddItem(v_u_63, v_u_64:GetAttribute("TweenTime"))
			end)
		end
	end,
	
	["PlayImpactFrames"] = function(p68, p69, p70, p_u_71)
		if p68 and p69 then
			local v_u_72 = not p70 or p68:FindFirstChild(p70)
			if v_u_72 then
				local v_u_73 = tick()
				local v_u_74 = nil
				local v75 = #v_u_72:GetChildren()
				local v_u_76 = v75
				pcall(function()
					if v_u_4.LocalPlayer:GetAttribute("Photosensitive_Mode") then
						v_u_76 = 0
					end
				end)
				
				if v_u_76 > 0 then
					p68.Enabled = true
					local v_u_77 = v_u_76 / p69 * 1000
					local v_u_78 = v_u_76
					
					for _, v79 in v_u_72:GetChildren() do
						if v79:IsA("ImageLabel") then
							v79.Visible = not p_u_71
							v79.Position = UDim2.fromScale(0.5, 0.5)
							local v80 = v79.Name
							v79.ZIndex = v75 - (tonumber(v80) or 0)
						end
					end
					
					local _ = v_u_3.RenderStepped:Connect(function()
						local v81 = (tick() - v_u_73) * 1000 / v_u_77 * v_u_78
						local v82 = math.floor(v81) + 1
						
						if v_u_78 < v82 then
							if v_u_74 then
								v_u_74:Disconnect()
								v_u_74 = nil
							end
							
							if v_u_72 then
								for _, v83 in v_u_72:GetChildren() do
									if v83:IsA("ImageLabel") then
										v83.Position = UDim2.fromScale(2, 0.5)
										v83.Visible = true
									end
								end
							end
						else
							if v82 <= 1 then
								local v84 = v_u_72:FindFirstChild(v82)
								if not v84 then
									return
								end
								
								v84.Visible = true
							else
								local v85 = v_u_72:FindFirstChild(v82 - 1)
								if not v85 then
									return
								end
								
								v85.Visible = false
							end
							if p_u_71 then
								local v86 = v_u_72:FindFirstChild(v82 + 1)
								if not v86 then
									return
								end
								
								v86.Visible = true
							end
						end
					end)
				end
			else
				return
			end
		else
			return
		end
	end,
	
	["emit_effect"] = function(p_u_110_2)
		EmitEffects(p_u_110_2)
	end,
	
	["bubbleModule"] = require(script.BubbleModule),
	
	["meshEmit"] = require(script.meshEmit),
	
	["emitFX"] = function(p_u_140)
		task.delay(0.02, function()
			for _, v141 in p_u_140:GetDescendants() do
				EmitEffects(v141)
			end
		end)
	end,
	
	["disable_humanoid_collisions"] = function(p120, p121)
		if p120 then
			if p120:FindFirstChild("Humanoid") then
				for _, v122 in p120:GetDescendants() do
					if v122:IsA("BasePart") then
						if p121 then
							v122.CollisionGroup = "NoHumanoid"
						else
							v122.CollisionGroup = "Humanoid"
						end
					end
				end
			else
				return
			end
		else
			return
		end
	end,
}

return v_u_161
