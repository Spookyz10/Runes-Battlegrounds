-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = game:GetService("CollectionService")
local v_u_3 = require("./mod/tween")
local v_u_4 = require("./mod/utility")
local v_u_5 = require("./mod/color/Oklab")
local v_u_6 = require("./obj/Promise")
local v_u_7 = Random.new()
return {
	["emit"] = function(p_u_8, p_u_9, p10, p11, p12)
		-- upvalues: (copy) v_u_4, (copy) v_u_7, (copy) v_u_3, (copy) v_u_1, (copy) v_u_5, (copy) v_u_2, (copy) v_u_6
		local v13 = p_u_8:FindFirstChild("Start")
		local v14 = p_u_8:FindFirstChild("End")
		if not v13 or (not v14 or (not v13:IsA("BasePart") or (not v14:IsA("BasePart") or p_u_8:GetAttribute("Enabled") and not p12))) then
			return
		end
		local v15 = v_u_4.getAttribute(p_u_8, "Duration", 1, true)
		local v16 = v_u_4.getRangeAttribute(p_u_8, "EffectDuration", NumberRange.new(v15, v15), NumberRange.new(0, (1 / 0)))
		local v17 = v_u_7:NextNumber(v16.Min, v16.Max)
		local v18 = v_u_4.getAttribute(p_u_8, "EmitDelay", 0)
		local v19 = v_u_4.getAttribute(p_u_8, "EmitDuration", 0, true)
		local v20 = v_u_4.getAttribute(p_u_8, "Flipbook", false, true)
		local v_u_21 = v_u_4.getAttribute(p_u_8, "FlipbookFadeOffset", 0, true)
		local v22 = (v20 or not v13:FindFirstChildOfClass("Decal")) and "Mesh_" or "Decal_"
		local v23 = p_u_8:GetAttribute("StartTransparency")
		if v23 ~= nil then
			p_u_8:SetAttribute(v22 .. "StartTransparency", v23)
			p_u_8:SetAttribute("StartTransparency", nil)
		end
		local v24 = p_u_8:GetAttribute("EndTransparency")
		if v24 ~= nil then
			p_u_8:SetAttribute(v22 .. "EndTransparency", v24)
			p_u_8:SetAttribute("EndTransparency", nil)
		end
		local v25 = p_u_8:GetAttribute("Enabled") ~= nil and p_u_8:HasTag(v_u_4.ENABLED_VFX_TAG)
		if v25 then
			v25 = v17 > 0
		end
		local v_u_26 = v_u_4.getAttribute(p_u_8, "Decal_StartTransparency", 0, true)
		local v_u_27 = v_u_4.getAttribute(p_u_8, "Decal_EndTransparency", 1, true)
		local v28 = 0
		local v29
		if v13 then
			v29 = v13:FindFirstChildOfClass("Decal")
		else
			v29 = v13
		end
		local v30 = v29 and 1 or v28
		local v31 = v_u_4.getAttribute(p_u_8, "Mesh_StartTransparency", v30, true)
		local v32 = v_u_4.getAttribute(p_u_8, "Mesh_EndTransparency", v30, true)
		local v_u_33 = v_u_4.getAttribute(p_u_8, "SyncPosition", false)
		local v_u_34 = v_u_4.getAttribute(p_u_8, "Speed_Start", 1)
		local v_u_35 = v_u_4.getAttribute(p_u_8, "Speed_End", 1)
		local v_u_36 = v_u_4.getAttribute(p_u_8, "Part_Transparency_Start", v31)
		local v_u_37 = v_u_4.getAttribute(p_u_8, "Part_Transparency_End", v32)
		local v38 = v_u_4.getAttribute(p_u_8, "SpreadAngle", Vector3.new(0, 0, 0))
		local v39 = v_u_4.getRangeAttribute(p_u_8, "Part_RotSpeed_Start", NumberRange.new(0, 0))
		local v40 = v_u_4.getRangeAttribute(p_u_8, "Part_RotSpeed_End", NumberRange.new(0, 0))
		local v_u_41 = v_u_4.getAttribute(p_u_8, "RotAroundOrigin", false)
		local v42 = v_u_4.getAttribute(p_u_8, "MinInitRot", Vector3.new(0, 0, 0))
		local v43 = v_u_4.getAttribute(p_u_8, "MaxInitRot", Vector3.new(0, 0, 0))
		local v_u_44 = v_u_7:NextNumber(v39.Min, v39.Max)
		local v_u_45 = v_u_7:NextNumber(v40.Min, v40.Max)
		local v46 = v_u_7:NextNumber(v42.x, v43.x)
		local v47 = v_u_7:NextNumber(v42.y, v43.y)
		local v48 = v_u_7
		local v49 = v42.z
		local v50 = v43.z
		local v_u_51 = vector.create(v46, v47, v48:NextNumber(v49, v50)) * v_u_4.DEG_TO_RAD
		task.wait(v18)
		if v25 and not p12 then
			p_u_8:SetAttribute("Enabled", true)
			if v_u_34 ~= v_u_35 then
				p_u_8:SetAttribute("SpeedTweening", true)
				local v52 = v_u_3.fromParams
				local v53 = v_u_4.getAttribute(p_u_8, "Speed_Curve", v_u_4.default_bezier)
				local v54 = v_u_4.getAttribute(p_u_8, "Speed_Duration", 0.1)
				local function v57(p55, p56)
					-- upvalues: (copy) p_u_8, (ref) v_u_4, (copy) v_u_34, (copy) v_u_35
					p_u_8:SetAttribute("SpeedOverride", v_u_4.lerp(v_u_34, v_u_35, p55))
					return p56
				end
				table.insert(p10, v52(v53, v54, v57, nil, function()
					-- upvalues: (copy) p_u_8
					p_u_8:SetAttribute("SpeedTweening", nil)
				end))
			end
			task.wait(v19)
			p_u_8:SetAttribute("Enabled", false)
			p_u_8:SetAttribute("SpeedOverride", nil)
			return
		end
		local v_u_58 = p_u_8:FindFirstAncestorOfClass("Attachment") or v13
		local v_u_59
		if typeof(p_u_9) == "table" then
			v_u_59 = p_u_9._getReal() or p_u_9
		else
			v_u_59 = p_u_9
		end
		local v_u_60 = v_u_58:IsA("Attachment") and v_u_58.WorldCFrame or v_u_58.CFrame
		local v_u_61 = v13.CFrame:ToObjectSpace(v14.CFrame)
		local v_u_62 = v_u_34
		local v_u_63 = v_u_44
		local v_u_64 = CFrame.fromOrientation(v_u_51.x, v_u_51.y, v_u_51.z)
		local v_u_65 = CFrame.identity
		local v66 = CFrame.fromOrientation
		local v67 = v_u_7:NextNumber(-v38.x, v38.x)
		local v68 = math.rad(v67)
		local v69 = v_u_7:NextNumber(-v38.y, v38.y)
		local v_u_70 = v66(v68, math.rad(v69), 0)
		local function v75(p71)
			-- upvalues: (copy) v_u_33, (copy) v_u_58, (copy) v_u_60, (copy) v_u_51, (ref) v_u_63, (ref) v_u_64, (copy) v_u_41, (copy) v_u_70, (ref) v_u_65, (copy) p_u_9
			local v72 = v_u_33 and (v_u_58:IsA("Attachment") and v_u_58.WorldCFrame or v_u_58.CFrame) or v_u_60
			local v73 = v_u_51:Sign() * v_u_63 * p71
			v_u_64 = v_u_64 * CFrame.fromOrientation(v73.x, v73.y, v73.z)
			local v74
			if v_u_41 then
				v74 = v72 * v_u_70 * v_u_64 * v_u_65
			else
				v74 = v72 * v_u_70 * v_u_65 * v_u_64
			end
			p_u_9.CFrame = v74 * v_u_64
		end
		v75(0)
		local v_u_76 = v_u_4.getRanomId()
		v_u_1:BindToRenderStep(v_u_76, v_u_4.RENDER_PRIORITY + p10.depth, v75)
		local function v77()
			-- upvalues: (ref) v_u_1, (copy) v_u_76
			v_u_1:UnbindFromRenderStep(v_u_76)
		end
		table.insert(p10, v77)
		local v78 = {}
		local v79 = p_u_9:FindFirstChild("EmitOnFinish")
		if v79 then
			v79.Parent = nil
		end
		if shared.vfx and #p_u_9:GetChildren() ~= 0 then
			local v80 = shared.vfx.emit(p_u_9).Finished
			table.insert(v78, v80)
		end
		local v_u_81
		if v_u_34 == v_u_35 or p_u_8:GetAttribute("SpeedOverride") then
			v_u_81 = nil
		else
			v_u_81 = v_u_3.fromParams(v_u_4.getAttribute(p_u_8, "Speed_Curve", v_u_4.default_bezier), v_u_4.getAttribute(p_u_8, "Speed_Duration", 0.1), function(p82, p83)
				-- upvalues: (ref) v_u_62, (ref) v_u_4, (copy) v_u_34, (copy) v_u_35
				v_u_62 = v_u_4.lerp(v_u_34, v_u_35, p82)
				return p83
			end)
			table.insert(p10, v_u_81)
		end
		if v_u_61 ~= CFrame.identity then
			local v84 = v_u_3.fromParams
			local v85 = v_u_4.getAttribute(p_u_8, "Part_CFrame_Curve", v_u_4.default_bezier)
			table.insert(p10, v84(v85, v17, function(p86, p87)
				-- upvalues: (ref) v_u_65, (copy) v_u_61, (copy) p_u_8, (ref) v_u_62
				v_u_65 = CFrame.identity:Lerp(v_u_61, p86)
				return p87 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
			end, v_u_81))
		end
		if v_u_44 ~= v_u_45 then
			local v88 = v_u_3.fromParams
			local v89 = v_u_4.getAttribute(p_u_8, "Part_RotSpeed_Curve", v_u_4.default_bezier)
			local function v92(p90, p91)
				-- upvalues: (ref) v_u_63, (ref) v_u_4, (copy) v_u_44, (copy) v_u_45, (copy) p_u_8, (ref) v_u_62
				v_u_63 = v_u_4.lerp(v_u_44, v_u_45, p90)
				return p91 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
			end
			table.insert(p10, v88(v89, v17, v92, v_u_81))
		end
		if v_u_36 == v_u_37 then
			p_u_9.Transparency = v_u_36
		else
			local v93 = v_u_3.fromParams
			local v94 = v_u_4.getAttribute(p_u_8, "Part_Transparency_Curve", v_u_4.default_bezier)
			local function v97(p95, p96)
				-- upvalues: (copy) p_u_9, (ref) v_u_4, (copy) v_u_36, (copy) v_u_37, (copy) p_u_8, (ref) v_u_62
				p_u_9.Transparency = v_u_4.lerp(v_u_36, v_u_37, p95)
				return p96 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
			end
			table.insert(p10, v93(v94, v17, v97, v_u_81))
		end
		local v_u_98 = v13.Size * p11
		local v_u_99 = v14.Size * p11
		if v_u_98 == v_u_99 then
			p_u_9.Size = v_u_98
		else
			local v100 = v_u_3.fromParams
			local v101 = v_u_4.getAttribute(p_u_8, "Part_Size_Curve", v_u_4.default_bezier)
			table.insert(p10, v100(v101, v17, function(p102, p103)
				-- upvalues: (copy) p_u_9, (copy) v_u_98, (copy) v_u_99, (copy) p_u_8, (ref) v_u_62
				p_u_9.Size = v_u_98:Lerp(v_u_99, p102)
				return p103 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
			end, v_u_81))
		end
		local v104 = v13:FindFirstChildOfClass("SpecialMesh")
		local v105 = v14:FindFirstChildOfClass("SpecialMesh")
		local v_u_106 = p_u_9:FindFirstChildOfClass("SpecialMesh")
		if v_u_106 then
			if v104 and v105 then
				local v_u_107 = v104.Scale * p11
				local v_u_108 = v105.Scale * p11
				if v_u_107 ~= v_u_108 then
					local v109 = v_u_3.fromParams
					local v110 = v_u_4.getAttribute(p_u_8, "Mesh_Scale_Curve", v_u_4.default_bezier)
					local function v113(p111, p112)
						-- upvalues: (copy) v_u_106, (ref) v_u_4, (copy) v_u_107, (copy) v_u_108, (copy) p_u_8, (ref) v_u_62
						v_u_106.Scale = v_u_4.lerp(v_u_107, v_u_108, p111)
						return p112 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
					end
					table.insert(p10, v109(v110, v17, v113, v_u_81))
				end
			else
				v_u_106.Parent = nil
				table.insert(p10, function()
					-- upvalues: (copy) v_u_106, (copy) v_u_59
					v_u_106.Parent = v_u_59
				end)
			end
		end
		local v_u_114, v115, v116 = v_u_4.getMeshDecals(p_u_8, p_u_9)
		local v117 = 0
		if v20 then
			table.sort(v_u_114, function(p118, p119)
				local v120 = p118.Name:match("%d+") or 0
				local v121 = p119.Name:match("%d+") or 0
				return tonumber(v120) < tonumber(v121)
			end)
			local v_u_122 = Instance.new("Decal")
			v_u_122.Parent = v_u_59
			table.insert(p10, v_u_122)
			if v_u_21 > 0 and v_u_26 ~= v_u_27 then
				local v123 = v_u_3.fromParams
				local v124 = v_u_4.default_bezier
				local v125 = v17 + v_u_21
				local function v128(p126, p127)
					-- upvalues: (copy) v_u_122, (ref) v_u_4, (copy) v_u_26, (copy) v_u_27, (copy) p_u_8, (ref) v_u_62
					v_u_122.Transparency = v_u_4.lerp(v_u_26, v_u_27, p126)
					return p127 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
				end
				table.insert(p10, v123(v124, v125, v128, v_u_81))
			end
			local v129 = v_u_3.fromParams
			local v130 = v_u_4.default_bezier
			local function v136(p131, p132)
				-- upvalues: (copy) v_u_114, (copy) v_u_122, (copy) v_u_21, (ref) v_u_4, (copy) v_u_26, (copy) v_u_27, (copy) p_u_8, (ref) v_u_62
				local v133 = #v_u_114 * p131
				local v134 = math.round(v133)
				local v135 = v_u_114[math.max(v134, 1)]
				v_u_122.Texture = v135.Texture
				v_u_122.Color3 = v135.Color3
				v_u_122.ZIndex = v135.ZIndex
				if v_u_21 == 0 then
					v_u_122.Transparency = v_u_4.lerp(v_u_26, v_u_27, p131)
					v_u_122.ZIndex = v135.ZIndex
				end
				return p132 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
			end
			table.insert(p10, v129(v130, v17, v136, v_u_81))
		else
			for _, v_u_137 in v_u_114 do
				local v_u_138 = v116[v_u_137]
				local v_u_139 = v_u_4.getAttribute(v_u_137, "Transparency_Start", v_u_26)
				local v_u_140 = v_u_4.getAttribute(v_u_137, "Transparency_End", v_u_27)
				if v_u_139 == v_u_140 then
					v_u_137.Transparency = v_u_139
				else
					local v141 = v_u_3.fromParams
					local v142 = v_u_4.getAttribute(v_u_137, "Transparency_Curve", v_u_4.default_bezier)
					local function v145(p143, p144)
						-- upvalues: (copy) v_u_137, (ref) v_u_4, (copy) v_u_139, (copy) v_u_140, (copy) p_u_8, (ref) v_u_62
						v_u_137.Transparency = v_u_4.lerp(v_u_139, v_u_140, p143)
						return p144 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
					end
					table.insert(p10, v141(v142, v17, v145, v_u_81))
				end
				if v_u_137.Color3 ~= v_u_138.Color3 then
					local v146 = v_u_3.fromParams
					local v147 = v_u_4.getAttribute(v_u_137, "Color_Curve", v_u_4.default_bezier)
					local function v152(p148, p149)
						-- upvalues: (ref) v_u_5, (copy) v_u_137, (copy) v_u_138, (copy) v_u_137, (copy) p_u_8, (ref) v_u_62
						local v150 = v_u_5.fromSRGB(v_u_137.Color3)
						local v151 = v_u_5.fromSRGB(v_u_138.Color3)
						v_u_137.Color3 = v_u_5.toSRGB(v150:Lerp(v151, p148), true)
						return p149 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
					end
					table.insert(p10, v146(v147, v17, v152, v_u_81))
				end
				local v_u_153 = v115[v_u_137]
				if v_u_153 then
					local v154 = v_u_4.getAttribute(v_u_137, "Flipbook_Change_Duration", v17)
					if v_u_4.getAttribute(v_u_137, "SyncDuration", false) then
						v154 = v17
					end
					if v117 < v154 then
						v117 = v154
					end
					local v_u_155 = false
					if v_u_1:IsStudio() then
						for _, v156 in v_u_2:GetTags(v_u_137) do
							if v156:match("^_local_flipbook_") then
								v_u_155 = true
								break
							end
						end
					end
					local v157 = v_u_3.fromParams
					local v158 = v_u_4.getAttribute(v_u_137, "Flipbook_Change_Curve", v_u_4.linear_bezier)
					local function v163(p159, p160)
						-- upvalues: (copy) v_u_153, (copy) v_u_137, (ref) v_u_155, (copy) p_u_8, (ref) v_u_62
						local v161 = #v_u_153 * p159
						local v162 = math.round(v161)
						v_u_137.Texture = ("%*%*"):format(v_u_155 and "rbxtemp://" or "rbxassetid://", v_u_153[math.max(v162, 1)])
						return p160 * (p_u_8:GetAttribute("SpeedOverride") or v_u_62)
					end
					table.insert(p10, v157(v158, v154, v163, v_u_81))
				end
			end
		end
		v_u_3.timer(math.max(v17, v117) + v_u_21, function(p164, p165)
			-- upvalues: (copy) p_u_8, (ref) v_u_62, (ref) v_u_81
			local v166 = p_u_8:GetAttribute("SpeedOverride") or v_u_62
			v_u_62 = v166
			if v166 > 0 then
				return p164 * v166
			else
				if p165 > 0 then
					local v167
					if v_u_81 then
						v167 = v_u_81.Connected
					else
						v167 = p_u_8:GetAttribute("SpeedTweening")
					end
					if v167 then
						
					end
				end
				return nil
			end
		end, v_u_81, p10)
		v_u_6.all(v78):await()
		if v79 then
			v79 = v79:GetChildren()
		end
		if v79 and #v79 ~= 0 then
			for _, v168 in v79 do
				v168.Parent = v_u_59
			end
			shared.vfx.emit(table.unpack(v79)).Finished:await()
		end
	end
}
