local v_u_1 = require(script:WaitForChild("Table"))

local v_u_2 = {}
v_u_2.__index = v_u_2
v_u_2.__type = "PartCache"
local v_u_3 = CFrame.new(0, 1000000000, 0)

function v_u_2.new(p4, p5, p6)
	local v7 = p5 or 5
	local v8 = p6 or workspace
	local v9 = p5 > 0
	assert(v9, "PrecreatedParts can not be negative!")
	
	if p5 ~= 0 == false then
		warn("PrecreatedParts is 0! This may have adverse effects when initially using the cache.")
	end
	
	if p4.Archivable == false then
		warn("The template\'s Archivable property has been set to false, which prevents it from being cloned. It will temporarily be set to true.")
	end
	local v10 = p4.Archivable
	p4.Archivable = true
	local v11 = p4:Clone()
	p4.Archivable = v10
	local v12 = {
		["Open"] = {},
		["InUse"] = {},
		["CurrentCacheParent"] = v8,
		["Template"] = v11,
		["ExpansionSize"] = 10
	}
	local v13 = v_u_2
	setmetatable(v12, v13)
	for _ = 1, v7 do
		local v14 = v_u_1.insert
		local v15 = v12.Open
		local v16 = v12.CurrentCacheParent
		local v17 = v11:Clone()
		v17.CFrame = v_u_3
		v17.Anchored = true
		v17.Parent = v16
		v14(v15, v17)
	end
	v12.Template.Parent = nil
	return v12
end

function v_u_2.GetPart(p18)
	local v19 = getmetatable(p18) == v_u_2
	assert(v19, ("Cannot statically invoke method \'%s\' - It is an instance method. Call it on an instance of this class created via %s"):format("GetPart", "PartCache.new"))
	if #p18.Open == 0 then
		local v20 = warn
		local v21 = p18.ExpansionSize
		local v22 = #p18.Open + #p18.InUse + p18.ExpansionSize
		v20("No parts available in the cache! Creating [" .. v21 .. "] new part instance(s) - this amount can be edited by changing the ExpansionSize property of the PartCache instance... (This cache now contains a grand total of " .. tostring(v22) .. " parts.)")
		for _ = 1, p18.ExpansionSize do
			local v23 = v_u_1.insert
			local v24 = p18.Open
			local v25 = p18.Template
			local v26 = p18.CurrentCacheParent
			local v27 = v25:Clone()
			v27.CFrame = v_u_3
			v27.Anchored = true
			v27.Parent = v26
			v23(v24, v27)
		end
	end
	
	local v28 = p18.Open[#p18.Open]
	p18.Open[#p18.Open] = nil
	v_u_1.insert(p18.InUse, v28)
	return v28
end

function v_u_2.ReturnPart(p29, p30)
	local v31 = getmetatable(p29) == v_u_2
	assert(v31, ("Cannot statically invoke method \'%s\' - It is an instance method. Call it on an instance of this class created via %s"):format("ReturnPart", "PartCache.new"))
	local v32 = v_u_1.indexOf(p29.InUse, p30)
	if v32 == nil then
		error("Attempted to return part \"" .. p30.Name .. "\" (" .. p30:GetFullName() .. ") to the cache, but it\'s not in-use! Did you call this on the wrong part?")
	else
		v_u_1.remove(p29.InUse, v32)
		v_u_1.insert(p29.Open, p30)
		p30.CFrame = v_u_3
		p30.Anchored = true
	end
end

function v_u_2.SetCacheParent(p33, p34)
	-- upvalues: (copy) v_u_2
	local v35 = getmetatable(p33) == v_u_2
	assert(v35, ("Cannot statically invoke method \'%s\' - It is an instance method. Call it on an instance of this class created via %s"):format("SetCacheParent", "PartCache.new"))
	local v36 = p34:IsDescendantOf(workspace) or p34 == workspace
	assert(v36, "Cache parent is not a descendant of Workspace! Parts should be kept where they will remain in the visible world.")
	p33.CurrentCacheParent = p34
	for v37 = 1, #p33.Open do
		p33.Open[v37].Parent = p34
	end
	for v38 = 1, #p33.InUse do
		p33.InUse[v38].Parent = p34
	end
end

function v_u_2.Expand(p39, p40)
	-- upvalues: (copy) v_u_2, (copy) v_u_1, (copy) v_u_3
	local v41 = getmetatable(p39) == v_u_2
	assert(v41, ("Cannot statically invoke method \'%s\' - It is an instance method. Call it on an instance of this class created via %s"):format("Expand", "PartCache.new"))
	if p40 == nil then
		p40 = p39.ExpansionSize
	end
	for _ = 1, p40 do
		local v42 = v_u_1.insert
		local v43 = p39.Open
		local v44 = p39.Template
		local v45 = p39.CurrentCacheParent
		local v46 = v44:Clone()
		v46.CFrame = v_u_3
		v46.Anchored = true
		v46.Parent = v45
		v42(v43, v46)
	end
end
function v_u_2.Dispose(p47)
	-- upvalues: (copy) v_u_2
	local v48 = getmetatable(p47) == v_u_2
	assert(v48, ("Cannot statically invoke method \'%s\' - It is an instance method. Call it on an instance of this class created via %s"):format("Dispose", "PartCache.new"))
	for v49 = 1, #p47.Open do
		p47.Open[v49]:Destroy()
	end
	for v50 = 1, #p47.InUse do
		p47.InUse[v50]:Destroy()
	end
	p47.Template:Destroy()
	p47.Open = {}
	p47.InUse = {}
	p47.CurrentCacheParent = nil
	p47.GetPart = nil
	p47.ReturnPart = nil
	p47.SetCacheParent = nil
	p47.Expand = nil
	p47.Dispose = nil
end
return v_u_2
