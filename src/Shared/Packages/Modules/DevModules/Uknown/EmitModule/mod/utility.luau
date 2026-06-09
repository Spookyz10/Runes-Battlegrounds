-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = game:GetService("PhysicsService")
local v_u_3 = require("./logger")
local v_u_4 = {
	["DEG_TO_RAD"] = 0.017453292519943295,
	["BEZIER_TAG"] = "BezierParticle",
	["SHOCKWAVE_TAG"] = "Shockwave",
	["SCREENSHAKE_TAG"] = "CameraShake",
	["ENABLED_VFX_TAG"] = "ConstantVFX",
	["TEXTURE_LOAD_TAG"] = "LoadVFXTextures",
	["RENDER_PRIORITY"] = Enum.RenderPriority.Camera.Value + 1
}
local v5 = {
	["StudioSelectable"] = {},
	["ForgeDebris"] = {
		["ForgeDebris"] = false
	},
	["ForgeMouseIgnore"] = {
		["StudioSelectable"] = false
	}
}
v_u_4.COLLISION_GROUPS = v5
v_u_4.COPY_SPECIALMESH_PROPERTIES = {
	"MeshId",
	"MeshType",
	"Offset",
	"Scale",
	"TextureId",
	"VertexColor"
}
v_u_4.COPY_PART_PROPERTIES = {
	"CastShadow",
	"Color",
	"Material",
	"MaterialVariant",
	"Reflectance",
	"Shape",
	"FrontSurface",
	"BackSurface",
	"LeftSurface",
	"RightSurface",
	"TopSurface",
	"BottomSurface"
}
v_u_4.COPY_EXTENDED_PART_PROPERTIES = {
	"Size",
	"Transparency",
	"CanCollide",
	"CanQuery",
	"CanTouch",
	"CollisionGroup"
}
local v_u_6 = setmetatable({}, {
	["__mode"] = "k"
})
function v_u_4.lock(p7)
	-- upvalues: (copy) v_u_6
	if v_u_6[p7] then
		return true
	end
	v_u_6[p7] = coroutine.running()
	return false
end
function v_u_4.unlock(p8, p9)
	-- upvalues: (copy) v_u_6, (copy) v_u_3
	local v10 = v_u_6[p8]
	if coroutine.running() ~= v10 and p9 ~= v10 then
		v_u_3.error("attempt to unlock an instance owned by a different thread")
	end
	v_u_6[p8] = nil
end
function v_u_4.setCollisionGroups(p11)
	-- upvalues: (copy) v_u_2, (copy) v_u_1
	local v12 = {}
	for v13, v14 in p11 do
		v_u_2:RegisterCollisionGroup(v13)
		if not v13:match("Studio") or v_u_1:IsStudio() then
			v12[v13] = v14
		end
	end
	for v15, v16 in v12 do
		for v17, v18 in v16 do
			if not v17:match("Studio") or v_u_1:IsStudio() then
				v_u_2:CollisionGroupSetCollidable(v15, v17, v18)
			end
		end
	end
end
local v_u_19 = 0
function v_u_4.getRanomId()
	-- upvalues: (ref) v_u_19
	v_u_19 = v_u_19 + 1
	local v20 = v_u_19
	return tostring(v20)
end
function v_u_4.copyProperties(p21, p22, p23)
	for _, v24 in p23 do
		p22[v24] = p21[v24]
	end
end
function v_u_4.lerp(p25, p26, p27)
	return p25 + (p26 - p25) * p27
end
function v_u_4.try(p_u_28, p29, ...)
	-- upvalues: (copy) v_u_3
	local v31 = { xpcall(p29, function(p30)
			-- upvalues: (ref) v_u_3, (copy) p_u_28
			v_u_3.warn(string.format(p_u_28, p30))
		end, ...) }
	return v31[1], table.unpack(v31, 2)
end
function v_u_4.reboundfn(p_u_32, p_u_33)
	local v_u_34 = nil
	return function(...)
		-- upvalues: (ref) v_u_34, (copy) p_u_32, (copy) p_u_33
		if v_u_34 then
			task.cancel(v_u_34)
		end
		local v_u_35 = { ... }
		v_u_34 = task.delay(p_u_32, function()
			-- upvalues: (ref) v_u_34, (ref) p_u_33, (copy) v_u_35
			v_u_34 = nil
			local v36 = v_u_35
			p_u_33(table.unpack(v36))
		end)
	end
end
function v_u_4.randomUnitVector(p37, p38, p39)
	local v40 = p39 or Random.new()
	local v41 = v40:NextNumber(p37.X, p38.X)
	local v42 = v40:NextNumber(p37.Y, p38.Y)
	local v43 = p37.Z
	local v44 = p38.Z
	return Vector3.new(v41, v42, v40:NextNumber(v43, v44))
