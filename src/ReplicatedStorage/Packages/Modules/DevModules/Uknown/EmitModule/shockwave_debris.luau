-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = game:GetService("CollectionService")
local v_u_3 = require("./mod/tween")
local v_u_4 = require("./mod/utility")
require("./obj/ObjectCache")
local v_u_5 = require(script.Parent.obj.Promise)
local v_u_6 = Random.new()
local v7 = {}
local v_u_8 = {}
local v_u_9 = nil
local v_u_10 = nil
function v7.init(p11)
	-- upvalues: (ref) v_u_10, (ref) v_u_9, (copy) v_u_1, (copy) v_u_8
	if not v_u_10 then
		v_u_9 = p11
		if v_u_1:IsStudio() and script:FindFirstAncestorOfClass("Plugin") then
			v_u_10 = v_u_1.RenderStepped:Connect(function(p12)
				-- upvalues: (ref) v_u_8
				if #v_u_8 ~= 0 then
					workspace:StepPhysics(p12, v_u_8)
				end
			end)
		end
	end
end
function v7.deinit()
	-- upvalues: (ref) v_u_10, (ref) v_u_9, (copy) v_u_8
	if v_u_10 then
		v_u_10:Disconnect()
		v_u_10 = nil
	end
	v_u_9 = nil
	for _, v13 in v_u_8 do
		v13:Destroy()
	end
	table.clear(v_u_8)
