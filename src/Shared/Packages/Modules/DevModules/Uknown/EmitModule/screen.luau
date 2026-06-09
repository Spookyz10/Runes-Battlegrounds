-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = require("./mod/utility")
return {
	["emit"] = function(p_u_3, p4)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		if p_u_3:GetAttribute("Enabled") then
			local v_u_5 = v_u_2.getAttribute(p_u_3, "PartScale", Vector3.new(1, 1, 1))
			local v_u_6 = v_u_2.getAttribute(p_u_3, "PartDistance", 1.5)
			local v_u_7 = v_u_2.getAttribute(p_u_3, "OffsetPosition", Vector3.new(0, 0, 0))
			local v_u_8 = v_u_2.getAttribute(p_u_3, "OffsetRotation", Vector3.new(0, 0, 0)) * v_u_2.DEG_TO_RAD
			local v_u_9 = p_u_3.CFrame
			local v_u_10 = p_u_3.Size
			local v_u_11 = p_u_3.CollisionGroup
			p_u_3.CollisionGroup = "ForgeMouseIgnore"
			table.insert(p4, function()
				-- upvalues: (copy) p_u_3, (copy) v_u_10, (copy) v_u_9, (copy) v_u_11
				p_u_3.Size = v_u_10
				p_u_3.CFrame = v_u_9
				p_u_3.CollisionGroup = v_u_11 == "" and "Default" or (v_u_11 or "Default")
			end)
			local v_u_12 = v_u_2.getRanomId()
			v_u_1:BindToRenderStep(v_u_12, v_u_2.RENDER_PRIORITY + p4.depth, function()
				-- upvalues: (copy) v_u_6, (copy) p_u_3, (copy) v_u_5, (copy) v_u_7, (copy) v_u_8
				local v13 = workspace.CurrentCamera
				local v14 = v13.FieldOfView / 2
				local v15 = math.rad(v14)
				local v16 = math.tan(v15) * v_u_6 * 2
				local v17 = v13.ViewportSize.X / v13.ViewportSize.Y * v16
				local v18 = v13.CFrame * CFrame.new(0, 0, -v_u_6)
				local v19 = p_u_3
				local v20 = p_u_3.Size.Z
				v19.Size = Vector3.new(v17, v16, v20) * v_u_5
				p_u_3.CFrame = v18 * CFrame.new(v_u_7) * CFrame.fromOrientation(v_u_8.x, v_u_8.y, v_u_8.z)
			end)
			local function v21()
				-- upvalues: (ref) v_u_1, (copy) v_u_12
				v_u_1:UnbindFromRenderStep(v_u_12)
			end
			table.insert(p4, v21)
		end
	end
}