end
function v_u_4.getImpulseForce(p45, p46, p47)
	local v48 = (p46 - p45) / p47
	local v49 = workspace.Gravity * p47 * 0.5
	return v48 + Vector3.new(0, v49, 0)
end
function v_u_4.isMeshVFX(p50)
	local v51 = p50 and (p50:IsA("Model") and p50:FindFirstChild("Start") and (p50.Start:IsA("BasePart") and p50:FindFirstChild("End")))
	if v51 then
		v51 = p50.End:IsA("BasePart")
	end
	return v51
end
function v_u_4.cleanupScope(p52)
	-- upvalues: (copy) v_u_4
	for _, v53 in p52 do
		local v54 = typeof(v53)
		if v54 == "Instance" then
			v53:Destroy()
		elseif v54 == "RBXScriptConnection" then
			v53:Disconnect()
		elseif v54 == "thread" then
			if coroutine.status(v53) ~= "dead" then
				task.cancel(v53)
			end
		elseif v54 == "function" then
			task.spawn(v53)
		elseif v54 == "table" then
			v_u_4.cleanupScope(v53)
		end
	end
	table.clear(p52)
end
function v_u_4.protectParent(p55, p_u_56)
	local v57 = p_u_56.AncestryChanged
	table.insert(p55, v57:Connect(function(_, _)
		-- upvalues: (copy) p_u_56
		if p_u_56.Parent ~= workspace.Terrain then
			p_u_56.Parent = workspace.Terrain
		end
	end))
end
function v_u_4.findFirstClassWithTag(p58, p59, p60)
	-- upvalues: (copy) v_u_4
	if p58 and p58.Parent ~= game then
		if p58.ClassName == p59 and p58:HasTag(p60) then
			return p58
		else
			return v_u_4.findFirstClassWithTag(p58.Parent, p59, p60)
		end
	else
		return
	end
end
function v_u_4.cloneParticleAncestry(p_u_61, p_u_62)
	if p_u_61:FindFirstAncestorWhichIsA("BasePart") or p_u_61:FindFirstAncestorOfClass("Attachment") then
		local function v_u_64(p63)
			-- upvalues: (copy) v_u_64
			if p63.Parent and (p63.Parent:IsA("BasePart") or p63.Parent:IsA("Attachment")) then
				p63 = v_u_64(p63.Parent)
			end
			return p63
		end
		local function v_u_73(p65)
			-- upvalues: (copy) p_u_62, (copy) p_u_61, (copy) v_u_64, (copy) v_u_73
			local v66 = p_u_62[p65]
			if v66 then
				if p65 == p_u_61 then
					return v66, p_u_62[p65.Parent]
				end
				local v67 = p_u_62
				local v68 = p65.Parent
				if v68.Parent and (v68.Parent:IsA("BasePart") or v68.Parent:IsA("Attachment")) then
					v68 = v_u_64(v68.Parent)
				end
				return v66, v67[v68] or p_u_62[p65]
			end
			local v69 = Instance.fromExisting(p65)
			v69.Archivable = false
			if v69:IsA("BasePart") then
				v69.Locked = true
			end
			if p_u_62 then
				p_u_62[p65] = v69
			end
			local v70
			if p65.Parent and (p65.Parent:IsA("BasePart") or p65.Parent:IsA("Attachment")) then
				local v71, v72 = v_u_73(p65.Parent)
				v70 = v72 or v69
				if v71 then
					v69.Parent = v71
				end
			else
				v70 = v69
			end
			return v69, v70
		end
		return v_u_73(p_u_61.Parent)
	end
end
function v_u_4.getAttribute(p74, p75, p76, p77)
	local v78 = p74:GetAttribute(p75)
	if v78 ~= nil and typeof(v78) == typeof(p76) then
		p76 = v78
	end
	if not p77 then
		p74:SetAttribute(p75, p76)
	end
	return p76
end
function v_u_4.getRangeAttribute(p79, p80, p81, p82, p83)
	local v84 = p79:GetAttribute(p80)
	if typeof(v84) ~= "NumberRange" then
		v84 = p81
	end
	if p82 then
		local v85 = NumberRange.new
		local v86 = v84.Min
		local v87 = p82.Min
		local v88 = p82.Max
		local v89 = math.clamp(v86, v87, v88)
		local v90 = v84.Max
		local v91 = p82.Min
		local v92 = p82.Max
		v84 = v85(v89, (math.clamp(v90, v91, v92)))
	end
	if not p83 then
		p79:SetAttribute(p80, v84)
	end
	return v84
end
function v_u_4.getEnumAttribute(p93, p94, p95, p96, p97)
	local v98 = p93:GetAttribute(p94)
	if v98 ~= nil and table.find(p96, v98) then
		p95 = v98
	end
	if not p97 then
		p93:SetAttribute(p94, p95)
	end
	return p95
