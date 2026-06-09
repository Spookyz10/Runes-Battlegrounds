local v1 = {}

local v_u_3 = require(script.Bezier)
local v_u_4 = require(script.PartCache)

function v1.CreateBezierTrails(p_u_34, p_u_35, p_u_36, p_u_37, p_u_38, p_u_39, p_u_40)
	task.spawn(function()
		local v_u_41 = v_u_4.new(p_u_34, p_u_39, workspace.Thrown)
		for _ = 1, p_u_39 do
			task.spawn(function()
				local v42
				if p_u_36 then
					v42 = p_u_36.CFrame * p_u_37
				else
					v42 = p_u_37
				end
				
				local v43 = v_u_41:GetPart()
				local v44 = CFrame.Angles
				local v45 = math.random(-180, 180)
				local v46 = math.rad(v45)
				local v47 = math.random(-180, 180)
				local v48 = math.rad(v47)
				local v49 = math.random(-180, 180)
				
				v43.CFrame = v42 * v44(v46, v48, (math.rad(v49))) * CFrame.new(0, 0, -p_u_35)
				v43.CFrame = CFrame.new(v43.Position, v42.Position)
				
				for _, v50 in pairs(v43:GetDescendants()) do
					if v50:IsA("Trail") or v50:IsA("ParticleEmitter") then
						v50.Enabled = true
					end
				end
				
				local v51 = v43.Position
				local v52 = v43.CFrame.upVector * (math.random(-p_u_35 * 100, p_u_35 * 100) / 100) + v43.CFrame.rightVector * (math.random(-p_u_35 * 100, p_u_35 * 100) / 100) + v51
				local v53 = v43.CFrame.lookVector * (p_u_35 / 2) + v43.CFrame.upVector * (math.random(-p_u_35 * 100, p_u_35 * 100) / 100) + v43.CFrame.rightVector * (math.random(-p_u_35 * 100, p_u_35 * 100) / 100) + v43.Position
				local v54 = v42.Position
				local v55 = v_u_3.new(v51, v52, v53, v54):CreateCFrameTween(v43, { "CFrame" }, (TweenInfo.new(p_u_40, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)))
				
				v55:Play()
				v55.Completed:Wait()
				
				for _, v56 in pairs(v43:GetDescendants()) do
					if v56:IsA("Trail") or v56:IsA("ParticleEmitter") then
						v56.Enabled = false
					end
				end
			end)
			
			task.wait(p_u_38 / p_u_39)
		end
		
		task.wait(p_u_40 + 2)
		v_u_41:Dispose()
	end)
end

return v1
