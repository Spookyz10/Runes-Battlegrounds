-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("TweenService")
VFXService = {
	["GetRandomNumber"] = function(p2, p3)
		local v4 = typeof(p2) ~= "number" and 0 or p2
		local v5 = typeof(p3) ~= "number" and 6.283185307179586 or p3
		if v5 > v4 then
			return Random.new():NextNumber(v4, v5)
		end
	end,
	["Destroy"] = function(p_u_6, p7)
		local v_u_8 = typeof(p7) ~= "number" and 0 or p7
		if typeof(p_u_6) == "table" then
			task.spawn(function()
				-- upvalues: (copy) p_u_6, (ref) v_u_8
				for _, v_u_9 in pairs(p_u_6) do
					task.delay(v_u_8, function()
						-- upvalues: (copy) v_u_9
						if v_u_9 ~= nil and v_u_9.Parent ~= nil then
							v_u_9:Destroy()
						end
					end)
				end
			end)
		end
		if typeof(p_u_6) == "Instance" and (p_u_6 ~= nil and p_u_6.Parent ~= nil) then
			task.delay(v_u_8, function()
				-- upvalues: (copy) p_u_6
				if p_u_6 ~= nil and p_u_6.Parent ~= nil then
					p_u_6:Destroy()
				end
			end)
		end
	end,
	["EnableParticles"] = function(p_u_10, p11)
		if typeof(p_u_10) == "Instance" then
			local v_u_12 = typeof(p11) ~= "boolean" and true or p11
			if p_u_10:IsA("ParticleEmitter") then
				local v13 = p_u_10:GetAttribute("EmitDelay")
				if typeof(v13) == "number" and v13 > 0 then
					task.delay(v13, function()
						-- upvalues: (copy) p_u_10, (ref) v_u_12
						if p_u_10 ~= nil and p_u_10.Parent ~= nil then
							p_u_10.Enabled = v_u_12
						end
					end)
				else
					p_u_10.Enabled = v_u_12
				end
			elseif p_u_10:IsA("Beam") then
				local v14 = p_u_10:GetAttribute("EmitDelay")
				if typeof(v14) == "number" and v14 > 0 then
					task.delay(v14, function()
						-- upvalues: (copy) p_u_10, (ref) v_u_12
						if p_u_10 ~= nil and p_u_10.Parent ~= nil then
							p_u_10.Enabled = v_u_12
						end
					end)
				else
					p_u_10.Enabled = v_u_12
				end
			elseif p_u_10:IsA("Trail") then
				local v15 = p_u_10:GetAttribute("EmitDelay")
				if typeof(v15) == "number" and v15 > 0 then
					task.delay(v15, function()
						-- upvalues: (copy) p_u_10, (ref) v_u_12
						if p_u_10 ~= nil and p_u_10.Parent ~= nil then
							p_u_10.Enabled = v_u_12
						end
					end)
				else
					p_u_10.Enabled = v_u_12
				end
			end
			task.spawn(function()
				-- upvalues: (copy) p_u_10, (ref) v_u_12
				for _, v_u_16 in pairs(p_u_10:GetDescendants()) do
					if v_u_16:IsA("ParticleEmitter") then
						local v17 = v_u_16:GetAttribute("EmitDelay")
						if typeof(v17) == "number" and v17 > 0 then
							task.delay(v17, function()
								-- upvalues: (copy) v_u_16, (ref) v_u_12
								if v_u_16 ~= nil and v_u_16.Parent ~= nil then
									v_u_16.Enabled = v_u_12
								end
							end)
						else
							v_u_16.Enabled = v_u_12
						end
					elseif v_u_16:IsA("Beam") then
						local v18 = v_u_16:GetAttribute("EmitDelay")
						if typeof(v18) == "number" and v18 > 0 then
							task.delay(v18, function()
								-- upvalues: (copy) v_u_16, (ref) v_u_12
								if v_u_16 ~= nil and v_u_16.Parent ~= nil then
									v_u_16.Enabled = v_u_12
								end
							end)
						else
							v_u_16.Enabled = v_u_12
						end
					elseif v_u_16:IsA("Trail") then
						local v19 = v_u_16:GetAttribute("EmitDelay")
						if typeof(v19) == "number" and v19 > 0 then
							task.delay(v19, function()
								-- upvalues: (copy) v_u_16, (ref) v_u_12
								if v_u_16 ~= nil and v_u_16.Parent ~= nil then
									v_u_16.Enabled = v_u_12
								end
							end)
						else
							v_u_16.Enabled = v_u_12
						end
					end
				end
			end)
		end
	end,
	["EmitParticles"] = function(p_u_20)
		if typeof(p_u_20) == "Instance" then
			if p_u_20:IsA("ParticleEmitter") then
				local v21 = p_u_20:GetAttribute("EmitDelay")
				if typeof(v21) == "number" and v21 > 0 then
					task.delay(v21, function()
						-- upvalues: (copy) p_u_20
						if p_u_20 ~= nil and p_u_20.Parent ~= nil then
							local v22 = p_u_20
							local v23 = p_u_20:GetAttribute("EmitCount")
							if not v23 then
								local v24 = p_u_20.Name
								v23 = tonumber(v24) or 1
							end
							v22:Emit(v23)
							local v25 = p_u_20
							local v26 = tonumber(v25:GetAttribute("EmitDuration"))
							if typeof(v26) == "number" and v26 > 0 then
								p_u_20.Enabled = true
								task.delay(v26, function()
									-- upvalues: (ref) p_u_20
									if p_u_20 ~= nil and p_u_20.Parent ~= nil then
										p_u_20.Enabled = false
									end
								end)
							end
						end
					end)
				else
					local v27 = p_u_20:GetAttribute("EmitCount")
					if not v27 then
						local v28 = p_u_20.Name
						v27 = tonumber(v28) or 1
					end
					p_u_20:Emit(v27)
					local v29 = tonumber(p_u_20:GetAttribute("EmitDuration"))
					if typeof(v29) == "number" and v29 > 0 then
						p_u_20.Enabled = true
						task.delay(v29, function()
							-- upvalues: (copy) p_u_20
							if p_u_20 ~= nil and p_u_20.Parent ~= nil then
								p_u_20.Enabled = false
							end
						end)
					end
				end
			elseif p_u_20:IsA("Beam") then
				local v_u_30 = p_u_20:GetAttribute("EmitDuration")
				if typeof(v_u_30) == "number" and v_u_30 > 0 then
					local v31 = p_u_20:GetAttribute("EmitDelay")
					if typeof(v31) == "number" and v31 > 0 then
						task.delay(v31, function()
							-- upvalues: (copy) p_u_20, (copy) v_u_30
							if p_u_20 ~= nil and p_u_20.Parent ~= nil then
								p_u_20.Enabled = true
								task.delay(v_u_30, function()
									-- upvalues: (ref) p_u_20
									if p_u_20 ~= nil and p_u_20.Parent ~= nil then
										p_u_20.Enabled = false
									end
								end)
							end
						end)
					else
						p_u_20.Enabled = true
						task.delay(v_u_30, function()
							-- upvalues: (copy) p_u_20
							if p_u_20 ~= nil and p_u_20.Parent ~= nil then
								p_u_20.Enabled = false
							end
						end)
					end
				end
			end
			task.spawn(function()
				-- upvalues: (copy) p_u_20
				for _, v_u_32 in pairs(p_u_20:GetDescendants()) do
					if v_u_32:IsA("ParticleEmitter") then
						local v33 = v_u_32:GetAttribute("EmitDelay")
						if typeof(v33) == "number" and v33 > 0 then
							task.delay(v33, function()
								-- upvalues: (copy) v_u_32
								if v_u_32 ~= nil and v_u_32.Parent ~= nil then
									local v34 = v_u_32
									local v35 = v_u_32:GetAttribute("EmitCount")
									if not v35 then
										local v36 = v_u_32.Name
										v35 = tonumber(v36) or 1
									end
									v34:Emit(v35)
									local v37 = v_u_32
									local v38 = tonumber(v37:GetAttribute("EmitDuration"))
									if typeof(v38) == "number" and v38 > 0 then
										v_u_32.Enabled = true
										task.delay(v38, function()
											-- upvalues: (ref) v_u_32
											if v_u_32 ~= nil and v_u_32.Parent ~= nil then
												v_u_32.Enabled = false
											end
										end)
									end
								end
							end)
						else
							local v39 = v_u_32:GetAttribute("EmitCount")
							if not v39 then
								local v40 = v_u_32.Name
								v39 = tonumber(v40) or 1
							end
							v_u_32:Emit(v39)
							local v41 = tonumber(v_u_32:GetAttribute("EmitDuration"))
							if typeof(v41) == "number" and v41 > 0 then
								v_u_32.Enabled = true
								task.delay(v41, function()
									-- upvalues: (copy) v_u_32
									if v_u_32 ~= nil and v_u_32.Parent ~= nil then
										v_u_32.Enabled = false
									end
								end)
							end
						end
					elseif v_u_32:IsA("Beam") then
						local v42 = v_u_32:GetAttribute("EmitDuration")
						if typeof(v42) == "number" and v42 > 0 then
							local v_u_43 = v_u_32:GetAttribute("EmitDelay")
							if typeof(v_u_43) == "number" and v_u_43 > 0 then
								task.delay(v_u_43, function()
									-- upvalues: (copy) v_u_32, (copy) v_u_43
									if v_u_32 ~= nil and v_u_32.Parent ~= nil then
										v_u_32.Enabled = true
										task.delay(v_u_43, function()
											-- upvalues: (ref) v_u_32
											if v_u_32 ~= nil and v_u_32.Parent ~= nil then
												v_u_32.Enabled = false
											end
										end)
									end
								end)
							else
								v_u_32.Enabled = true
								task.delay(v_u_43, function()
									-- upvalues: (copy) v_u_32
									if v_u_32 ~= nil and v_u_32.Parent ~= nil then
										v_u_32.Enabled = false
									end
								end)
							end
						end
					end
				end
			end)
		end
	end,
	["EmitMesh"] = function(p_u_44)
		-- upvalues: (copy) v_u_1
		if p_u_44:IsA("Model") and (p_u_44 ~= nil and p_u_44.Parent ~= nil) then
			local v_u_45 = p_u_44:FindFirstChild("Start")
			local v_u_46 = p_u_44:FindFirstChild("End")
			local v47 = p_u_44:GetAttribute("Time")
			local v48 = p_u_44:GetAttribute("Delay")
			local v_u_49 = (typeof(v47) ~= "number" or v47 <= 0) and 0.25 or v47
			local v50 = (typeof(v48) ~= "number" or v48 < 0) and 0 or v48
			local v51 = p_u_44:GetAttribute("Time2")
			if typeof(v51) == "number" and v_u_49 < v51 then
				v_u_49 = VFXService.GetRandomNumber(v_u_49, v51)
			end
			local v52 = p_u_44:GetAttribute("EasingStyle")
			local v53 = p_u_44:GetAttribute("EasingDirection")
			local v_u_54
			if typeof(v52) == "string" and Enum.EasingStyle[v52] ~= nil then
				v_u_54 = Enum.EasingStyle[v52]
			else
				v_u_54 = Enum.EasingStyle.Linear
			end
			local v_u_55
			if typeof(v53) == "string" and Enum.EasingDirection[v53] ~= nil then
				v_u_55 = Enum.EasingDirection[v53]
			else
				v_u_55 = Enum.EasingDirection.Out
			end
			local v56 = p_u_44:GetAttribute("DelayAll")
			if typeof(v56) ~= "boolean" then
				v56 = false
			end
			local v57 = p_u_44:GetAttribute("Scale")
			local v58 = (typeof(v57) ~= "number" or v57 < 0) and 1 or v57
			VFXService.Destroy({ v_u_45, p_u_44 }, v_u_49)
			if v_u_45 ~= nil and v_u_46 ~= nil then
				p_u_44:ScaleTo(v58)
				if (v_u_45:IsA("Part") or v_u_45:IsA("MeshPart")) and (v_u_46:IsA("Part") or v_u_46:IsA("MeshPart")) then
					v_u_46.Parent = nil
					task.delay(v_u_49, function()
						-- upvalues: (copy) v_u_46
						if v_u_46 ~= nil then
							v_u_46:Destroy()
						end
					end)
					p_u_44.Parent = workspace.Thrown
					if v_u_45:FindFirstChild("Decal") then
						if v_u_46:FindFirstChild("Decal") then
							task.delay(v50, function()
								-- upvalues: (copy) v_u_45, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (copy) v_u_46, (ref) v_u_1
								if v_u_45 ~= nil and v_u_45:FindFirstChild("Decal") ~= nil then
									v_u_1:Create(v_u_45.Decal, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Transparency"] = v_u_46.Decal.Transparency
									}):Play()
								end
							end)
						else
							task.delay(v50, function()
								-- upvalues: (copy) v_u_45, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (ref) v_u_1
								if v_u_45 ~= nil and v_u_45:FindFirstChild("Decal") ~= nil then
									v_u_1:Create(v_u_45.Decal, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Transparency"] = 1
									}):Play()
								end
							end)
						end
					end
					if v_u_45:FindFirstChild("Decal1") then
						if v_u_46:FindFirstChild("Decal1") then
							task.delay(v50, function()
								-- upvalues: (copy) v_u_45, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (copy) v_u_46, (ref) v_u_1
								if v_u_45 ~= nil and v_u_45:FindFirstChild("Decal1") ~= nil then
									v_u_1:Create(v_u_45.Decal1, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Transparency"] = v_u_46.Decal1.Transparency
									}):Play()
								end
							end)
						else
							task.delay(v50, function()
								-- upvalues: (copy) v_u_45, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (ref) v_u_1
								if v_u_45 ~= nil and v_u_45:FindFirstChild("Decal1") ~= nil then
									v_u_1:Create(v_u_45.Decal1, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Transparency"] = 1
									}):Play()
								end
							end)
						end
					end
					if v56 == true then
						task.delay(v50, function()
							-- upvalues: (copy) v_u_45, (copy) v_u_46, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (ref) v_u_1, (copy) p_u_44
							if v_u_45 ~= nil and v_u_45:FindFirstChild("Mesh") ~= nil then
								if v_u_46 == nil or v_u_46:FindFirstChild("Mesh") == nil then
									v_u_1:Create(v_u_45.Mesh, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Scale"] = Vector3.new(0, 0, 0)
									}):Play()
								else
									v_u_1:Create(v_u_45.Mesh, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
										["Offset"] = v_u_46.Mesh.Offset,
										["Scale"] = v_u_46.Mesh.Scale
									}):Play()
								end
							end
							if p_u_44 ~= nil and p_u_44:FindFirstChild("Start") ~= nil then
								v_u_1:Create(p_u_44.Start, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
									["Size"] = v_u_46.Size
								}):Play()
							end
						end)
						v_u_1:Create(p_u_44.Start, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
							["CFrame"] = v_u_46.CFrame
						}):Play()
					else
						if v_u_45 ~= nil and v_u_45:FindFirstChild("Mesh") ~= nil then
							if v_u_46 == nil or v_u_46:FindFirstChild("Mesh") == nil then
								v_u_1:Create(v_u_45.Mesh, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
									["Scale"] = Vector3.new(0, 0, 0)
								}):Play()
							else
								v_u_1:Create(v_u_45.Mesh, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
									["Offset"] = v_u_46.Mesh.Offset,
									["Scale"] = v_u_46.Mesh.Scale
								}):Play()
							end
						end
						if p_u_44 ~= nil and (p_u_44:FindFirstChild("Start") ~= nil and v_u_46 ~= nil) then
							if v_u_45.CFrame ~= v_u_46.CFrame then
								v_u_1:Create(p_u_44.Start, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
									["CFrame"] = v_u_46.CFrame
								}):Play()
							end
							if v_u_45.Size ~= v_u_46.Size then
								v_u_1:Create(p_u_44.Start, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
									["Size"] = v_u_46.Size
								}):Play()
							end
						end
					end
					task.delay(v50, function()
						-- upvalues: (copy) p_u_44, (ref) v_u_49, (ref) v_u_54, (ref) v_u_55, (ref) v_u_1
						if p_u_44 ~= nil and p_u_44:FindFirstChild("Start") ~= nil then
							v_u_1:Create(p_u_44.Start, TweenInfo.new(v_u_49, v_u_54, v_u_55), {
								["Transparency"] = 1
							}):Play()
						end
					end)
				end
			end
		end
	end,
	["CreateRotation"] = function(p_u_59, p_u_60, p61)
		if p_u_59 ~= nil and p_u_59.Parent ~= nil then
			if typeof(p_u_60) ~= "CFrame" then
				p_u_60 = CFrame.new(0, 0, 0)
			end
			if typeof(p61) == "number" and p61 > 0 then
				local v_u_62 = true
				task.delay(p61, function()
					-- upvalues: (ref) v_u_62
					v_u_62 = false
				end)
				task.spawn(function()
					-- upvalues: (ref) v_u_62, (copy) p_u_59, (ref) p_u_60
					while v_u_62 do
						local v63 = p_u_59
						v63.CFrame = v63.CFrame * p_u_60
						task.wait()
					end
				end)
			else
				task.spawn(function()
					-- upvalues: (copy) p_u_59, (ref) p_u_60
					while p_u_59 ~= nil and p_u_59.Parent ~= nil do
						local v64 = p_u_59
						v64.CFrame = v64.CFrame * p_u_60
						task.wait()
					end
				end)
			end
		end
	end
}
return VFXService