end
function v_u_4.getMeshDecals(p99, p100)
	-- upvalues: (copy) v_u_4
	local v101 = {}
	local v102 = {}
	local v103 = {}
	local function v107(p104)
		local v105 = {}
		for _, v106 in p104 do
			if v106:IsA("Decal") then
				table.insert(v105, v106)
			end
		end
		return v105
	end
	if v_u_4.getAttribute(p99, "Flipbook", false, true) then
		return v107(p100:GetChildren()), v102, v103
	end
	local v108 = p99:FindFirstChild("End")
	if v108 then
		for _, v109 in p100:GetChildren() do
			if v109:IsA("Decal") then
				local v110 = v108:FindFirstChild(v109.Name)
				if v110 and v110:IsA("Decal") then
					table.insert(v101, v109)
					v103[v109] = v110
					local v111 = v109:GetChildren()
					local v112 = 0
					for v113 = 1, #v111 do
						local v114 = v113 - v112
						if not v111[v114]:IsA("Decal") then
							table.remove(v111, v114)
							v112 = v112 + 1
						end
					end
					if #v111 ~= 0 then
						table.sort(v111, function(p115, p116)
							local v117 = p115.Name
							local v118 = tonumber(v117:match("%d+")) or 0
							local v119 = p116.Name
							return v118 < (tonumber(v119:match("%d+")) or 0)
						end)
						local v120 = {}
						for _, v121 in v111 do
							local v122 = v121.Texture
							local v123 = tonumber(v122:match("%d+")) or 0
							table.insert(v120, v123)
							v121:Destroy()
						end
						local v124 = v_u_4.serializeFlipbook(v120)
						v109:SetAttribute("FlipbookEnabled", true)
						v109:SetAttribute("FlipbookTextures", buffer.tostring(v124))
					end
					if v109:GetAttribute("FlipbookEnabled") then
						v102[v109] = v_u_4.deserializeFlipbook(v109:GetAttribute("FlipbookTextures"))
					else
						table.insert(v101, v109)
					end
				end
			end
		end
	end
	return v101, v102, v103
end
function v_u_4.getBezierPoints(p125, p126)
	local v127 = p125:GetChildren()
	table.sort(v127, function(p128, p129)
		local v130 = p128.Name
		local v131 = tonumber(v130)
		local v132 = p129.Name
		return v131 < tonumber(v132)
	end)
	local v133 = {}
	local v134 = {}
	local v135 = {}
	for v136, v137 in v127 do
		local v138 = v137:FindFirstChild("T0")
		local v139 = v137:FindFirstChild("T1")
		if v136 == 1 then
			local v140 = p125.WorldCFrame:PointToObjectSpace(v137.WorldPosition)
			local v141 = v140.X
			local v142 = v140.Y
			local v143 = v140.Z
			local v144 = vector.create(v141, v142, v143)
			table.insert(v133, v144)
			if p126 then
				v134[v137] = v144
				table.insert(v135, v137)
			end
		end
		if v136 ~= 1 then
			if v139 then
				local v145 = p125.WorldCFrame:PointToObjectSpace(v139.WorldPosition)
				local v146 = v145.X
				local v147 = v145.Y
				local v148 = v145.Z
				local v149 = vector.create(v146, v147, v148)
				table.insert(v133, v149)
				if p126 then
					v134[v139] = v149
					table.insert(v135, v139)
				end
			else
				local v150 = p125.WorldCFrame:PointToObjectSpace(v137.WorldPosition)
				local v151 = v150.X
				local v152 = v150.Y
				local v153 = v150.Z
				local v154 = vector.create(v151, v152, v153)
				table.insert(v133, v154)
				if p126 then
					v134[v137] = v154
					table.insert(v135, v137)
				end
			end
		end
		if v136 ~= 1 and v136 ~= #v127 then
			local v155 = p125.WorldCFrame:PointToObjectSpace(v137.WorldPosition)
			local v156 = v155.X
			local v157 = v155.Y
			local v158 = v155.Z
			local v159 = vector.create(v156, v157, v158)
			table.insert(v133, v159)
			if p126 then
				v134[v137] = v159
				table.insert(v135, v137)
			end
		end
		if v136 ~= #v127 then
			if v138 then
				local v160 = p125.WorldCFrame:PointToObjectSpace(v138.WorldPosition)
				local v161 = v160.X
				local v162 = v160.Y
				local v163 = v160.Z
				local v164 = vector.create(v161, v162, v163)
				table.insert(v133, v164)
				if p126 then
					v134[v138] = v164
					table.insert(v135, v138)
				end
			else
				local v165 = p125.WorldCFrame:PointToObjectSpace(v137.WorldPosition)
				local v166 = v165.X
				local v167 = v165.Y
				local v168 = v165.Z
				local v169 = vector.create(v166, v167, v168)
				table.insert(v133, v169)
				if p126 then
					v134[v137] = v169
					table.insert(v135, v137)
				end
			end
		end
		if v136 == #v127 then
			local v170 = p125.WorldCFrame:PointToObjectSpace(v137.WorldPosition)
			local v171 = v170.X
			local v172 = v170.Y
			local v173 = v170.Z
			local v174 = vector.create(v171, v172, v173)
			table.insert(v133, v174)
			if p126 then
				v134[v137] = v174
				table.insert(v135, v137)
			end
		end
	end
	return v133, v135, v134
