-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v1 = {}
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = game:GetService("TweenService")
local v_u_4 = v2.Packages.ImpactAssets
function v1.ImpactV1(p_u_5)
	-- upvalues: (copy) v_u_4, (copy) v_u_3
	task.spawn(function()
		-- upvalues: (ref) v_u_4, (copy) p_u_5, (ref) v_u_3
		local v6 = v_u_4:WaitForChild("ColorCorrection"):Clone()
		v6.Parent = workspace.CurrentCamera
		v6.Brightness = 1
		v6.Contrast = -10
		v6.Saturation = -1
		task.wait(p_u_5)
		v6.Brightness = 0
		v6.Contrast = 0
		v6.Saturation = 0
		task.wait(p_u_5)
		v6.Brightness = -1
		v6.Contrast = -10
		v6.Saturation = -1
		v_u_3:Create(v6, TweenInfo.new(p_u_5), {
			["Brightness"] = 0,
			["Contrast"] = 0,
			["Saturation"] = 0
		}):Play()
		task.wait(p_u_5)
		v6:Destroy()
	end)
end
function v1.ImpactV2(p7)
	-- upvalues: (copy) v_u_4, (copy) v_u_3
	local v8 = v_u_4.ColorCorrection2:Clone()
	v8.Parent = workspace.CurrentCamera
	v_u_3:Create(v8, TweenInfo.new(p7), {
		["Brightness"] = 0,
		["Contrast"] = 0,
		["Saturation"] = 0
	}):Play()
end
return v1