end
function v7.emit(p14, p15, p_u_16)
	-- upvalues: (ref) v_u_9, (copy) v_u_4, (copy) v_u_2, (copy) v_u_6, (copy) v_u_8, (copy) v_u_3, (copy) v_u_5
	if v_u_9 then
		local v17 = v_u_4.getAttribute(p15, "InheritanceEnabled", true)
		local v18 = v_u_4.getAttribute(p15, "InheritanceRadius", 5)
		local v19
		if v17 then
			local v20 = v_u_4.getAttribute(p15, "InheritanceMaxResults", 5)
			local v21 = v_u_4.getAttribute(p14, "RayCollisionGroup", "Default")
			local v22 = v_u_4.getAttribute(p14, "FilterTag", "")
			local v23 = v_u_4.getAttribute(p14, "FilterType", "Exclude")
			local v24 = v_u_4.getAttribute(p14, "IgnoreCanCollide", false)
			v19 = OverlapParams.new()
			v19.MaxParts = v20
			v19.CollisionGroup = v21
			v19.RespectCanCollide = not v24
			v19.FilterType = Enum.RaycastFilterType[v23]
			v19.FilterDescendantsInstances = v_u_2:GetTagged(v22)
			if v23 == "Exclude" then
				v19:AddToFilter({ workspace.Terrain })
			end
		else
			v19 = nil
		end
		local v25 = v_u_4.getAttribute(p15, "EmitDelay", 0)
		local v26 = v_u_4.getRangeAttribute(p15, "Amount", NumberRange.new(5, 10), NumberRange.new(0, (1 / 0)))
		local v27 = v_u_4.getRangeAttribute(p15, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, (1 / 0)))
		local v28 = v_u_4.getRangeAttribute(p15, "Airtime", NumberRange.new(0.5, 0.5), NumberRange.new(0, (1 / 0)))
		local v29 = v_u_4.getRangeAttribute(p15, "LinearMagnitude", NumberRange.new(15, 25))
		local v30 = v_u_4.getRangeAttribute(p15, "AngularMagnitude", NumberRange.new(5, 15))
		local v_u_31 = v_u_4.getAttribute(p15, "SizeScaleEnd", Vector3.new(0, 0, 0))
		local v32 = v_u_4.getAttribute(p15, "MinSize", Vector3.new(2, 1, 2))
		local v33 = v_u_4.getAttribute(p15, "MaxSize", Vector3.new(3, 2, 3))
		local v34 = v_u_4.getAttribute(p15, "MinDirection", Vector3.new(-1, -1, -1))
		local v35 = v_u_4.getAttribute(p15, "MaxDirection", Vector3.new(1, 1, 1))
		local v36 = v_u_6:NextInteger(v26.Min, v26.Max)
		local v_u_37 = v_u_4.getAttribute(p15, "Size_Curve", v_u_4.default_bezier)
		local v_u_38 = v_u_4.getAttribute(p15, "Transparency_Curve", v_u_4.default_bezier)
		local v_u_39 = v_u_4.getAttribute(p15, "Transparency_Duration", 0.5)
		local v_u_40 = v_u_4.getAttribute(p15, "Size_Duration", 0.5)
		local v_u_41 = v_u_4.getAttribute(p15, "Transparency_Start", 0)
		local v_u_42 = v_u_4.getAttribute(p15, "Transparency_End", 1)
		local v43 = {}
		local v44 = {}
		p15.CanCollide = false
		if v19 then
			for _, v45 in workspace:GetPartBoundsInRadius(p14.WorldPosition, v18, v19) do
				if v45.Transparency ~= 1 then
					table.insert(v43, v45)
				end
			end
		end
		task.wait(v25)
		for _ = 1, v36 do
			local v46
			if #v43 == 0 then
				v46 = false
			else
				v46 = v43[v_u_6:NextInteger(1, #v43)]
			end
			local v_u_47 = v_u_4.getRanomId()
			local v_u_48 = v_u_9:get(v_u_47)
			local v_u_49 = v_u_48._getReal()
			v_u_4.copyProperties(p15, v_u_49, v_u_4.COPY_PART_PROPERTIES)
			v_u_4.copyProperties(p15, v_u_49, v_u_4.COPY_EXTENDED_PART_PROPERTIES)
			if #p15:GetChildren() ~= 0 then
				local v50 = p15:Clone()
				for _, v51 in v50:GetChildren() do
					v51.Parent = v_u_49
				end
				v50:Destroy()
			end
			v_u_48.Anchored = false
			v_u_48.CanCollide = true
			v_u_48.Transparency = v_u_41
			if v_u_48.CollisionGroup == "Default" then
				v_u_48.CollisionGroup = "ForgeDebris"
			end
			v_u_48.CFrame = CFrame.new(p14.WorldPosition)
			local v52 = v_u_6:NextNumber(v32.X, v33.X)
			local v53 = v_u_6:NextNumber(v32.Y, v33.Y)
			local v54 = v_u_6
			local v55 = v32.Z
			local v56 = v33.Z
			local v_u_57 = Vector3.new(v52, v53, v54:NextNumber(v55, v56))
			v_u_48.Size = v_u_57
			if v46 then
				v_u_48.Material = v46.Material
				v_u_48.Color = v46.Color
				v_u_48.Transparency = v46.Transparency
			end
			local function v59()
				-- upvalues: (ref) v_u_8, (copy) v_u_49, (ref) v_u_9, (copy) v_u_47
				local v58 = table.find(v_u_8, v_u_49)
				if v58 then
					table.remove(v_u_8, v58)
				end
				if v_u_9 then
					v_u_9:free(v_u_47)
				end
			end
			table.insert(p_u_16, v59)
			local v60 = v_u_8
			table.insert(v60, v_u_49)
			v_u_48.AssemblyLinearVelocity = p14.WorldCFrame:VectorToWorldSpace(v_u_48.AssemblyLinearVelocity)
			local v61 = v_u_4.randomUnitVector(v34, v35)
			local v62 = p14.WorldCFrame:VectorToWorldSpace(v61)
			v_u_48:ApplyImpulse(v_u_48.AssemblyMass * v_u_4.getImpulseForce(p14.WorldPosition, p14.WorldPosition + v62.Unit * v_u_6:NextNumber(v29.Min, v29.Max), v_u_6:NextNumber(v28.Min, v28.Max)))
			v_u_48:ApplyAngularImpulse(v_u_48.AssemblyMass * v_u_6:NextUnitVector() * v_u_6:NextNumber(v30.Min, v30.Max))
			if shared.vfx and #v_u_48:GetChildren() ~= 0 then
				local v63 = shared.vfx.emit(v_u_48).Finished
				table.insert(v44, v63)
			end
			task.delay(v_u_6:NextNumber(v27.Min, v27.Max), function()
				-- upvalues: (copy) v_u_48, (copy) v_u_57, (copy) v_u_31, (copy) p_u_16, (ref) v_u_3, (copy) v_u_37, (copy) v_u_40, (copy) v_u_41, (copy) v_u_42, (copy) v_u_38, (copy) v_u_39, (ref) v_u_4
				local v_u_64 = v_u_48.Size
				if v_u_64 ~= v_u_57 * v_u_31 then
					local v65 = p_u_16
					local v66 = v_u_3.fromParams
					local v67 = v_u_37
					local v68 = v_u_40
					local function v71(p69, p70)
						-- upvalues: (ref) v_u_48, (copy) v_u_64, (ref) v_u_57, (ref) v_u_31
						v_u_48.Size = v_u_64:Lerp(v_u_57 * v_u_31, p69)
						return p70
					end
					table.insert(v65, v66(v67, v68, v71))
				end
				if v_u_41 == v_u_42 then
					v_u_48.Transparency = v_u_41
				else
					local v72 = p_u_16
					local v73 = v_u_3.fromParams
					local v74 = v_u_38
					local v75 = v_u_39
					local function v78(p76, p77)
						-- upvalues: (ref) v_u_48, (ref) v_u_4, (ref) v_u_41, (ref) v_u_42
						v_u_48.Transparency = v_u_4.lerp(v_u_41, v_u_42, p76)
						return p77
					end
					table.insert(v72, v73(v74, v75, v78))
				end
			end)
		end
		task.wait(v27.Max + math.max(v_u_39, v_u_40))
		v_u_5.all(v44):await()
	end
end
return v7
