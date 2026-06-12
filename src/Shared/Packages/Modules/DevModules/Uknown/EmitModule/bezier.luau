
local v_u_1 = game:GetService("HttpService")
local v_u_2 = game:GetService("CollectionService")
local v_u_3 = require("./mod/tween")
local v_u_4 = require("./mod/shape")
local v_u_5 = require("./mod/utility")
local v_u_6 = require("./obj/Bezier")
require("./obj/ObjectCache")
local v_u_7 = require(script.Parent.obj.Promise)
local v_u_38 = {
	["Box"] = {
		["Volume"] = v_u_4.getPointWithinBox,
		["Surface"] = v_u_4.getPointOnBox
	},
	["Cylinder"] = {
		["Volume"] = function(p8, p9, p10, p11, p12)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinCylinder(p8, 0, p12, p9, p10, p11)
		end,
		["Surface"] = function(p13, p14, p15, p16, p17)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinCylinder(p13, 1, p17, p14, p15, p16)
		end
	},
	["Sphere"] = {
		["Volume"] = function(p18, p19, p20, p21, p22)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinSphere(p18, 0, p22, p19, p20, p21)
		end,
		["Surface"] = function(p23, p24, p25, p26, p27)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinSphere(p23, 1, p27, p24, p25, p26)
		end
	},
	["Disc"] = {
		["Volume"] = function(p28, p29, p30, p31, p32)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinDisc(p28, 0, p32, p29, p30, p31)
		end,
		["Surface"] = function(p33, p34, p35, p36, p37)
			-- upvalues: (copy) v_u_4
			return v_u_4.getPointWithinDisc(p33, 1, p37, p34, p35, p36)
		end
	}
}
local v39 = {}
local v_u_40 = nil
function v39.init(p41)
	-- upvalues: (ref) v_u_40
	v_u_40 = p41
end
function v39.deinit()
	-- upvalues: (ref) v_u_40
	v_u_40 = nil
