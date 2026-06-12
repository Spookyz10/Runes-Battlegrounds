-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("../mod/utility")
local v_u_2 = {}
v_u_2.__index = v_u_2
local v_u_3 = table.create(10000)
local v_u_4 = table.create(10000)
local v_u_5 = false
local v_u_6 = coroutine.create(function()
	-- upvalues: (copy) v_u_3, (copy) v_u_4, (ref) v_u_5
	while true do
		workspace:BulkMoveTo(v_u_3, v_u_4, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(v_u_3)
		table.clear(v_u_4)
		v_u_5 = false
		coroutine.yield()
	end
end)
function v_u_2.new(p7, p8, p9)
	-- upvalues: (copy) v_u_2
	local v10 = v_u_2
	local v_u_11 = setmetatable({}, v10)
	v_u_11.ref = p7
	v_u_11.parent = p8
	v_u_11.amount = 0
	v_u_11.restore_amount = 0
	local v12 = p9 or {}
	for v13, v14 in {
		["size"] = 100,
		["excess_lifetime"] = 30
	} do
		if v12[v13] == nil then
			v12[v13] = v14
		end
	end
	v_u_11.params = v12
	v_u_11.scope = { p7, p8 }
	v_u_11.unused = table.create(v_u_11.params.size)
	v_u_11.item_map = {}
	v_u_11.part_mode = p7:IsA("BasePart")
	for _ = 1, v_u_11.params.size do
		v_u_11:_add()
	end
	local v15 = v_u_11.scope
	local v16 = task.spawn
	table.insert(v15, v16(function()
		-- upvalues: (copy) v_u_11
		while true do
			if not task.wait(15) then
				return
			end
			if v_u_11.restore_amount > 0 then
				for _ = 1, v_u_11.restore_amount do
					v_u_11:_add()
					local v17 = v_u_11
					v17.restore_amount = v17.restore_amount - 1
				end
			end
			if v_u_11.amount > v_u_11.params.size then
				local v18 = 0
				for v19 = 1, #v_u_11.unused do
					if v_u_11.amount <= v_u_11.params.size then
						break
					end
					local v20 = v19 - v18
					local v21 = v_u_11.unused[v20]
					if v21.dependents == 0 and os.clock() - v21.added <= v_u_11.params.excess_lifetime then
						v21:destroy()
						table.remove(v_u_11.unused, v20)
						v_u_11.item_map[v21.key] = nil
						local v22 = v_u_11
						v22.amount = v22.amount - 1
						v18 = v18 + 1
					end
				end
			end
		end
	end))
	return v_u_11
end
function v_u_2._add(p_u_23, p24, p25)
	local v_u_26 = p_u_23.ref:Clone()
	v_u_26.Archivable = false
	v_u_26.Parent = p_u_23.parent
	local v_u_27 = {
		["key"] = p24,
		["value"] = v_u_26,
		["added"] = os.clock(),
		["dependents"] = 1
	}
	local v_u_28 = false
	function v_u_27.destroy(_)
		-- upvalues: (ref) v_u_28, (copy) v_u_26
		v_u_28 = true
		v_u_26:Destroy()
	end
	p_u_23.amount = p_u_23.amount + 1
	v_u_26.Destroying:Connect(function()
		-- upvalues: (ref) v_u_28, (copy) p_u_23, (copy) v_u_27
		if not v_u_28 then
			local v29 = table.find(p_u_23.unused, v_u_27)
			if v29 then
				table.remove(p_u_23.unused, v29)
			end
			if v_u_27.key then
				p_u_23.item_map[v_u_27.key] = nil
			end
			local v30 = p_u_23
			v30.amount = v30.amount - 1
			local v31 = p_u_23
			v31.restore_amount = v31.restore_amount + 1
		end
	end)
	if p24 then
		p_u_23.item_map[p24] = v_u_27
	end
	if not p25 then
		local v32 = p_u_23.unused
		table.insert(v32, v_u_27)
	end
	return v_u_27
end
function v_u_2.has(p33, p34)
	return p33.item_map[p34] and true or false
end
function v_u_2.peek(p35, p36)
	return p35.item_map[p36]
end
function v_u_2.get(p37, p38)
	-- upvalues: (copy) v_u_3, (copy) v_u_4, (ref) v_u_5, (copy) v_u_6
	if p37:has(p38) then
		local v39 = p37:peek(p38)
		if v39 then
			v39.dependents = v39.dependents + 1
		end
		return v39.value
	end
	local v_u_40 = table.remove(p37.unused)
	if v_u_40 then
		v_u_40.key = p38
		v_u_40.added = os.clock()
		p37.item_map[p38] = v_u_40
	else
		v_u_40 = p37:_add(p38, true)
	end
	if not p37.part_mode then
		return v_u_40.value
	end
	local v48 = {
		["__newindex"] = function(_, p41, p42)
			-- upvalues: (ref) v_u_3, (ref) v_u_40, (ref) v_u_4, (ref) v_u_5, (ref) v_u_6
			if p41 == "CFrame" then
				local v43 = v_u_3
				local v44 = v_u_40.value
				table.insert(v43, v44)
				local v45 = v_u_4
				table.insert(v45, p42)
				if not v_u_5 then
					v_u_5 = true
					task.defer(v_u_6)
					return
				end
			else
				v_u_40.value[p41] = p42
			end
		end,
		["__index"] = function(_, p46)
			-- upvalues: (ref) v_u_40
			local v_u_47 = v_u_40.value[p46]
			return typeof(v_u_47) == "function" and function(_, ...)
				-- upvalues: (copy) v_u_47, (ref) v_u_40
				return v_u_47(v_u_40.value, ...)
			end or v_u_47
		end
	}
	return setmetatable({
		["_getReal"] = function()
			-- upvalues: (ref) v_u_40
			return v_u_40.value
		end
	}, v48)
end
function v_u_2.free(p49, p50)
	local v51 = p49.item_map[p50]
	if v51 then
		local v52 = v51.dependents - 1
		v51.dependents = math.max(v52, 0)
		if v51.dependents == 0 then
			v51.added = os.clock()
			if p49.params.on_free then
				task.spawn(p49.params.on_free, v51)
			end
			local v53 = p49.unused
			table.insert(v53, v51)
		end
	end
end
function v_u_2.destroy(p54)
	-- upvalues: (copy) v_u_1
	v_u_1.cleanupScope(p54.scope)
	for _, v55 in p54.item_map do
		v55.value:Destroy()
	end
	table.clear(p54.unused)
	table.clear(p54.item_map)
end
return v_u_2
