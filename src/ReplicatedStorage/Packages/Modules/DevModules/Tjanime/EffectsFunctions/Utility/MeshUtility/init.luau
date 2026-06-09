-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = require(script.Presets)
require(v2.Packages.Modules.DevModules.Tjanime.EffectsFunctions.Tweening)
function v_u_1.new(p4)
	-- upvalues: (copy) v_u_1
	local v5 = v_u_1
	local v6 = setmetatable({}, v5)
	v6.Object = p4.Object
	return v6
end
function v_u_1.PlayPreset(_, p7, ...)
	-- upvalues: (copy) v_u_3
	v_u_3[p7](...)
end
function v_u_1.PlayFlipbook(p8, p9)
	local v_u_10 = 1 / p9
	for _, v_u_11 in pairs(p8.Object:GetDescendants()) do
		if v_u_11.Name == "Flip" and v_u_11:IsA("Folder") then
			local v_u_12 = v_u_11.Parent
			task.spawn(function()
				-- upvalues: (copy) v_u_11, (copy) v_u_12, (copy) v_u_10
				for v13 = 1, #v_u_11:GetChildren() - 1 do
					v_u_12.Mesh.TextureId = v_u_11:FindFirstChild(v13).Texture
					task.wait(v_u_10)
				end
				v_u_12:Destroy()
			end)
		end
	end
end
return v_u_1