end
function v39.emit(p_u_42, p_u_43, p_u_44, p45)
	-- upvalues: (ref) v_u_40, (copy) v_u_5, (copy) v_u_38, (copy) v_u_3, (copy) v_u_6, (copy) v_u_2, (copy) v_u_7, (copy) v_u_1
	local v46 = p_u_42:FindFirstChild("Points")
	if v46 and (v46:IsA("Attachment") and v_u_40) then
		local v47 = v_u_5.getAttribute(p_u_42, "EmitDelay", 0)
		local v48 = v_u_5.getAttribute(p_u_42, "EmitCount", 1)
		local v49 = v_u_5.getAttribute(p_u_42, "EmitDuration", 0)
		local v50 = v_u_5.getAttribute(p_u_42, "DestroyDelay", 0)
		local v51 = v_u_5.getRangeAttribute(p_u_42, "Duration", NumberRange.new(1, 1), NumberRange.new(0, (1 / 0)))
		local v_u_52 = v_u_5.getEnumAttribute(p_u_42, "ShapeFace", "Outward", { "InAndOut", "Inward", "Outward" })
		local v_u_53 = v_u_5.getAttribute(p_u_42, "SpreadAngle", Vector3.new(0, 0, 0))
		local v_u_54 = v_u_5.getAttribute(p_u_42, "SyncPosition", false)
		local v_u_55 = v_u_5.getAttribute(p_u_42, "MirrorPaths", true)
		local v_u_56 = v_u_5.getAttribute(p_u_42, "MirrorRotation", Vector3.new(0, 0, 180))
		local v_u_57 = v_u_5.getAttribute(p_u_42, "FacePath", false)
		local v_u_58 = v_u_5.getAttribute(p_u_42, "ArcSpace", false)
		local v_u_59 = v_u_5.getAttribute(p_u_42, "ShapePartial", 1)
		local v60 = v_u_5.getEnumAttribute(p_u_42, "Shape", "Box", {
			"Box",
			"Cylinder",
			"Sphere",
			"Disc"
		})
		local v61 = v_u_5.getEnumAttribute(p_u_42, "ShapeStyle", "Volume", { "Volume", "Surface" })
		local v_u_62 = Enum.NormalId[v_u_5.getEnumAttribute(p_u_42, "EmissionDirection", "Top", {
			"Top",
			"Bottom",
			"Left",
			"Right",
			"Front",
			"Back"
		})]
		local v_u_63 = v_u_5.getAttribute(p_u_42, "ProjectileEnabled", false)
		local v_u_64 = v_u_5.getAttribute(p_u_42, "MatchEndDirection", false)
		local v_u_65 = v_u_5.getAttribute(p_u_42, "ProjectileSpeed", 30)
		local v66 = v_u_5.getRangeAttribute(p_u_42, "ProjectileLifetime", NumberRange.new(1, 1), NumberRange.new(0, (1 / 0)))
		local v_u_67 = v_u_5.getAttribute(p_u_42, "HitboxEnabled", false)
		local v68 = v_u_5.getAttribute(p_u_42, "HitboxCollisionGroup", "Default")
		local v69 = v_u_5.getAttribute(p_u_42, "HitboxFilterTag", "")
		local v70 = v_u_5.getAttribute(p_u_42, "HitboxFilterType", "Exclude")
		local v71 = v_u_5.getAttribute(p_u_42, "HitboxIgnoreCanCollide", false)
		local v72 = v_u_5.getRangeAttribute(p_u_42, "RotSpeed_Start", NumberRange.new(0, 0))
		local v73 = v_u_5.getRangeAttribute(p_u_42, "RotSpeed_End", NumberRange.new(0, 0))
		local v74 = v_u_5.getAttribute(p_u_42, "MinInitRot", Vector3.new(0, 0, 0))
		local v75 = v_u_5.getAttribute(p_u_42, "MaxInitRot", Vector3.new(0, 0, 0))
		local v_u_76 = v_u_5.getAttribute(p_u_42, "Speed_Start", 1)
		local v_u_77 = v_u_5.getAttribute(p_u_42, "Speed_End", 1)
		local v_u_78 = v_u_38[v60]
		if v_u_78 then
			v_u_78 = v_u_38[v60][v61]
		end
		if v_u_78 then
			local v_u_79 = {}
			local v80 = v49 > 0
			task.wait(v47)
			if v80 and not p45 then
				p_u_42:SetAttribute("Enabled", true)
				if v_u_76 ~= v_u_77 then
					p_u_42:SetAttribute("SpeedTweening", true)
					local v81 = v_u_3.fromParams
					local v82 = v_u_5.getAttribute(p_u_42, "Speed_Curve", v_u_5.default_bezier)
					local v83 = v_u_5.getAttribute(p_u_42, "Speed_Duration", 0.1)
					local function v86(p84, p85)
						-- upvalues: (copy) p_u_42, (ref) v_u_5, (copy) v_u_76, (copy) v_u_77
						p_u_42:SetAttribute("SpeedOverride", v_u_5.lerp(v_u_76, v_u_77, p84))
						return p85
					end
					table.insert(p_u_44, v81(v82, v83, v86, nil, function()
						-- upvalues: (copy) p_u_42
						p_u_42:SetAttribute("SpeedTweening", nil)
					end))
				end
				task.wait(v49)
				p_u_42:SetAttribute("Enabled", false)
				p_u_42:SetAttribute("SpeedOverride", nil)
			elseif v48 > 0 then
				local v_u_87 = nil
				local v_u_88 = nil
				local v_u_89 = p_u_42.Parent
				if not v_u_89 then
					return
				end
				if not (v_u_89:IsA("BasePart") or v_u_89:IsA("Attachment")) then
					v_u_89 = p_u_42
				end
				if v_u_89:IsA("BasePart") then
					v_u_87 = v_u_89.Size
					v_u_88 = v_u_89.CFrame
				elseif v_u_89:IsA("Attachment") then
					v_u_88 = v_u_89.WorldCFrame
					v_u_87 = Vector3.new(0, 0, 0)
				end
				if not v_u_88 then
					return
				end
				local v_u_90 = p_u_42:FindFirstChild("End")
				v_u_90 = v_u_90
				local v_u_91
				if v_u_90 then
					v_u_91 = v_u_90:FindFirstChild("T1")
				end
				if v_u_90 and not v_u_90:IsA("Attachment") then
					v_u_90 = nil
				end
				if v_u_91 and not v_u_91:IsA("Attachment") then
					v_u_91 = nil
				end
				local v_u_92 = v_u_5.getBezierPoints(v46)
				local v_u_93 = Random.new()
				local v_u_94 = not v_u_90
				if v_u_94 then
					v_u_94 = v_u_6.new(v_u_92)
				end
				local v_u_95 = OverlapParams.new()
				v_u_95.MaxParts = 1
				v_u_95.FilterType = Enum.RaycastFilterType[v70]
				v_u_95.CollisionGroup = v68
				v_u_95.RespectCanCollide = not v71
				v_u_95:AddToFilter(v_u_2:GetTagged(v69))
				if v70 == "Exclude" then
					v_u_95:AddToFilter({ workspace.Terrain, v_u_89, v46:FindFirstAncestorOfClass("Part") })
				end
				for _ = 1, v48 do
					local v_u_96 = v_u_93:NextNumber(v72.Min, v72.Max)
					local v_u_97 = v_u_93:NextNumber(v73.Min, v73.Max)
					local v98 = v_u_93:NextNumber(v74.x, v75.x)
					local v99 = v_u_93:NextNumber(v74.y, v75.y)
					local v100 = v74.z
					local v101 = v75.z
					local v_u_102 = vector.create(v98, v99, v_u_93:NextNumber(v100, v101))
					local v_u_103 = v_u_93:NextNumber(v51.Min, v51.Max)
					local v_u_104
					if v_u_63 then
						v_u_104 = v_u_93:NextNumber(v66.Min, v66.Max)
					else
						v_u_104 = v_u_63
					end
					local v105 = v_u_7.new
					local function v189(p_u_106)
						-- upvalues: (ref) v_u_89, (ref) v_u_88, (copy) v_u_62, (copy) v_u_78, (ref) v_u_87, (copy) v_u_59, (copy) v_u_93, (copy) v_u_53, (copy) v_u_52, (ref) v_u_90, (copy) v_u_55, (copy) v_u_56, (ref) v_u_5, (copy) v_u_94, (copy) v_u_92, (ref) v_u_91, (ref) v_u_6, (copy) v_u_58, (ref) v_u_1, (ref) v_u_40, (copy) p_u_43, (copy) v_u_79, (copy) p_u_44, (copy) v_u_67, (copy) v_u_95, (copy) v_u_76, (copy) v_u_96, (copy) v_u_102, (copy) v_u_77, (copy) p_u_42, (ref) v_u_3, (copy) v_u_97, (copy) v_u_103, (copy) v_u_57, (copy) v_u_54, (copy) v_u_63, (copy) v_u_104, (copy) v_u_64, (copy) v_u_65
						local v107
						if v_u_89:IsA("Attachment") then
							v107 = v_u_88 * CFrame.new(Vector3.new(0, 0, 0), Vector3.FromNormalId(v_u_62)).Rotation
						else
							v107 = v_u_78(nil, v_u_88, v_u_87, v_u_62, v_u_59)
						end
						local v108 = Vector3.FromNormalId(v_u_62)
						local v109 = v108:Cross(v_u_88.LookVector)
						if v109.Magnitude < 0.001 then
							v109 = v108:Cross(v_u_88.UpVector)
						end
						local v110 = CFrame.fromAxisAngle
						local v111 = v_u_93:NextNumber(-v_u_53.x, v_u_53.x)
						local v112 = v110(v108, (math.rad(v111)))
						local v113 = CFrame.fromAxisAngle
						local v114 = v_u_93:NextNumber(-v_u_53.y, v_u_53.y)
						local v_u_115 = v107 * (v112 * v113(v109, (math.rad(v114))))
						if v_u_52 == "Inward" or v_u_52 == "InAndOut" and v_u_93:NextInteger(0, 1) == 1 then
							v_u_115 = v_u_115 * CFrame.fromOrientation(0, 3.141592653589793, 0)
						end
						if v_u_90 and (v_u_55 and (v_u_115.Position - v_u_90.WorldPosition).Unit:Dot(v_u_115.RightVector) >= 0) then
							local v116 = v_u_56 * v_u_5.DEG_TO_RAD
							v_u_115 = v_u_115 * CFrame.fromOrientation(v116.x, v116.y, v116.z)
						end
						local v_u_117 = v_u_94
						if v_u_90 then
							local v118 = {}
							for v119, v120 in v_u_92 do
								local v121
								if v119 == #v_u_92 - 1 then
									v121 = v_u_91 and v_u_91.WorldPosition or v_u_90.WorldPosition
								elseif v119 == #v_u_92 then
									v121 = v_u_90.WorldPosition
								else
									v121 = v_u_115 * (v120 - v_u_92[1])
								end
								table.insert(v118, v121)
							end
							v_u_117 = v_u_6.new(v118)
						end
						local v_u_122 = v_u_1:GenerateGUID(false)
						if v_u_40 then
							local v_u_123 = v_u_40:get(v_u_122)
							local v124 = CFrame.new
							local v125 = v_u_58 and v_u_117:getPositionArcSpace(0) or v_u_117:getPosition(0)
							if not v_u_90 then
								v125 = v_u_115 * (v125 - v_u_92[1])
							end
							v_u_123.CFrame = v124(v125)
							local v_u_126 = v_u_123._getReal()
							v_u_5.copyProperties(p_u_43, v_u_126, v_u_5.COPY_PART_PROPERTIES)
							v_u_5.copyProperties(p_u_43, v_u_126, v_u_5.COPY_EXTENDED_PART_PROPERTIES)
							local v127 = p_u_43:Clone()
							for _, v128 in v127:GetChildren() do
								v128.Parent = v_u_126
							end
							v127:Destroy()
							local v_u_129 = v_u_126:FindFirstChild("EmitOnFinish")
							if v_u_129 then
								v_u_129.Parent = nil
							end
							if shared.vfx and #v_u_126:GetChildren() ~= 0 then
								local v130 = v_u_79
								local v131 = shared.vfx.emit(v_u_126).Finished
								table.insert(v130, v131)
							end
							local v132 = p_u_44
							local function v133()
								-- upvalues: (ref) v_u_40, (copy) v_u_122
								if v_u_40 then
									v_u_40:free(v_u_122)
								end
							end
							table.insert(v132, v133)
							local v_u_134 = Vector3.new(0, 0, 0)
							local v_u_135 = Vector3.new(0, 0, 0)
							local v_u_136 = false
							local function v_u_139()
								-- upvalues: (ref) v_u_136, (copy) v_u_129, (copy) v_u_126, (copy) p_u_106
								if v_u_136 then
									return
								else
									v_u_136 = true
									local v137 = v_u_129
									if v137 then
										v137 = v_u_129:GetChildren()
									end
									if v137 and #v137 ~= 0 then
										for _, v138 in v137 do
											v138.Parent = v_u_126
										end
										shared.vfx.emit(table.unpack(v137)).Finished:finally(function()
											-- upvalues: (ref) p_u_106
											p_u_106()
										end)
									else
										p_u_106()
									end
								end
							end
							local v_u_140 = false
							local v_u_141 = CFrame.identity
							local v_u_142 = v_u_76
							local v_u_143 = v_u_96
							local v_u_144 = CFrame.fromOrientation(v_u_102.x, v_u_102.y, v_u_102.z)
							local v_u_145
							if v_u_76 == v_u_77 or p_u_42:GetAttribute("SpeedOverride") then
								v_u_145 = nil
							else
								v_u_145 = v_u_3.fromParams(v_u_5.getAttribute(p_u_42, "Speed_Curve", v_u_5.default_bezier), v_u_5.getAttribute(p_u_42, "Speed_Duration", 0.1), function(p146, p147)
									-- upvalues: (ref) v_u_142, (ref) v_u_5, (ref) v_u_76, (ref) v_u_77
									v_u_142 = v_u_5.lerp(v_u_76, v_u_77, p146)
									return p147
								end)
								local v148 = p_u_44
								table.insert(v148, v_u_145)
							end
							if v_u_96 ~= v_u_97 then
								local v149 = p_u_44
								local v150 = v_u_3.fromParams
								local v151 = v_u_5.getAttribute(p_u_42, "RotSpeed_Curve", v_u_5.default_bezier)
								local v152 = v_u_103
								local function v155(p153, p154)
									-- upvalues: (ref) v_u_143, (ref) v_u_5, (ref) v_u_96, (ref) v_u_97, (ref) p_u_42, (ref) v_u_142
									v_u_143 = v_u_5.lerp(v_u_96, v_u_97, p153)
									return p154 * (p_u_42:GetAttribute("SpeedOverride") or v_u_142)
								end
								table.insert(v149, v150(v151, v152, v155, v_u_145))
							end
							local v156 = p_u_44
							local v157 = v_u_3.fromParams
							local v158 = v_u_5.getAttribute(p_u_42, "Easing_Curve", v_u_5.linear_bezier)
							local v159 = v_u_103
							local function v175(p160, p161, p162)
								-- upvalues: (ref) v_u_58, (ref) v_u_117, (ref) v_u_90, (ref) v_u_115, (ref) v_u_92, (ref) v_u_57, (ref) v_u_103, (ref) v_u_141, (ref) v_u_102, (ref) v_u_143, (ref) v_u_5, (ref) v_u_144, (ref) v_u_54, (copy) v_u_123, (ref) v_u_88, (ref) v_u_89, (ref) v_u_135, (ref) v_u_134, (ref) v_u_67, (copy) v_u_126, (ref) v_u_95, (copy) v_u_139, (ref) v_u_140, (ref) p_u_42, (ref) v_u_142, (ref) v_u_145, (ref) v_u_63, (ref) v_u_104
								local v163 = v_u_58 and v_u_117:getPositionArcSpace(p160) or v_u_117:getPosition(p160)
								if not v_u_90 then
									v163 = v_u_115 * (v163 - v_u_92[1])
								end
								local v164 = CFrame.new(v163)
								if v_u_57 then
									local v165 = (p162 + 0.016666666666666666) / v_u_103
									local v166 = math.clamp(v165, 0, 1)
									local v167 = v_u_58 and v_u_117:getPositionArcSpace(v166) or v_u_117:getPosition(v166)
									if not v_u_90 then
										v167 = v_u_115 * (v167 - v_u_92[1])
									end
									if v163 == v167 then
										v164 = v164 * v_u_141.Rotation
									else
										v164 = CFrame.lookAt(v163, v167)
									end
								end
								local v168 = v_u_102:Sign() * v_u_143 * v_u_5.DEG_TO_RAD * p161
								v_u_144 = v_u_144 * CFrame.fromOrientation(v168.x, v168.y, v168.z)
								v_u_141 = v164
								local v169 = v164 * v_u_144
								if v_u_54 then
									local v170 = v_u_123
									local v171 = v_u_88
									if v_u_89:IsA("BasePart") then
										v171 = v_u_89.CFrame
									elseif v_u_89:IsA("Attachment") then
										v171 = v_u_89.WorldCFrame
									end
									v170.CFrame = v171 * v_u_88:ToObjectSpace(v169)
								else
									v_u_123.CFrame = v169
								end
								v_u_135 = (v163 - v_u_134) / p161
								v_u_134 = v163
								local v172
								if v_u_67 then
									v172 = workspace:GetPartsInPart(v_u_126, v_u_95)[1] and true or false
								else
									v172 = nil
								end
								if v172 then
									v_u_139()
									v_u_140 = true
									return nil
								end
								local v173 = p_u_42:GetAttribute("SpeedOverride") or v_u_142
								v_u_142 = v173
								if v173 == 0 then
									local v174
									if v_u_145 then
										v174 = not v_u_145.Connected
									else
										v174 = not p_u_42:GetAttribute("SpeedTweening")
									end
									if v174 then
										return nil
									end
								end
								if v_u_63 and p160 * v_u_103 < v_u_104 or not v_u_63 then
									return p161 * v173
								end
								v_u_139()
								return nil
							end
							local function v187(p176)
								-- upvalues: (ref) v_u_63, (ref) v_u_140, (copy) v_u_139, (ref) v_u_64, (ref) v_u_90, (ref) v_u_135, (ref) v_u_65, (copy) v_u_126, (ref) v_u_88, (ref) v_u_89, (ref) v_u_3, (ref) v_u_104, (ref) v_u_54, (copy) v_u_123, (ref) v_u_67, (ref) v_u_95, (ref) p_u_42, (ref) v_u_142, (ref) v_u_145, (ref) p_u_44, (ref) v_u_5
								if v_u_63 and not v_u_140 then
									local v177
									if v_u_64 and v_u_90 then
										v177 = v_u_90.WorldCFrame.LookVector
									else
										v177 = v_u_135.Unit
									end
									v_u_135 = (v177 ~= v177 and Vector3.new(0, 0, 0) or v177) * v_u_65
									local v_u_178 = v_u_126.Position
									local v_u_179 = v_u_88
									if v_u_89:IsA("BasePart") then
										v_u_179 = v_u_89.CFrame
									elseif v_u_89:IsA("Attachment") then
										v_u_179 = v_u_89.WorldCFrame
									end
									v_u_3.timer(v_u_104, function(p180, p181)
										-- upvalues: (ref) v_u_54, (ref) v_u_123, (ref) v_u_88, (ref) v_u_89, (copy) v_u_179, (copy) v_u_178, (ref) v_u_135, (ref) v_u_126, (ref) v_u_67, (ref) v_u_95, (ref) v_u_139, (ref) v_u_140, (ref) p_u_42, (ref) v_u_142, (ref) v_u_145
										if v_u_54 then
											local v182 = v_u_123
											local v183 = v_u_88
											if v_u_89:IsA("BasePart") then
												v183 = v_u_89.CFrame
											elseif v_u_89:IsA("Attachment") then
												v183 = v_u_89.WorldCFrame
											end
											v182.CFrame = v183 * v_u_179:ToObjectSpace(CFrame.new(v_u_178 + v_u_135 * p181))
										else
											v_u_123.CFrame = CFrame.new(v_u_178 + v_u_135 * p181) * v_u_126.CFrame.Rotation
										end
										local v184
										if v_u_67 then
											v184 = workspace:GetPartsInPart(v_u_126, v_u_95)[1] and true or false
										else
											v184 = nil
										end
										if v184 then
											v_u_139()
											v_u_140 = true
											return nil
										end
										local v185 = p_u_42:GetAttribute("SpeedOverride") or v_u_142
										v_u_142 = v185
										
										if v185 > 0 then
											return p180 * v185
										else
											if p181 > 0 then
												local v186
												if v_u_145 then
													v186 = v_u_145.Connected
												else
													v186 = p_u_42:GetAttribute("SpeedTweening")
												end
												
												if v186 then
													
												end
											end
											return nil
										end
									end, v_u_145, p_u_44, v_u_5.RENDER_PRIORITY + p_u_44.depth)
									if not v_u_140 then
										v_u_139()
									end
								elseif p176 then
									v_u_139()
								end
							end
							local v188 = v_u_5.RENDER_PRIORITY + p_u_44.depth
							table.insert(v156, v157(v158, v159, v175, v_u_145, v187, true, v188))
						else
							p_u_106()
						end
					end
					table.insert(v_u_79, v105(v189))
				end
				v_u_7.all(v_u_79):await()
				task.wait(v50)
			end
		else
			return
		end
	else
		return
	end
end
return v39
