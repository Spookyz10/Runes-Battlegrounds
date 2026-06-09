local v_u_1 = game:GetService("TweenService")
local v_u_2 = game:GetService("Debris")
local v_u_3 = game:GetService("RunService")

local v4 = {}

local function v_u_18(p5, p6, p7, p8, p9)
	local v10 = 1 - p5
	local v11 = v10 * v10
	local v12 = v11 * v10
	local v13 = p5 * p5
	local v14 = v13 * p5
	local v15 = p6.Position * v12 + p7.Position * (v11 * 3 * p5) + p8.Position * (v10 * 3 * v13) + p9.Position * v14
	local v16 = (p7.Position - p6.Position) * (v11 * 3) + (p8.Position - p7.Position) * (v10 * 6 * p5) + (p9.Position - p8.Position) * (v13 * 3)
	if v16.Magnitude < 0.001 then
		if p5 < 0.5 then
			v16 = (p7.Position - p6.Position).Unit
		else
			v16 = (p9.Position - p8.Position).Unit
		end
		if v16.Magnitude < 0.001 then
			local v17 = p9.Position - p6.Position
			v16 = v17.Magnitude < 0.001 and Vector3.new(0, 0, -1) or v17
		end
	end
	return CFrame.lookAt(v15, v15 + v16)
end

function v4.Create(p_u_19, p20)
	local v21 = p20 or {}
	local v22 = v21.Count or 30
	local v_u_23 = v21.SpawnRadius or 20
	local v_u_24 = v21.MinDuration or 0.8
	local v_u_25 = v21.MaxDuration or 1.5
	local v_u_26 = v21.Lifetime or 2
	local v_u_27 = v21.ParticleTemplate
	local v_u_28 = v21.ControlPointHeight or 15
	local v_u_29 = v21.RandomControlOffset or 8
	local v_u_30 = v21.Parent or workspace.Thrown
	local v_u_31 = v21.EasingStyle or Enum.EasingStyle.Quart
	local v_u_32 = v21.EasingDirection or Enum.EasingDirection.Out
	local v_u_33 = v21.SpawnDelay or 0.05
	local v_u_34 = v21.ColorSequence
	local v_u_35 = v21.TransparencySequence
	local v_u_36 = v21.SwirlStrength or 0
	
	if v_u_27 and v_u_27:IsA("BasePart") then
		for v_u_37 = 1, v22 do
			task.spawn(function()
				if v_u_33 > 0 then
					task.wait(v_u_37 * v_u_33)
				end
				
				local v_u_38 = v_u_27:Clone()
				v_u_38.Anchored = false
				v_u_38.CanCollide = false
				v_u_38.CanTouch = false
				v_u_38.Massless = true
				v_u_38.Parent = v_u_30
				local v39 = math.random() * 2 - 1
				local v40 = math.random() * 2 - 1
				local v41 = math.random() * 2 - 1
				local v42 = Vector3.new(v39, v40, v41).Unit * math.random(0, v_u_23)
				local v43 = p_u_19
				local v_u_44
				
				if typeof(v43) == "CFrame" then
					v_u_44 = p_u_19
				else
					v_u_44 = p_u_19.CFrame
				end
				
				local v_u_45 = CFrame.new(v_u_44.Position + v42)
				v_u_38.CFrame = v_u_45
				local v46 = math.random(v_u_24 * 100, v_u_25 * 100) / 100
				local v47 = v_u_45:Lerp(v_u_44, 0.5)
				local v48 = v_u_29
				local v49 = math.abs(v48)
				local v50 = math.random() * 2 - 1
				local v51 = math.random() * 2 - 1
				local v52 = math.random() * 2 - 1
				local v53 = Vector3.new(v50, v51, v52).Unit * (math.random() * v49)
				local v54 = math.random() * 2 - 1
				local v55 = math.random() * 2 - 1
				local v56 = math.random() * 2 - 1
				local v57 = Vector3.new(v54, v55, v56).Unit * (math.random() * v49)
				local v58 = (v_u_44.Position - v_u_45.Position).Unit
				local v59 = v58:Cross(Vector3.new(0, 1, 0))
				
				if v59.Magnitude < 0.001 then
					v59 = v58:Cross(Vector3.new(0, 0, -1))
				end
				
				local v60 = v59.Unit
				local v61 = v60 * (math.random() * 2 - 1) * v_u_36
				local v62 = v60 * (math.random() * 2 - 1) * v_u_36
				local v63 = v_u_28
				local v64 = v_u_45.Position:Lerp(v47.Position, 0.3) + Vector3.new(0, v63, 0) + v53 + v61
				local v65 = v_u_28
				local v66 = v47.Position:Lerp(v_u_44.Position, 0.7) + Vector3.new(0, v65, 0) + v57 + v62
				local v_u_67 = CFrame.new(v64)
				local v_u_68 = CFrame.new(v66)
				local v_u_69 = Instance.new("NumberValue")
				v_u_69.Value = 0
				v_u_69.Parent = nil
				local v_u_70 = v_u_1:Create(v_u_69, TweenInfo.new(v46, v_u_31, v_u_32, 0, false, 0), {
					["Value"] = 1
				})
				local v_u_71 = nil
				v_u_71 = v_u_3.Heartbeat:Connect(function()
					if v_u_38 and (v_u_38.Parent and v_u_70.PlaybackState == Enum.PlaybackState.Playing) then
						v_u_38.CFrame = v_u_18(v_u_69.Value, v_u_45, v_u_67, v_u_68, v_u_44)
					elseif v_u_71 then
						v_u_71:Disconnect()
						v_u_71 = nil
					end
				end)
				
				local v72 = v_u_34 and v_u_38:FindFirstChildOfClass("Trail")
				if v72 then
					v72.Color = v_u_34
				end
				
				local v73 = v_u_35 and v_u_38:FindFirstChildOfClass("Trail")
				if v73 then
					v73.Transparency = v_u_35
				end
				
				v_u_70:Play()
				v_u_70.Completed:Connect(function()
					if v_u_71 then
						v_u_71:Disconnect()
						v_u_71 = nil
					end
					v_u_69:Destroy()
				end)
				
				v_u_2:AddItem(v_u_38, v_u_26)
			end)
		end
	else
		warn("BezierChargeEffect.Create: ParticleTemplate is required and must be a BasePart.")
	end
end
return v4