end
function v_u_4.scaleNumberSequence(p175, p176)
	if p176 == 1 then
		return p175
	end
	local v177 = {}
	for _, v178 in p175.Keypoints do
		local v179, v180
		if typeof(p176) == "function" then
			v179, v180 = p176(v178.Value, v178.Envelope)
		else
			v179 = v178.Value * p176
			v180 = v178.Envelope * p176
		end
		local v181 = NumberSequenceKeypoint.new
		local v182 = v178.Time
		table.insert(v177, v181(v182, v179, v180))
	end
	return NumberSequence.new(v177)
end
function v_u_4.serializePath(p183)
	local v184 = buffer.create(#p183 * 4 * 6)
	local v185 = 0
	for v186, v187 in p183 do
		local v188 = v187.Position.X.Scale
		local v189 = v187.Position.Y.Scale
		if v186 ~= 1 then
			local v190 = v188 + v187.LeftTangent.X.Scale
			buffer.writef32(v184, v185, v190)
			local v191 = v185 + 4
			local v192 = v189 + v187.LeftTangent.Y.Scale
			buffer.writef32(v184, v191, v192)
			v185 = v185 + 8
		end
		buffer.writef32(v184, v185, v188)
		local v193 = v185 + 4
		buffer.writef32(v184, v193, v189)
		v185 = v185 + 8
		if v186 ~= #p183 then
			local v194 = v188 + v187.RightTangent.X.Scale
			buffer.writef32(v184, v185, v194)
			local v195 = v185 + 4
			local v196 = v189 + v187.RightTangent.Y.Scale
			buffer.writef32(v184, v195, v196)
			v185 = v185 + 8
		end
	end
	return v184
end
function v_u_4.deserializePath(p197)
	if typeof(p197) == "string" then
		p197 = buffer.fromstring(p197) or p197
	end
	local v198 = buffer.len(p197) / 24
	local v199 = {}
	for v200 = 0, v198 - 1 do
		local v201 = v200 * 4 * 6
		local v202 = buffer.readf32(p197, v201)
		local v203 = v201 + 4
		local v204 = buffer.readf32(p197, v203)
		local v205 = vector.create(v202, v204)
		table.insert(v199, v205)
		if v200 ~= v198 - 1 then
			local v206 = v201 + 8
			local v207 = buffer.readf32(p197, v206)
			local v208 = v201 + 12
			local v209 = buffer.readf32(p197, v208)
			local v210 = v201 + 16
			local v211 = buffer.readf32(p197, v210)
			local v212 = v201 + 20
			local v213 = buffer.readf32(p197, v212)
			local v214 = vector.create(v207, v209)
			table.insert(v199, v214)
			local v215 = vector.create(v211, v213)
			table.insert(v199, v215)
		end
	end
	return v199
end
function v_u_4.serializeFlipbook(p216)
	local v217 = buffer.create(#p216 * 8)
	for v218, v219 in p216 do
		local v220 = (v218 - 1) * 8
		buffer.writef64(v217, v220, v219)
	end
	return v217
end
function v_u_4.deserializeFlipbook(p221)
	if typeof(p221) == "string" then
		p221 = buffer.fromstring(p221) or p221
	end
	local v222 = {}
	for v223 = 0, buffer.len(p221) / 8 - 1 do
		local v224 = v223 * 8
		local v225 = buffer.readf64(p221, v224)
		table.insert(v222, v225)
	end
	return v222
end
v_u_4.default_bezier = buffer.tostring(v_u_4.serializePath({ Path2DControlPoint.new(UDim2.fromScale(0, 1), UDim2.new(), UDim2.fromScale(0.215, -0.61)), Path2DControlPoint.new(UDim2.fromScale(1, 0), UDim2.fromScale(-0.645, 0), UDim2.new()) }))
v_u_4.linear_bezier = buffer.tostring(v_u_4.serializePath({ Path2DControlPoint.new(UDim2.fromScale(0, 1)), Path2DControlPoint.new(UDim2.fromScale(1, 0)) }))
return v_u_4
