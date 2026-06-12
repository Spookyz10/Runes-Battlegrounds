-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
return {
	["SpawnProjectiles"] = function(p2)
		-- upvalues: (copy) v_u_1
		local v3 = p2.root
		local v_u_4 = p2.projectile
		local v_u_5 = p2.onHit or function() end
		local v6 = p2.count or 1
		local v7 = p2.spreadRadius or 5
		local v8 = p2.startHeight or 5
		local v_u_9 = p2.duration or 1
		local v_u_10 = p2.arcHeight or 10
		local v11 = p2.evenlySpaced or false
		local v_u_12 = p2.rotate or false
		local v13 = p2.spawnDelay or 0
		local v_u_14 = p2.lifetime or 1
		local v_u_15 = v3.Position + Vector3.new(0, v8, 0)
		for v16 = 1, v6 do
			local v17
			if v11 then
				local v18 = v16 / v6 * 3.141592653589793 * 2
				local v19 = math.cos(v18) * v7
				local v20 = math.sin(v18) * v7
				v17 = Vector3.new(v19, 0, v20)
			else
				local v21 = math.random(-v7, v7)
				local v22 = math.random
				local v23 = -v7
				v17 = Vector3.new(v21, 0, v22(v23, v7))
			end
			local v_u_24 = v3.Position + v17
			local v25 = math.random() * v13
			task.delay(v25, function()
				-- upvalues: (copy) v_u_4, (copy) v_u_15, (copy) v_u_24, (copy) v_u_10, (copy) v_u_9, (ref) v_u_1, (copy) v_u_5, (copy) v_u_14, (copy) v_u_12
				local v_u_26 = v_u_4:Clone()
				v_u_26.CFrame = CFrame.new(v_u_15)
				v_u_26.Parent = workspace.Thrown
				local v27 = v_u_10
				local v_u_28 = (v_u_15 + v_u_24) / 2 + Vector3.new(0, v27, 0)
				local v_u_29 = v_u_9 / 30
				local v_u_30 = 0
				local v_u_31 = nil
				v_u_31 = v_u_1.Heartbeat:Connect(function(p32)
					-- upvalues: (ref) v_u_30, (copy) v_u_29, (ref) v_u_31, (copy) v_u_26, (ref) v_u_5, (ref) v_u_14, (ref) v_u_15, (copy) v_u_28, (ref) v_u_24, (ref) v_u_12
					v_u_30 = v_u_30 + p32 / v_u_29
					if v_u_30 >= 30 then
						v_u_31:Disconnect()
						if v_u_26 and v_u_26.Parent then
							for _, v33 in ipairs(v_u_26:GetChildren()) do
								if v33:IsA("ParticleEmitter") then
									v33:Emit(v33:GetAttribute("EmitCount") or 30)
								end
							end
							v_u_5(v_u_26.Position, v_u_26)
							task.delay(v_u_14, function()
								-- upvalues: (ref) v_u_26
								if v_u_26 and v_u_26.Parent then
									v_u_26:Destroy()
								end
							end)
							return
						end
					else
						local v34 = v_u_30 / 30
						local v35 = v_u_15
						local v36 = v_u_28
						local v37 = v_u_24
						local v38 = (1 - v34) ^ 2 * v35 + 2 * (1 - v34) * v34 * v36 + v34 ^ 2 * v37
						v_u_26.CFrame = CFrame.new(v38)
						if v_u_12 then
							local v39 = (v_u_24 - v38).Unit
							v_u_26.CFrame = CFrame.new(v38, v38 + v39)
						end
					end
				end)
			end)
		end
	end
}
