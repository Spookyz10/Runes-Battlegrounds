-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("CollectionService")
local v_u_2 = require("./mod/tween")
local v_u_3 = require("./mod/logger")
local v_u_4 = require("./mod/utility")
local v_u_5 = require("./obj/Bezier")
require("./obj/ObjectCache")
local v_u_6 = require(script.Parent.obj.Promise)
local v_u_7 = Random.new()
local v8 = {}
local v_u_9 = nil
function v8.init(p10)
	-- upvalues: (ref) v_u_9
	v_u_9 = p10
end
function v8.deinit()
	-- upvalues: (ref) v_u_9
	v_u_9 = nil
end
function v8.emit(p_u_11, p_u_12, p_u_13)
	-- upvalues: (ref) v_u_9, (copy) v_u_4, (copy) v_u_1, (copy) v_u_2, (copy) v_u_3, (copy) v_u_5, (copy) v_u_7, (copy) v_u_6
	if v_u_9 then
		local v_u_14 = v_u_4.getAttribute(p_u_11, "RayDirection", Vector3.new(0, -50, 0))
		local v15 = v_u_4.getAttribute(p_u_11, "RayCollisionGroup", "Default")
		local v16 = v_u_4.getAttribute(p_u_11, "FilterTag", "")
		local v17 = v_u_4.getAttribute(p_u_11, "FilterType", "Exclude")
		local v18 = v_u_4.getAttribute(p_u_11, "IgnoreWater", true)
		local v19 = v_u_4.getAttribute(p_u_11, "IgnoreCanCollide", false)
		local v_u_20 = RaycastParams.new()
		v_u_20.CollisionGroup = v15
		v_u_20.IgnoreWater = v18
		v_u_20.RespectCanCollide = not v19
		v_u_20.FilterType = Enum.RaycastFilterType[v17]
		v_u_20.FilterDescendantsInstances = v_u_1:GetTagged(v16)
		if v17 == "Exclude" then
			v_u_20:AddToFilter({ workspace.Terrain })
		end
		local v21 = v_u_4.getAttribute(p_u_12, "EmitDelay", 0)
		local v_u_22 = v_u_4.getAttribute(p_u_12, "Rate_Start", 30)
		local v_u_23 = v_u_4.getAttribute(p_u_12, "Rate_End", 30)
		local v24 = v_u_4.getAttribute(p_u_12, "FixedAmount", 0)
		local v_u_25 = v_u_4.getAttribute(p_u_12, "Scale_Start", 1)
		local v_u_26 = v_u_4.getAttribute(p_u_12, "Scale_End", 1)
		local v27 = v_u_4.getAttribute(p_u_12, "Duration", 1)
		local v28 = v_u_4.getAttribute(p_u_12, "Direction", Vector3.new(0, 0, -1))
		local v_u_29 = v_u_4.getAttribute(p_u_12, "Length", 50)
		local v_u_30 = v_u_4.getRangeAttribute(p_u_12, "Rotation", NumberRange.new(-180, 180))
		local v31 = v_u_4.getAttribute(p_u_12, "PartOffset", Vector3.new(0, 0, 0), true)
		local v_u_32 = v_u_4.getAttribute(p_u_12, "BaseOffset", v31)
		local v_u_33 = v_u_4.getAttribute(p_u_12, "Offset_Start", v31)
		local v_u_34 = v_u_4.getAttribute(p_u_12, "Offset_End", v31)
		local v_u_35 = v_u_4.getAttribute(p_u_12, "Offset_Start_Duration", 0.5)
		local v_u_36 = v_u_4.getAttribute(p_u_12, "Offset_End_Duration", 0.5)
		local v_u_37 = v_u_4.getRangeAttribute(p_u_12, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, (1 / 0)))
		local v_u_38 = v_u_4.getAttribute(p_u_12, "SizeScaleStart", Vector3.new(0, 0, 0))
		local v_u_39 = v_u_4.getAttribute(p_u_12, "SizeScaleEnd", Vector3.new(0, 0, 0))
		local v_u_40 = v_u_4.getAttribute(p_u_12, "MinSize", Vector3.new(2, 1, 2))
		local v_u_41 = v_u_4.getAttribute(p_u_12, "MaxSize", Vector3.new(3, 2, 3))
		local v42 = v_u_4.getAttribute(p_u_12, "Size_Curve", v_u_4.default_bezier, true)
		local v43 = v_u_4.getAttribute(p_u_12, "Size_Duration", 0.5, true)
		local v_u_44 = v_u_4.getAttribute(p_u_12, "Size_Start_Curve", v42)
		local v_u_45 = v_u_4.getAttribute(p_u_12, "Size_End_Curve", v42)
		local v_u_46 = v_u_4.getAttribute(p_u_12, "Size_Start_Duration", v43)
		local v_u_47 = v_u_4.getAttribute(p_u_12, "Size_End_Duration", v43)
		local v_u_48 = v_u_4.getAttribute(p_u_12, "Transparency_Duration", 0.5)
		local v_u_49 = v_u_4.getAttribute(p_u_12, "Transparency_Start", 0)
		local v_u_50 = v_u_4.getAttribute(p_u_12, "Transparency_End", 0)
		local v_u_51 = v_u_4.getAttribute(p_u_12, "SyncPosition", false)
		local v_u_52 = math.max(v27, 0.001)
		if v24 > 0 then
			v_u_22 = v24 / v_u_52
			v_u_23 = v_u_22
		end
		local v53 = v28.Unit
		local v_u_54 = v53 ~= v53 and Vector3.new(-0, -0, -1) or v53
		task.wait(v21)
		local v_u_55 = {}
		local v_u_56 = p_u_11.WorldCFrame
		local v_u_57 = 0
		local v_u_58 = 0
		local v_u_59 = v_u_25
		if v_u_25 ~= v_u_26 then
			local v60 = v_u_2.fromParams
			local v61 = v_u_4.getAttribute(p_u_12, "Scale_Curve", v_u_4.default_bezier)
			local function v64(p62, p63)
				-- upvalues: (ref) v_u_59, (ref) v_u_4, (copy) v_u_25, (copy) v_u_26
				v_u_59 = v_u_4.lerp(v_u_25, v_u_26, p62)
				return p63
			end
			table.insert(p_u_13, v60(v61, v_u_52, v64))
		end
		if v_u_22 ~= v_u_23 then
			local v65 = v_u_2.fromParams
			local v66 = v_u_4.getAttribute(p_u_12, "Rate_Curve", v_u_4.default_bezier)
			local function v69(p67, p68)
				-- upvalues: (ref) v_u_22, (ref) v_u_4, (ref) v_u_22, (ref) v_u_23
				v_u_22 = v_u_4.lerp(v_u_22, v_u_23, p67)
				return p68
			end
			table.insert(p_u_13, v65(v66, v_u_52, v69))
		end
		local v_u_70 = v_u_4.getAttribute(p_u_12, "Path_Curve", v_u_4.linear_bezier)
		local v71, v72 = pcall(function()
			-- upvalues: (ref) v_u_4, (copy) v_u_70
			return v_u_4.deserializePath(v_u_70)
		end)
		if not v71 then
			v_u_3.error((("failed to decode bezier path data with error: %*"):format(v72)))
		end
		local v_u_73 = v_u_5.new(v72, 0)
		local v74 = v_u_2.fromParams
		local v75 = v_u_4.linear_bezier
		local function v135(_, p76)
			-- upvalues: (ref) v_u_57, (ref) v_u_22, (ref) v_u_52, (ref) v_u_58, (copy) v_u_73, (copy) v_u_51, (ref) v_u_56, (copy) p_u_11, (ref) v_u_54, (copy) v_u_29, (copy) v_u_14, (copy) v_u_20, (ref) v_u_7, (copy) v_u_40, (copy) v_u_41, (ref) v_u_4, (ref) v_u_9, (copy) p_u_12, (copy) p_u_13, (copy) v_u_49, (copy) v_u_30, (copy) v_u_33, (copy) v_u_32, (ref) v_u_2, (copy) v_u_35, (ref) v_u_59, (copy) v_u_38, (copy) v_u_44, (copy) v_u_46, (copy) v_u_55, (copy) v_u_37, (copy) v_u_39, (copy) v_u_45, (copy) v_u_47, (copy) v_u_34, (copy) v_u_36, (copy) v_u_50, (copy) v_u_48
			v_u_57 = v_u_57 + p76
			local v77 = 1 / v_u_22
			local v78 = v_u_52 * v_u_22
			if v_u_57 < v77 or v78 <= v_u_58 then
				return p76
			end
			for _ = 1, v_u_57 // v77 do
				if v78 > v_u_58 then
					v_u_58 = v_u_58 + 1
					local v79 = v_u_58 / v78
					local v80 = 1 - v_u_73:getEase((math.clamp(v79, 0, 1))).y
					if v_u_51 then
						v_u_56 = p_u_11.WorldCFrame
					end
					local v81 = workspace:Raycast(v_u_56.Position + v_u_56:VectorToWorldSpace(v_u_54) * v_u_29 * v80, p_u_11.WorldCFrame:VectorToWorldSpace(v_u_14), v_u_20)
					if not v81 then
						v_u_57 = 0
						return p76
					end
					local v82 = v_u_7:NextNumber(v_u_40.X, v_u_41.X)
					local v83 = v_u_7:NextNumber(v_u_40.Y, v_u_41.Y)
					local v84 = v_u_7:NextNumber(v_u_40.Z, v_u_41.Z)
					local v_u_85 = v_u_4.getRanomId()
					local v_u_86 = v_u_9:get(v_u_85)
					local v87 = v_u_86._getReal()
					v_u_4.copyProperties(p_u_12, v87, v_u_4.COPY_PART_PROPERTIES)
					v_u_4.copyProperties(p_u_12, v87, v_u_4.COPY_EXTENDED_PART_PROPERTIES)
					if #p_u_12:GetChildren() ~= 0 then
						local v88 = p_u_12:Clone()
						for _, v89 in v88:GetChildren() do
							v89.Parent = v87
						end
						v88:Destroy()
					end
					local v90 = p_u_13
					local function v91()
						-- upvalues: (ref) v_u_9, (copy) v_u_85
						if v_u_9 then
							v_u_9:free(v_u_85)
						end
					end
					table.insert(v90, v91)
					v_u_86.Color = v81.Instance.Color
					v_u_86.Material = v81.Material
					v_u_86.Transparency = v81.Instance.Transparency
					if v_u_86.Transparency == 0 then
						v_u_86.Transparency = v_u_49
					end
					v_u_86.Size = Vector3.new(0, 0, 0)
					local v92 = v_u_7:NextNumber(v_u_30.Min, v_u_30.Max)
					local v93 = -math.cos(v92)
					local v94 = -math.sin(v92)
					local v95 = p_u_11.WorldCFrame:VectorToWorldSpace((Vector3.new(v93, 0, v94))):Cross(v81.Normal).Unit
					local v96 = CFrame.fromMatrix(v81.Position, v95, v81.Normal)
					local v97 = CFrame.fromOrientation
					local v98 = v83 / v84
					local v_u_99 = v96 * v97(-math.atan(v98), 0, 0)
					v_u_86.CFrame = CFrame.new(v_u_33) * v_u_99
					local v_u_100 = nil
					local v_u_101 = Vector3.new(0, 0, 0)
					local v_u_102
					if v_u_33 == v_u_32 then
						v_u_102 = nil
					else
						v_u_102 = v_u_2.fromParams(v_u_4.getAttribute(p_u_12, "Offset_Start_Curve", v_u_4.default_bezier), v_u_35, function(p103, p104)
							-- upvalues: (ref) v_u_101, (ref) v_u_33, (ref) v_u_32, (copy) v_u_86, (copy) v_u_99
							v_u_101 = v_u_33:Lerp(v_u_32, p103)
							v_u_86.CFrame = CFrame.new(v_u_101) * v_u_99
							return p104
						end)
						local v105 = p_u_13
						table.insert(v105, v_u_102)
					end
					local v_u_106 = Vector3.new(v82, v83, v84) * v_u_59
					if v_u_106 * v_u_38 == v_u_106 then
						v_u_86.Size = v_u_106 * v_u_38
					else
						v_u_100 = v_u_2.fromParams(v_u_44, v_u_46, function(p107, p108)
							-- upvalues: (copy) v_u_86, (copy) v_u_106, (ref) v_u_38
							v_u_86.Size = (v_u_106 * v_u_38):Lerp(v_u_106, p107)
							return p108
						end)
						local v109 = p_u_13
						table.insert(v109, v_u_100)
					end
					if shared.vfx and #v_u_86:GetChildren() ~= 0 then
						local v110 = v_u_55
						local v111 = shared.vfx.emit(v87).Finished
						table.insert(v110, v111)
					end
					task.delay(v_u_7:NextNumber(v_u_37.Min, v_u_37.Max), function()
						-- upvalues: (ref) v_u_100, (ref) v_u_102, (copy) v_u_86, (copy) v_u_106, (ref) v_u_39, (ref) p_u_13, (ref) v_u_2, (ref) v_u_45, (ref) v_u_47, (ref) v_u_101, (ref) v_u_34, (ref) v_u_4, (ref) p_u_12, (ref) v_u_36, (copy) v_u_99, (ref) v_u_50, (ref) v_u_48
						if v_u_100 then
							v_u_100:Disconnect()
						end
						if v_u_102 then
							v_u_102:Disconnect()
						end
						local v_u_112 = v_u_86.Size
						local v_u_113 = v_u_86.Transparency
						if v_u_112 ~= v_u_106 * v_u_39 then
							local v114 = p_u_13
							local v115 = v_u_2.fromParams
							local v116 = v_u_45
							local v117 = v_u_47
							local function v120(p118, p119)
								-- upvalues: (ref) v_u_86, (copy) v_u_112, (ref) v_u_106, (ref) v_u_39
								v_u_86.Size = v_u_112:Lerp(v_u_106 * v_u_39, p118)
								return p119
							end
							table.insert(v114, v115(v116, v117, v120))
						end
						if v_u_101 ~= v_u_34 then
							local v121 = p_u_13
							local v122 = v_u_2.fromParams
							local v123 = v_u_4.getAttribute(p_u_12, "Offset_End_Curve", v_u_4.default_bezier)
							local v124 = v_u_36
							local function v127(p125, p126)
								-- upvalues: (ref) v_u_86, (ref) v_u_101, (ref) v_u_34, (ref) v_u_99
								v_u_86.CFrame = CFrame.new(v_u_101:Lerp(v_u_34, p125)) * v_u_99
								return p126
							end
							table.insert(v121, v122(v123, v124, v127))
						end
						if v_u_113 == v_u_50 then
							v_u_86.Transparency = v_u_113
						else
							local v128 = p_u_13
							local v129 = v_u_2.fromParams
							local v130 = v_u_4.getAttribute(p_u_12, "Transparency_Curve", v_u_4.default_bezier)
							local v131 = v_u_48
							local function v134(p132, p133)
								-- upvalues: (ref) v_u_86, (ref) v_u_4, (copy) v_u_113, (ref) v_u_50
								v_u_86.Transparency = v_u_4.lerp(v_u_113, v_u_50, p132)
								return p133
							end
							table.insert(v128, v129(v130, v131, v134))
						end
					end)
				end
			end
			v_u_57 = v_u_57 % v77
			return p76
		end
		local v136 = v_u_4.RENDER_PRIORITY + p_u_13.depth
		table.insert(p_u_13, v74(v75, v_u_52, v135, nil, nil, true, v136))
		task.wait(v_u_37.Max + v_u_52 + math.max(v_u_47, v_u_36))
		v_u_6.all(v_u_55):await()
	end
end
return v8
