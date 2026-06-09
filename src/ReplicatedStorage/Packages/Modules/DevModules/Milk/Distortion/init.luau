local v1 = {}
local v_u_2 = game:GetService("Debris")
local v_u_3 = game:GetService("TweenService")
local v_u_4 = workspace.Thrown
local v_u_5 = script.DistortionMesh


function v1.Play(p6)
	local v7 = v_u_5:Clone()
	v7.CFrame = p6.Position
	v7.Parent = v_u_4
	v7.Transparency = p6.StartDistortion
	
	local v8 = p6.StartRadius
	local v9 = p6.StartRadius
	local v10 = p6.StartRadius
	
	v7.Size = Vector3.new(v8, v9, v10)
	
	local v11 = v_u_3
	local v12 = TweenInfo.new(p6.Duration, p6.EasingStyle, p6.EasingDirection)
	local v13 = {}
	local v14 = p6.EndRadius
	local v15 = p6.EndRadius
	local v16 = p6.EndRadius
	v13.Size = Vector3.new(v14, v15, v16)
	v13.Transparency = p6.EndDistortion
	v11:Create(v7, v12, v13):Play()
	v_u_2:AddItem(v7, p6.Duration)
end


return v1
