-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("CollectionService")
local v_u_2 = require("./mod/tween")
local v_u_3 = require("./mod/utility")
local v_u_4 = require(script.Parent.obj.Promise)
require("./obj/ObjectCache")
local v_u_5 = Random.new()
local v6 = {}
local v_u_7 = nil
function v6.init(p8)
	-- upvalues: (ref) v_u_7
	v_u_7 = p8
end
function v6.deinit()
	-- upvalues: (ref) v_u_7
	v_u_7 = nil
end
function v6.emit(p9, p_u_10, p_u_11)
	-- upvalues: (ref) v_u_7, (copy) v_u_3, (copy) v_u_1, (copy) v_u_5, (copy) v_u_2, (copy) v_u_4
	if v_u_7 then
		local v12 = v_u_3.getAttribute(p9, "RayDirection", Vector3.new(0, -50, 0))
		local v13 = v_u_3.getAttribute(p9, "RayCollisionGroup", "Default")
		local v14 = v_u_3.getAttribute(p9, "FilterTag", "")
		local v15 = v_u_3.getAttribute(p9, "FilterType", "Exclude")
		local v16 = v_u_3.getAttribute(p9, "IgnoreWater", true)
		local v17 = v_u_3.getAttribute(p9, "IgnoreCanCollide", false)
		local v18 = RaycastParams.new()
		v18.CollisionGroup = v13
		v18.IgnoreWater = v16
		v18.RespectCanCollide = not v17
		v18.FilterType = Enum.RaycastFilterType[v15]
		v18.FilterDescendantsInstances = v_u_1:GetTagged(v14)
		if v15 == "Exclude" then
			v18:AddToFilter({ workspace.Terrain })
		end
		local v19 = v_u_3.getAttribute(p_u_10, "EmitDelay", 0)
		local v20 = v_u_3.getAttribute(p_u_10, "Radius", 5)
		local v21 = v_u_3.getAttribute(p_u_10, "Segments", 7)
		local v22 = v_u_3.getRangeAttribute(p_u_10, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, (1 / 0)))
		local v23 = v_u_3.getAttribute(p_u_10, "PartOffset", Vector3.new(0, 0, 0), true)
		local v_u_24 = v_u_3.getAttribute(p_u_10, "BaseOffset", v23)
		local v_u_25 = v_u_3.getAttribute(p_u_10, "Offset_Start", v23)
		local v_u_26 = v_u_3.getAttribute(p_u_10, "Offset_End", v23)
		local v27 = v_u_3.getAttribute(p_u_10, "Offset_Start_Duration", 0.5)
		local v_u_28 = v_u_3.getAttribute(p_u_10, "Offset_End_Duration", 0.5)
		local v_u_29 = v_u_3.getAttribute(p_u_10, "SizeScaleStart", Vector3.new(0, 0, 0))
		local v_u_30 = v_u_3.getAttribute(p_u_10, "SizeScaleEnd", Vector3.new(0, 0, 0))
		local v31 = v_u_3.getAttribute(p_u_10, "MinSize", Vector3.new(2, 1, 2))
		local v32 = v_u_3.getAttribute(p_u_10, "MaxSize", Vector3.new(3, 2, 3))
		local v33 = v_u_3.getAttribute(p_u_10, "Size_Curve", v_u_3.default_bezier, true)
		local v34 = v_u_3.getAttribute(p_u_10, "Size_Duration", 0.5, true)
		local v35 = v_u_3.getAttribute(p_u_10, "Size_Start_Curve", v33)
		local v_u_36 = v_u_3.getAttribute(p_u_10, "Size_End_Curve", v33)
		local v37 = v_u_3.getAttribute(p_u_10, "Size_Start_Duration", v34)
		local v_u_38 = v_u_3.getAttribute(p_u_10, "Size_End_Duration", v34)
		local v_u_39 = v_u_3.getAttribute(p_u_10, "Transparency_Duration", 0.5)
		local v40 = v_u_3.getAttribute(p_u_10, "Transparency_Start", 0)
		local v_u_41 = v_u_3.getAttribute(p_u_10, "Transparency_End", 0)
		task.wait(v19)
		local v42 = {}
		for v43 = 0, v21 - 1 do
			local v44 = v43 / v21 * 3.141592653589793 * 2
			local v45 = v20 * math.cos(v44)
			local v46 = v20 * math.sin(v44)
			local v47 = workspace:Raycast((p9.WorldCFrame * CFrame.new(v45, 0, v46)).Position, p9.WorldCFrame:VectorToWorldSpace(v12), v18)
			if v47 then
				local v48 = v_u_5:NextNumber(v31.X, v32.X)
				local v49 = v_u_5:NextNumber(v31.Y, v32.Y)
				local v50 = v_u_5:NextNumber(v31.Z, v32.Z)
				local v_u_51 = v_u_3.getRanomId()
				local v_u_52 = v_u_7:get(v_u_51)
				local v53 = v_u_52._getReal()
				v_u_3.copyProperties(p_u_10, v53, v_u_3.COPY_PART_PROPERTIES)
				v_u_3.copyProperties(p_u_10, v53, v_u_3.COPY_EXTENDED_PART_PROPERTIES)
				if #p_u_10:GetChildren() ~= 0 then
					local v54 = p_u_10:Clone()
					for _, v55 in v54:GetChildren() do
						v55.Parent = v53
					end
					v54:Destroy()
				end
				local function v56()
					-- upvalues: (ref) v_u_7, (copy) v_u_51
					if v_u_7 then
						v_u_7:free(v_u_51)
					end
				end
				table.insert(p_u_11, v56)
				v_u_52.Color = v47.Instance.Color
				v_u_52.Material = v47.Material
				v_u_52.Transparency = v47.Instance.Transparency
				if v_u_52.Transparency == 0 then
					v_u_52.Transparency = v40
				end
				v_u_52.Size = Vector3.new(0, 0, 0)
				local v57 = -math.cos(v44)
				local v58 = -math.sin(v44)
				local v59 = p9.WorldCFrame:VectorToWorldSpace((Vector3.new(v57, 0, v58))):Cross(v47.Normal).Unit
				local v60 = CFrame.fromMatrix(v47.Position, v59, v47.Normal)
				local v61 = CFrame.fromOrientation
				local v62 = v49 / v50
				local v_u_63 = v60 * v61(-math.atan(v62), 0, 0)
				v_u_52.CFrame = CFrame.new(v_u_25) * v_u_63
				local v_u_64 = nil
				local v_u_65 = Vector3.new(0, 0, 0)
				local v_u_66
				if v_u_25 == v_u_24 then
					v_u_66 = nil
				else
					v_u_66 = v_u_2.fromParams(v_u_3.getAttribute(p_u_10, "Offset_Start_Curve", v_u_3.default_bezier), v27, function(p67, p68)
						-- upvalues: (ref) v_u_65, (copy) v_u_25, (copy) v_u_24, (copy) v_u_52, (copy) v_u_63
						v_u_65 = v_u_25:Lerp(v_u_24, p67)
						v_u_52.CFrame = CFrame.new(v_u_65) * v_u_63
						return p68
					end)
					table.insert(p_u_11, v_u_64)
				end
				local v_u_69 = Vector3.new(v48, v49, v50)
				if v_u_69 * v_u_29 == v_u_69 then
					v_u_52.Size = v_u_69 * v_u_29
				else
					v_u_64 = v_u_2.fromParams(v35, v37, function(p70, p71)
						-- upvalues: (copy) v_u_52, (copy) v_u_69, (copy) v_u_29
						v_u_52.Size = (v_u_69 * v_u_29):Lerp(v_u_69, p70)
						return p71
					end)
					table.insert(p_u_11, v_u_64)
				end
				if shared.vfx and #v_u_52:GetChildren() ~= 0 then
					local v72 = shared.vfx.emit(v_u_52).Finished
					table.insert(v42, v72)
				end
				task.delay(v_u_5:NextNumber(v22.Min, v22.Max), function()
					-- upvalues: (ref) v_u_64, (ref) v_u_66, (copy) v_u_52, (copy) v_u_69, (copy) v_u_30, (copy) p_u_11, (ref) v_u_2, (copy) v_u_36, (copy) v_u_38, (ref) v_u_65, (copy) v_u_26, (ref) v_u_3, (copy) p_u_10, (copy) v_u_28, (copy) v_u_63, (copy) v_u_41, (copy) v_u_39
					if v_u_64 then
						v_u_64:Disconnect()
					end
					if v_u_66 then
						v_u_66:Disconnect()
					end
					local v_u_73 = v_u_52.Size
					local v_u_74 = v_u_52.Transparency
					if v_u_73 ~= v_u_69 * v_u_30 then
						local v75 = p_u_11
						local v76 = v_u_2.fromParams
						local v77 = v_u_36
						local v78 = v_u_38
						local function v81(p79, p80)
							-- upvalues: (ref) v_u_52, (copy) v_u_73, (ref) v_u_69, (ref) v_u_30
							v_u_52.Size = v_u_73:Lerp(v_u_69 * v_u_30, p79)
							return p80
						end
						table.insert(v75, v76(v77, v78, v81))
					end
					if v_u_65 ~= v_u_26 then
						local v82 = p_u_11
						local v83 = v_u_2.fromParams
						local v84 = v_u_3.getAttribute(p_u_10, "Offset_End_Curve", v_u_3.default_bezier)
						local v85 = v_u_28
						local function v88(p86, p87)
							-- upvalues: (ref) v_u_52, (ref) v_u_65, (ref) v_u_26, (ref) v_u_63
							v_u_52.CFrame = CFrame.new(v_u_65:Lerp(v_u_26, p86)) * v_u_63
							return p87
						end
						table.insert(v82, v83(v84, v85, v88))
					end
					if v_u_74 == v_u_41 then
						v_u_52.Transparency = v_u_74
					else
						local v89 = p_u_11
						local v90 = v_u_2.fromParams
						local v91 = v_u_3.getAttribute(p_u_10, "Transparency_Curve", v_u_3.default_bezier)
						local v92 = v_u_39
						local function v95(p93, p94)
							-- upvalues: (ref) v_u_52, (ref) v_u_3, (copy) v_u_74, (ref) v_u_41
							v_u_52.Transparency = v_u_3.lerp(v_u_74, v_u_41, p93)
							return p94
						end
						table.insert(v89, v90(v91, v92, v95))
					end
				end)
			end
		end
		task.wait(v22.Max + math.max(v_u_38, v_u_28))
		v_u_4.all(v42):await()
	end
end
return v6
