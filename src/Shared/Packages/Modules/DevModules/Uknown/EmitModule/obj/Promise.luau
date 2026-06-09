-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {
	["__mode"] = "k"
}
local function v7(p_u_2, p3)
	local v4 = {}
	for _, v5 in ipairs(p3) do
		v4[v5] = v5
	end
	return setmetatable(v4, {
		["__index"] = function(_, p6)
			-- upvalues: (copy) p_u_2
			error(string.format("%s is not in %s!", p6, p_u_2), 2)
		end,
		["__newindex"] = function()
			-- upvalues: (copy) p_u_2
			error(string.format("Creating new members in %s is not allowed!", p_u_2), 2)
		end
	})
end
local v_u_8 = {
	["Kind"] = v7("Promise.Error.Kind", {
		"ExecutionError",
		"AlreadyCancelled",
		"NotResolvedInTime",
		"TimedOut"
	})
}
v_u_8.__index = v_u_8
function v_u_8.new(p9, p10)
	-- upvalues: (ref) v_u_8
	local v11 = p9 or {}
	local v12 = {}
	local v13 = v11.error
	v12.error = tostring(v13) or "[This error has no error text.]"
	v12.trace = v11.trace
	v12.context = v11.context
	v12.kind = v11.kind
	v12.parent = p10
	v12.createdTick = os.clock()
	v12.createdTrace = debug.traceback()
	local v14 = v_u_8
	return setmetatable(v12, v14)
end
function v_u_8.is(p15)
	if type(p15) == "table" then
		local v16 = getmetatable(p15)
		if type(v16) == "table" then
			local v17
			if rawget(p15, "error") == nil then
				v17 = false
			else
				local v18 = rawget(v16, "extend")
				v17 = type(v18) == "function"
			end
			return v17
		end
	end
	return false
end
function v_u_8.isKind(p19, p20)
	-- upvalues: (ref) v_u_8
	local v21 = p20 ~= nil
	assert(v21, "Argument #2 to Promise.Error.isKind must not be nil")
	local v22 = v_u_8.is(p19)
	if v22 then
		v22 = p19.kind == p20
	end
	return v22
end
function v_u_8.extend(p23, p24)
	-- upvalues: (ref) v_u_8
	local v25 = p24 or {}
	v25.kind = v25.kind or p23.kind
	return v_u_8.new(v25, p23)
end
function v_u_8.getErrorChain(p26)
	local v27 = { p26 }
	while v27[#v27].parent do
		local v28 = v27[#v27].parent
		table.insert(v27, v28)
	end
	return v27
end
function v_u_8.__tostring(p29)
	local v30 = { string.format("-- Promise.Error(%s) --", p29.kind or "?") }
	for _, v31 in ipairs(p29:getErrorChain()) do
		local v32 = table.concat
		local v33 = { v31.trace or v31.error, v31.context }
		table.insert(v30, v32(v33, "\n"))
	end
	return table.concat(v30, "\n")
end
local function v_u_34(...)
	return select("#", ...), { ... }
end
local function v_u_36(p35, ...)
	return p35, select("#", ...), { ... }
end
local function v_u_43(p_u_37, p38, ...)
	-- upvalues: (copy) v_u_36, (ref) v_u_8
	local v39 = v_u_36
	local v40 = xpcall
	local v41 = p_u_37 ~= nil
	assert(v41, "traceback is nil")
	return v39(v40(p38, function(p42)
		-- upvalues: (ref) v_u_8, (copy) p_u_37
		if type(p42) == "table" then
			return p42
		else
			return v_u_8.new({
				["error"] = p42,
				["kind"] = v_u_8.Kind.ExecutionError,
				["trace"] = debug.traceback(tostring(p42), 2),
				["context"] = "Promise created at:\n\n" .. p_u_37
			})
		end
	end, ...))
end
local v_u_44 = {
	["Error"] = v_u_8,
	["Status"] = v7("Promise.Status", {
		"Started",
		"Resolved",
		"Rejected",
		"Cancelled"
	}),
	["_getTime"] = os.clock,
	["_timeEvent"] = game:GetService("RunService").Heartbeat,
	["_unhandledRejectionCallbacks"] = {},
	["prototype"] = {}
}
v_u_44.__index = v_u_44.prototype
function v_u_44._new(p45, p_u_46, p47)
	-- upvalues: (copy) v_u_44, (copy) v_u_1, (copy) v_u_43
	if p47 ~= nil and not v_u_44.is(p47) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end
	local v_u_48 = {
		["_thread"] = nil,
		["_source"] = p45,
		["_status"] = v_u_44.Status.Started,
		["_values"] = nil,
		["_valuesLength"] = -1,
		["_unhandledRejection"] = true,
		["_queuedResolve"] = {},
		["_queuedReject"] = {},
		["_queuedFinally"] = {},
		["_cancellationHook"] = nil,
		["_parent"] = p47
	}
	local v49 = v_u_1
	v_u_48._consumers = setmetatable({}, v49)
	if p47 and p47._status == v_u_44.Status.Started then
		p47._consumers[v_u_48] = true
	end
	local v50 = v_u_44
	setmetatable(v_u_48, v50)
	local function v_u_51(...)
		-- upvalues: (copy) v_u_48
		v_u_48:_resolve(...)
	end
	local function v_u_52(...)
		-- upvalues: (copy) v_u_48
		v_u_48:_reject(...)
	end
	local function v_u_54(p53)
		-- upvalues: (copy) v_u_48, (ref) v_u_44
		if p53 then
			if v_u_48._status == v_u_44.Status.Cancelled then
				p53()
			else
				v_u_48._cancellationHook = p53
			end
		end
		return v_u_48._status == v_u_44.Status.Cancelled
	end
	v_u_48._thread = coroutine.create(function()
		-- upvalues: (ref) v_u_43, (copy) v_u_48, (copy) p_u_46, (copy) v_u_51, (copy) v_u_52, (copy) v_u_54
		local v55, _, v56 = v_u_43(v_u_48._source, p_u_46, v_u_51, v_u_52, v_u_54)
		if not v55 then
			v_u_52(v56[1])
		end
	end)
	task.spawn(v_u_48._thread)
	return v_u_48
end
function v_u_44.new(p57)
	-- upvalues: (copy) v_u_44
	return v_u_44._new(debug.traceback(nil, 2), p57)
end
function v_u_44.__tostring(p58)
	return string.format("Promise(%s)", p58._status)
end
function v_u_44.defer(p_u_59)
	-- upvalues: (copy) v_u_44, (copy) v_u_43
	local v_u_60 = debug.traceback(nil, 2)
	return v_u_44._new(v_u_60, function(p_u_61, p_u_62, p_u_63)
		-- upvalues: (ref) v_u_43, (copy) v_u_60, (copy) p_u_59
		task.defer(function()
			-- upvalues: (ref) v_u_43, (ref) v_u_60, (ref) p_u_59, (copy) p_u_61, (copy) p_u_62, (copy) p_u_63
			local v64, _, v65 = v_u_43(v_u_60, p_u_59, p_u_61, p_u_62, p_u_63)
			if not v64 then
				p_u_62(v65[1])
			end
		end)
	end)
end
v_u_44.async = v_u_44.defer
function v_u_44.resolve(...)
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_66, v_u_67 = v_u_34(...)
	return v_u_44._new(debug.traceback(nil, 2), function(p68)
		-- upvalues: (copy) v_u_67, (copy) v_u_66
		local v69 = v_u_67
		local v70 = v_u_66
		p68(unpack(v69, 1, v70))
	end)
end
function v_u_44.reject(...)
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_71, v_u_72 = v_u_34(...)
	return v_u_44._new(debug.traceback(nil, 2), function(_, p73)
		-- upvalues: (copy) v_u_72, (copy) v_u_71
		local v74 = v_u_72
		local v75 = v_u_71
		p73(unpack(v74, 1, v75))
	end)
end
function v_u_44._try(p76, p_u_77, ...)
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_78, v_u_79 = v_u_34(...)
	return v_u_44._new(p76, function(p80)
		-- upvalues: (copy) p_u_77, (copy) v_u_79, (copy) v_u_78
		local v81 = v_u_79
		local v82 = v_u_78
		p80(p_u_77(unpack(v81, 1, v82)))
	end)
end
function v_u_44.try(p83, ...)
	-- upvalues: (copy) v_u_44
	return v_u_44._try(debug.traceback(nil, 2), p83, ...)
end
function v_u_44._all(p84, p_u_85, p_u_86)
	-- upvalues: (copy) v_u_44
	if type(p_u_85) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.all"), 3)
	end
	for v87, v88 in pairs(p_u_85) do
		if not v_u_44.is(v88) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.all", (tostring(v87))), 3)
		end
	end
	if #p_u_85 == 0 or p_u_86 == 0 then
		return v_u_44.resolve({})
	else
		return v_u_44._new(p84, function(p_u_89, p_u_90, p91)
			-- upvalues: (copy) p_u_86, (copy) p_u_85
			local v_u_92 = {}
			local v_u_93 = {}
			local v_u_94 = 0
			local v_u_95 = 0
			local v_u_96 = false
			local function v_u_99(p97, ...)
				-- upvalues: (ref) v_u_96, (ref) v_u_94, (ref) p_u_86, (copy) v_u_92, (ref) p_u_85, (copy) p_u_89, (copy) v_u_93
				if not v_u_96 then
					v_u_94 = v_u_94 + 1
					if p_u_86 == nil then
						v_u_92[p97] = ...
					else
						v_u_92[v_u_94] = ...
					end
					if v_u_94 >= (p_u_86 or #p_u_85) then
						v_u_96 = true
						p_u_89(v_u_92)
						for _, v98 in ipairs(v_u_93) do
							v98:cancel()
						end
					end
				end
			end
			p91(function()
				-- upvalues: (copy) v_u_93
				for _, v100 in ipairs(v_u_93) do
					v100:cancel()
				end
			end)
			local v_u_101 = v_u_96
			for v_u_102, v103 in ipairs(p_u_85) do
				v_u_93[v_u_102] = v103:andThen(function(...)
					-- upvalues: (copy) v_u_99, (copy) v_u_102
					v_u_99(v_u_102, ...)
				end, function(...)
					-- upvalues: (ref) v_u_95, (ref) p_u_86, (ref) p_u_85, (copy) v_u_93, (ref) v_u_101, (copy) p_u_90
					v_u_95 = v_u_95 + 1
					if p_u_86 == nil or #p_u_85 - v_u_95 < p_u_86 then
						for _, v104 in ipairs(v_u_93) do
							v104:cancel()
						end
						v_u_101 = true
						p_u_90(...)
					end
				end)
			end
			if v_u_101 then
				for _, v105 in ipairs(v_u_93) do
					v105:cancel()
				end
			end
		end)
	end
end
function v_u_44.all(p106)
	-- upvalues: (copy) v_u_44
	return v_u_44._all(debug.traceback(nil, 2), p106)
end
function v_u_44.fold(p107, p_u_108, p109)
	-- upvalues: (copy) v_u_44
	local v110 = type(p107) == "table"
	assert(v110, "Bad argument #1 to Promise.fold: must be a table")
	local v111
	if type(p_u_108) == "function" then
		v111 = true
	elseif type(p_u_108) == "table" then
		local v112 = getmetatable(p_u_108)
		if v112 then
			local v113 = rawget(v112, "__call")
			v111 = type(v113) == "function"
		else
			v111 = false
		end
	else
		v111 = false
	end
	assert(v111, "Bad argument #2 to Promise.fold: must be a function")
	local v_u_114 = v_u_44.resolve(p109)
	return v_u_44.each(p107, function(p_u_115, p_u_116)
		-- upvalues: (ref) v_u_114, (copy) p_u_108
		v_u_114 = v_u_114:andThen(function(p117)
			-- upvalues: (ref) p_u_108, (copy) p_u_115, (copy) p_u_116
			return p_u_108(p117, p_u_115, p_u_116)
		end)
	end):andThen(function()
		-- upvalues: (ref) v_u_114
		return v_u_114
	end)
end
function v_u_44.some(p118, p119)
	-- upvalues: (copy) v_u_44
	local v120 = type(p119) == "number"
	assert(v120, "Bad argument #2 to Promise.some: must be a number")
	return v_u_44._all(debug.traceback(nil, 2), p118, p119)
end
function v_u_44.any(p121)
	-- upvalues: (copy) v_u_44
	return v_u_44._all(debug.traceback(nil, 2), p121, 1):andThen(function(p122)
		return p122[1]
	end)
end
function v_u_44.allSettled(p_u_123)
	-- upvalues: (copy) v_u_44
	if type(p_u_123) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.allSettled"), 2)
	end
	for v124, v125 in pairs(p_u_123) do
		if not v_u_44.is(v125) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.allSettled", (tostring(v124))), 2)
		end
	end
	if #p_u_123 == 0 then
		return v_u_44.resolve({})
	else
		return v_u_44._new(debug.traceback(nil, 2), function(p_u_126, _, p127)
			-- upvalues: (copy) p_u_123
			local v_u_128 = {}
			local v_u_129 = {}
			local v_u_130 = 0
			local function v_u_132(p131, ...)
				-- upvalues: (ref) v_u_130, (copy) v_u_128, (ref) p_u_123, (copy) p_u_126
				v_u_130 = v_u_130 + 1
				v_u_128[p131] = ...
				if v_u_130 >= #p_u_123 then
					p_u_126(v_u_128)
				end
			end
			p127(function()
				-- upvalues: (copy) v_u_129
				for _, v133 in ipairs(v_u_129) do
					v133:cancel()
				end
			end)
			for v_u_134, v135 in ipairs(p_u_123) do
				v_u_129[v_u_134] = v135:finally(function(...)
					-- upvalues: (copy) v_u_132, (copy) v_u_134
					v_u_132(v_u_134, ...)
				end)
			end
		end)
	end
end
function v_u_44.race(p_u_136)
	-- upvalues: (copy) v_u_44
	local v137 = type(p_u_136) == "table"
	local v138 = string.format
	assert(v137, v138("Please pass a list of promises to %s", "Promise.race"))
	for v139, v140 in pairs(p_u_136) do
		local v141 = v_u_44.is(v140)
		local v142 = string.format
		local v143 = tostring(v139)
		assert(v141, v142("Non-promise value passed into %s at index %s", "Promise.race", v143))
	end
	return v_u_44._new(debug.traceback(nil, 2), function(p_u_144, p_u_145, p146)
		-- upvalues: (copy) p_u_136
		local v_u_147 = {}
		local v_u_148 = false
		if not p146(function(...)
			-- upvalues: (copy) v_u_147, (ref) v_u_148, (copy) p_u_145
			for _, v149 in ipairs(v_u_147) do
				v149:cancel()
			end
			v_u_148 = true
			return p_u_145(...)
		end) then
			local v_u_150 = v_u_148
			for v151, v152 in ipairs(p_u_136) do
				v_u_147[v151] = v152:andThen(function(...)
					-- upvalues: (copy) v_u_147, (ref) v_u_150, (copy) p_u_144
					for _, v153 in ipairs(v_u_147) do
						v153:cancel()
					end
					v_u_150 = true
					return p_u_144(...)
				end, function(...)
					-- upvalues: (copy) v_u_147, (ref) v_u_150, (copy) p_u_145
					for _, v154 in ipairs(v_u_147) do
						v154:cancel()
					end
					v_u_150 = true
					return p_u_145(...)
				end)
			end
			if v_u_150 then
				for _, v155 in ipairs(v_u_147) do
					v155:cancel()
				end
			end
		end
	end)
end
function v_u_44.each(p_u_156, p_u_157)
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v158 = type(p_u_156) == "table"
	local v159 = string.format
	assert(v158, v159("Please pass a list of promises to %s", "Promise.each"))
	local v160
	if type(p_u_157) == "function" then
		v160 = true
	elseif type(p_u_157) == "table" then
		local v161 = getmetatable(p_u_157)
		if v161 then
			local v162 = rawget(v161, "__call")
			v160 = type(v162) == "function"
		else
			v160 = false
		end
	else
		v160 = false
	end
	local v163 = string.format
	assert(v160, v163("Please pass a handler function to %s!", "Promise.each"))
	return v_u_44._new(debug.traceback(nil, 2), function(p164, p165, p166)
		-- upvalues: (copy) p_u_156, (ref) v_u_44, (ref) v_u_8, (copy) p_u_157
		local v167 = {}
		local v_u_168 = {}
		local v_u_169 = false
		p166(function()
			-- upvalues: (ref) v_u_169, (copy) v_u_168
			v_u_169 = true
			for _, v170 in ipairs(v_u_168) do
				v170:cancel()
			end
		end)
		local v171 = v_u_169
		local v172 = {}
		for v173, v174 in ipairs(p_u_156) do
			if v_u_44.is(v174) then
				if v174:getStatus() == v_u_44.Status.Cancelled then
					for _, v175 in ipairs(v_u_168) do
						v175:cancel()
					end
					return p165(v_u_8.new({
						["error"] = "Promise is cancelled",
						["kind"] = v_u_8.Kind.AlreadyCancelled,
						["context"] = string.format("The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s", v173, v174._source)
					}))
				end
				if v174:getStatus() == v_u_44.Status.Rejected then
					for _, v176 in ipairs(v_u_168) do
						v176:cancel()
					end
					return p165(select(2, v174:await()))
				end
				local v177 = v174:andThen(function(...)
					return ...
				end)
				table.insert(v_u_168, v177)
				v172[v173] = v177
			else
				v172[v173] = v174
			end
		end
		for v178, v181 in ipairs(v172) do
			if v_u_44.is(v181) then
				local v180, v181 = v181:await()
				if not v180 then
					for _, v182 in ipairs(v_u_168) do
						v182:cancel()
					end
					return p165(v181)
				end
			end
			if v171 then
				return
			end
			local v183 = v_u_44.resolve(p_u_157(v181, v178))
			table.insert(v_u_168, v183)
			local v184, v185 = v183:await()
			if not v184 then
				for _, v186 in ipairs(v_u_168) do
					v186:cancel()
				end
				return p165(v185)
			end
			v167[v178] = v185
		end
		p164(v167)
	end)
end
function v_u_44.is(p187)
	-- upvalues: (copy) v_u_44
	if type(p187) ~= "table" then
		return false
	end
	local v188 = getmetatable(p187)
	if v188 == v_u_44 then
		return true
	end
	if v188 ~= nil then
		if type(v188) == "table" then
			local v189 = rawget(v188, "__index")
			if type(v189) == "table" then
				local v190 = rawget(v188, "__index")
				local v191 = rawget(v190, "andThen")
				local v192
				if type(v191) == "function" then
					v192 = true
				else
					local v193 = type(v191) == "table" and getmetatable(v191)
					if v193 then
						local v194 = rawget(v193, "__call")
						v192 = type(v194) == "function"
					else
						v192 = false
					end
				end
				if v192 then
					return true
				end
			end
		end
		return false
	end
	local v195 = p187.andThen
	if type(v195) == "function" then
		return true
	end
	local v196 = type(v195) == "table" and getmetatable(v195)
	if v196 then
		local v197 = rawget(v196, "__call")
		if type(v197) == "function" then
			return true
		end
	end
	return false
end
function v_u_44.promisify(p_u_198)
	-- upvalues: (copy) v_u_44
	return function(...)
		-- upvalues: (ref) v_u_44, (copy) p_u_198
		return v_u_44._try(debug.traceback(nil, 2), p_u_198, ...)
	end
end
function v_u_44.delay(p_u_199)
	-- upvalues: (copy) v_u_44
	local v200 = type(p_u_199) == "number"
	assert(v200, "Bad argument #1 to Promise.delay, must be a number.")
	local v_u_201 = v_u_44._getTime()
	return v_u_44._new(debug.traceback(nil, 2), function(p_u_202)
		-- upvalues: (copy) p_u_199, (ref) v_u_44, (copy) v_u_201
		task.delay(p_u_199, function()
			-- upvalues: (copy) p_u_202, (ref) v_u_44, (ref) v_u_201
			p_u_202(v_u_44._getTime() - v_u_201)
		end)
	end)
end
local function v207(p203, p_u_204, p_u_205)
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v_u_206 = debug.traceback(nil, 2)
	return v_u_44.race({ v_u_44.delay(p_u_204):andThen(function()
			-- upvalues: (ref) v_u_44, (copy) p_u_205, (ref) v_u_8, (copy) p_u_204, (copy) v_u_206
			return v_u_44.reject(p_u_205 == nil and v_u_8.new({
				["kind"] = v_u_8.Kind.TimedOut,
				["error"] = "Timed out",
				["context"] = string.format("Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s", p_u_204, v_u_206)
			}) or p_u_205)
		end), p203 })
end
v_u_44.prototype.timeout = v207
function v_u_44.prototype.getStatus(p208)
	return p208._status
end
function v_u_44.prototype._andThen(p_u_209, p_u_210, p_u_211, p_u_212)
	-- upvalues: (copy) v_u_44, (copy) v_u_43
	p_u_209._unhandledRejection = false
	if p_u_209._status ~= v_u_44.Status.Cancelled then
		return v_u_44._new(p_u_210, function(p_u_213, p_u_214, p215)
			-- upvalues: (copy) p_u_211, (copy) p_u_210, (ref) v_u_43, (copy) p_u_212, (copy) p_u_209, (ref) v_u_44
			local v_u_216
			if p_u_211 then
				local v_u_217 = p_u_210
				local v_u_218 = p_u_211
				v_u_216 = function(...)
					-- upvalues: (ref) v_u_43, (copy) v_u_217, (copy) v_u_218, (copy) p_u_213, (copy) p_u_214
					local v219, v220, v221 = v_u_43(v_u_217, v_u_218, ...)
					if v219 then
						p_u_213(unpack(v221, 1, v220))
					else
						p_u_214(v221[1])
					end
				end
			else
				v_u_216 = p_u_213
			end
			if p_u_212 then
				local v_u_222 = p_u_210
				local v_u_223 = p_u_212
				p_u_214 = function(...)
					-- upvalues: (ref) v_u_43, (copy) v_u_222, (copy) v_u_223, (copy) p_u_213, (copy) p_u_214
					local v224, v225, v226 = v_u_43(v_u_222, v_u_223, ...)
					if v224 then
						p_u_213(unpack(v226, 1, v225))
					else
						p_u_214(v226[1])
					end
				end
			end
			if p_u_209._status == v_u_44.Status.Started then
				local v227 = p_u_209._queuedResolve
				table.insert(v227, v_u_216)
				local v228 = p_u_209._queuedReject
				table.insert(v228, p_u_214)
				p215(function()
					-- upvalues: (ref) p_u_209, (ref) v_u_44, (ref) v_u_216, (ref) p_u_214
					if p_u_209._status == v_u_44.Status.Started then
						table.remove(p_u_209._queuedResolve, table.find(p_u_209._queuedResolve, v_u_216))
						table.remove(p_u_209._queuedReject, table.find(p_u_209._queuedReject, p_u_214))
					end
				end)
			elseif p_u_209._status == v_u_44.Status.Resolved then
				local v229 = p_u_209._values
				local v230 = p_u_209._valuesLength
				v_u_216(unpack(v229, 1, v230))
			elseif p_u_209._status == v_u_44.Status.Rejected then
				local v231 = p_u_209._values
				local v232 = p_u_209._valuesLength
				p_u_214(unpack(v231, 1, v232))
			end
		end, p_u_209)
	end
	local v233 = v_u_44.new(function() end)
	v233:cancel()
	return v233
end
function v_u_44.prototype.andThen(p234, p235, p236)
	local v237
	if p235 == nil or type(p235) == "function" then
		v237 = true
	elseif type(p235) == "table" then
		local v238 = getmetatable(p235)
		if v238 then
			local v239 = rawget(v238, "__call")
			v237 = type(v239) == "function"
		else
			v237 = false
		end
	else
		v237 = false
	end
	local v240 = string.format
	assert(v237, v240("Please pass a handler function to %s!", "Promise:andThen"))
	local v241
	if p236 == nil or type(p236) == "function" then
		v241 = true
	elseif type(p236) == "table" then
		local v242 = getmetatable(p236)
		if v242 then
			local v243 = rawget(v242, "__call")
			v241 = type(v243) == "function"
		else
			v241 = false
		end
	else
		v241 = false
	end
	local v244 = string.format
	assert(v241, v244("Please pass a handler function to %s!", "Promise:andThen"))
	return p234:_andThen(debug.traceback(nil, 2), p235, p236)
end
function v_u_44.prototype.catch(p245, p246)
	local v247
	if p246 == nil or type(p246) == "function" then
		v247 = true
	elseif type(p246) == "table" then
		local v248 = getmetatable(p246)
		if v248 then
			local v249 = rawget(v248, "__call")
			v247 = type(v249) == "function"
		else
			v247 = false
		end
	else
		v247 = false
	end
	local v250 = string.format
	assert(v247, v250("Please pass a handler function to %s!", "Promise:catch"))
	return p245:_andThen(debug.traceback(nil, 2), nil, p246)
end
function v_u_44.prototype.tap(p251, p_u_252)
	-- upvalues: (copy) v_u_44, (copy) v_u_34
	local v253
	if type(p_u_252) == "function" then
		v253 = true
	elseif type(p_u_252) == "table" then
		local v254 = getmetatable(p_u_252)
		if v254 then
			local v255 = rawget(v254, "__call")
			v253 = type(v255) == "function"
		else
			v253 = false
		end
	else
		v253 = false
	end
	local v256 = string.format
	assert(v253, v256("Please pass a handler function to %s!", "Promise:tap"))
	return p251:_andThen(debug.traceback(nil, 2), function(...)
		-- upvalues: (copy) p_u_252, (ref) v_u_44, (ref) v_u_34
		local v257 = p_u_252(...)
		if not v_u_44.is(v257) then
			return ...
		end
		local v_u_258, v_u_259 = v_u_34(...)
		return v257:andThen(function()
			-- upvalues: (copy) v_u_259, (copy) v_u_258
			local v260 = v_u_259
			local v261 = v_u_258
			return unpack(v260, 1, v261)
		end)
	end)
end
function v_u_44.prototype.andThenCall(p262, p_u_263, ...)
	-- upvalues: (copy) v_u_34
	local v264
	if type(p_u_263) == "function" then
		v264 = true
	elseif type(p_u_263) == "table" then
		local v265 = getmetatable(p_u_263)
		if v265 then
			local v266 = rawget(v265, "__call")
			v264 = type(v266) == "function"
		else
			v264 = false
		end
	else
		v264 = false
	end
	local v267 = string.format
	assert(v264, v267("Please pass a handler function to %s!", "Promise:andThenCall"))
	local v_u_268, v_u_269 = v_u_34(...)
	return p262:_andThen(debug.traceback(nil, 2), function()
		-- upvalues: (copy) p_u_263, (copy) v_u_269, (copy) v_u_268
		local v270 = v_u_269
		local v271 = v_u_268
		return p_u_263(unpack(v270, 1, v271))
	end)
end
function v_u_44.prototype.andThenReturn(p272, ...)
	-- upvalues: (copy) v_u_34
	local v_u_273, v_u_274 = v_u_34(...)
	return p272:_andThen(debug.traceback(nil, 2), function()
		-- upvalues: (copy) v_u_274, (copy) v_u_273
		local v275 = v_u_274
		local v276 = v_u_273
		return unpack(v275, 1, v276)
	end)
end
function v_u_44.prototype.cancel(p277)
	-- upvalues: (copy) v_u_44
	if p277._status == v_u_44.Status.Started then
		p277._status = v_u_44.Status.Cancelled
		if p277._cancellationHook then
			p277._cancellationHook()
		end
		coroutine.close(p277._thread)
		if p277._parent then
			p277._parent:_consumerCancelled(p277)
		end
		for v278 in pairs(p277._consumers) do
			v278:cancel()
		end
		p277:_finalize()
	end
end
function v_u_44.prototype._consumerCancelled(p279, p280)
	-- upvalues: (copy) v_u_44
	if p279._status == v_u_44.Status.Started then
		p279._consumers[p280] = nil
		if next(p279._consumers) == nil then
			p279:cancel()
		end
	end
end
function v_u_44.prototype._finally(p_u_281, p_u_282, p_u_283)
	-- upvalues: (copy) v_u_44, (copy) v_u_43
	p_u_281._unhandledRejection = false
	return v_u_44._new(p_u_282, function(p_u_284, p_u_285, p286)
		-- upvalues: (copy) p_u_281, (copy) p_u_283, (ref) v_u_43, (copy) p_u_282, (ref) v_u_44
		local v_u_287 = nil
		p286(function()
			-- upvalues: (ref) p_u_281, (ref) v_u_287
			p_u_281:_consumerCancelled(p_u_281)
			if v_u_287 then
				v_u_287:cancel()
			end
		end)
		local v292 = p_u_283 and function(...)
			-- upvalues: (ref) v_u_43, (ref) p_u_282, (ref) p_u_283, (copy) p_u_285, (ref) v_u_44, (ref) v_u_287, (copy) p_u_284, (ref) p_u_281
			local v288, _, v289 = v_u_43(p_u_282, p_u_283, ...)
			local v290 = v289[1]
			if v288 then
				if v_u_44.is(v290) then
					v_u_287 = v290
					v290:finally(function(p291)
						-- upvalues: (ref) v_u_44, (ref) p_u_284, (ref) p_u_281
						if p291 ~= v_u_44.Status.Rejected then
							p_u_284(p_u_281)
						end
					end):catch(function(...)
						-- upvalues: (ref) p_u_285
						p_u_285(...)
					end)
				else
					p_u_284(p_u_281)
				end
			else
				return p_u_285(v290)
			end
		end or p_u_284
		if p_u_281._status == v_u_44.Status.Started then
			local v293 = p_u_281._queuedFinally
			table.insert(v293, v292)
		else
			v292(p_u_281._status)
		end
	end)
end
function v_u_44.prototype.finally(p294, p295)
	local v296
	if p295 == nil or type(p295) == "function" then
		v296 = true
	elseif type(p295) == "table" then
		local v297 = getmetatable(p295)
		if v297 then
			local v298 = rawget(v297, "__call")
			v296 = type(v298) == "function"
		else
			v296 = false
		end
	else
		v296 = false
	end
	local v299 = string.format
	assert(v296, v299("Please pass a handler function to %s!", "Promise:finally"))
	return p294:_finally(debug.traceback(nil, 2), p295)
end
function v_u_44.prototype.finallyCall(p300, p_u_301, ...)
	-- upvalues: (copy) v_u_34
	local v302
	if type(p_u_301) == "function" then
		v302 = true
	elseif type(p_u_301) == "table" then
		local v303 = getmetatable(p_u_301)
		if v303 then
			local v304 = rawget(v303, "__call")
			v302 = type(v304) == "function"
		else
			v302 = false
		end
	else
		v302 = false
	end
	local v305 = string.format
	assert(v302, v305("Please pass a handler function to %s!", "Promise:finallyCall"))
	local v_u_306, v_u_307 = v_u_34(...)
	return p300:_finally(debug.traceback(nil, 2), function()
		-- upvalues: (copy) p_u_301, (copy) v_u_307, (copy) v_u_306
		local v308 = v_u_307
		local v309 = v_u_306
		return p_u_301(unpack(v308, 1, v309))
	end)
end
function v_u_44.prototype.finallyReturn(p310, ...)
	-- upvalues: (copy) v_u_34
	local v_u_311, v_u_312 = v_u_34(...)
	return p310:_finally(debug.traceback(nil, 2), function()
		-- upvalues: (copy) v_u_312, (copy) v_u_311
		local v313 = v_u_312
		local v314 = v_u_311
		return unpack(v313, 1, v314)
	end)
end
function v_u_44.prototype.awaitStatus(p315)
	-- upvalues: (copy) v_u_44
	p315._unhandledRejection = false
	if p315._status == v_u_44.Status.Started then
		local v_u_316 = coroutine.running()
		p315:finally(function()
			-- upvalues: (copy) v_u_316
			task.spawn(v_u_316)
		end):catch(function() end)
		coroutine.yield()
	end
	if p315._status == v_u_44.Status.Resolved then
		local v317 = p315._status
		local v318 = p315._values
		local v319 = p315._valuesLength
		return v317, unpack(v318, 1, v319)
	end
	if p315._status ~= v_u_44.Status.Rejected then
		return p315._status
	end
	local v320 = p315._status
	local v321 = p315._values
	local v322 = p315._valuesLength
	return v320, unpack(v321, 1, v322)
end
local function v_u_324(p323, ...)
	-- upvalues: (copy) v_u_44
	return p323 == v_u_44.Status.Resolved, ...
end
function v_u_44.prototype.await(p325)
	-- upvalues: (copy) v_u_324
	return v_u_324(p325:awaitStatus())
end
local function v_u_327(p326, ...)
	-- upvalues: (copy) v_u_44
	if p326 ~= v_u_44.Status.Resolved then
		error(... == nil and "Expected Promise rejected with no value." or ..., 3)
	end
	return ...
end
function v_u_44.prototype.expect(p328)
	-- upvalues: (copy) v_u_327
	return v_u_327(p328:awaitStatus())
end
v_u_44.prototype.awaitValue = v_u_44.prototype.expect
function v_u_44.prototype._unwrap(p329)
	-- upvalues: (copy) v_u_44
	if p329._status == v_u_44.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end
	local v330 = p329._status == v_u_44.Status.Resolved
	local v331 = p329._values
	local v332 = p329._valuesLength
	return v330, unpack(v331, 1, v332)
end
local function v341(p_u_333, ...)
	-- upvalues: (copy) v_u_44, (ref) v_u_8, (copy) v_u_34
	if p_u_333._status == v_u_44.Status.Started then
		if v_u_44.is((...)) then
			if select("#", ...) > 1 then
				local v334 = string.format("When returning a Promise from andThen, extra arguments are discarded! See:\n\n%s", p_u_333._source)
				warn(v334)
			end
			local v_u_335 = ...
			local v337 = v_u_335:andThen(function(...)
				-- upvalues: (copy) p_u_333
				p_u_333:_resolve(...)
			end, function(...)
				-- upvalues: (copy) v_u_335, (ref) v_u_8, (copy) p_u_333
				local v336 = v_u_335._values[1]
				if v_u_335._error then
					v336 = v_u_8.new({
						["error"] = v_u_335._error,
						["kind"] = v_u_8.Kind.ExecutionError,
						["context"] = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]"
					})
				end
				if v_u_8.isKind(v336, v_u_8.Kind.ExecutionError) then
					return p_u_333:_reject(v336:extend({
						["error"] = "This Promise was chained to a Promise that errored.",
						["trace"] = "",
						["context"] = string.format("The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n", p_u_333._source)
					}))
				end
				p_u_333:_reject(...)
			end)
			if v337._status == v_u_44.Status.Cancelled then
				p_u_333:cancel()
			elseif v337._status == v_u_44.Status.Started then
				p_u_333._parent = v337
				v337._consumers[p_u_333] = true
			end
		else
			p_u_333._status = v_u_44.Status.Resolved
			local v338, v339 = v_u_34(...)
			p_u_333._valuesLength = v338
			p_u_333._values = v339
			for _, v340 in ipairs(p_u_333._queuedResolve) do
				coroutine.wrap(v340)(...)
			end
			p_u_333:_finalize()
			return
		end
	else
		if v_u_44.is((...)) then
			(...):_consumerCancelled(p_u_333)
		end
		return
	end
end
v_u_44.prototype._resolve = v341
function v_u_44.prototype._reject(p_u_342, ...)
	-- upvalues: (copy) v_u_44, (copy) v_u_34
	if p_u_342._status == v_u_44.Status.Started then
		p_u_342._status = v_u_44.Status.Rejected
		local v343, v344 = v_u_34(...)
		p_u_342._valuesLength = v343
		p_u_342._values = v344
		local v345 = p_u_342._queuedReject
		if next(v345) == nil then
			local v_u_346 = tostring((...))
			coroutine.wrap(function()
				-- upvalues: (ref) v_u_44, (copy) p_u_342, (copy) v_u_346
				v_u_44._timeEvent:Wait()
				if p_u_342._unhandledRejection then
					local v347 = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", v_u_346, p_u_342._source)
					for _, v348 in ipairs(v_u_44._unhandledRejectionCallbacks) do
						local v349 = task.spawn
						local v350 = p_u_342
						local v351 = p_u_342._values
						local v352 = p_u_342._valuesLength
						v349(v348, v350, unpack(v351, 1, v352))
					end
					if not v_u_44.TEST then
						warn(v347)
					end
				else
					return
				end
			end)()
		else
			for _, v353 in ipairs(p_u_342._queuedReject) do
				coroutine.wrap(v353)(...)
			end
		end
		p_u_342:_finalize()
	end
end
function v_u_44.prototype._finalize(p354)
	-- upvalues: (copy) v_u_44
	for _, v355 in ipairs(p354._queuedFinally) do
		coroutine.wrap(v355)(p354._status)
	end
	p354._queuedFinally = nil
	p354._queuedReject = nil
	p354._queuedResolve = nil
	if not v_u_44.TEST then
		p354._parent = nil
		p354._consumers = nil
	end
	task.defer(coroutine.close, p354._thread)
end
local function v360(p356, p357)
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v358 = debug.traceback(nil, 2)
	if p356._status == v_u_44.Status.Resolved then
		return p356:_andThen(v358, function(...)
			return ...
		end)
	end
	local v359 = v_u_44.reject
	if p357 == nil then
		p357 = v_u_8.new({
			["kind"] = v_u_8.Kind.NotResolvedInTime,
			["error"] = "This Promise was not resolved in time for :now()",
			["context"] = ":now() was called at:\n\n" .. v358
		}) or p357
	end
	return v359(p357)
end
v_u_44.prototype.now = v360
function v_u_44.retry(p_u_361, p_u_362, ...)
	-- upvalues: (copy) v_u_44
	local v363
	if type(p_u_361) == "function" then
		v363 = true
	elseif type(p_u_361) == "table" then
		local v364 = getmetatable(p_u_361)
		if v364 then
			local v365 = rawget(v364, "__call")
			v363 = type(v365) == "function"
		else
			v363 = false
		end
	else
		v363 = false
	end
	assert(v363, "Parameter #1 to Promise.retry must be a function")
	local v366 = type(p_u_362) == "number"
	assert(v366, "Parameter #2 to Promise.retry must be a number")
	local v_u_367 = { ... }
	local v_u_368 = select("#", ...)
	return v_u_44.resolve(p_u_361(...)):catch(function(...)
		-- upvalues: (copy) p_u_362, (ref) v_u_44, (copy) p_u_361, (copy) v_u_367, (copy) v_u_368
		if p_u_362 <= 0 then
			return v_u_44.reject(...)
		end
		local v369 = v_u_367
		local v370 = v_u_368
		return v_u_44.retry(p_u_361, p_u_362 - 1, unpack(v369, 1, v370))
	end)
end
function v_u_44.retryWithDelay(p_u_371, p_u_372, p_u_373, ...)
	-- upvalues: (copy) v_u_44
	local v374
	if type(p_u_371) == "function" then
		v374 = true
	elseif type(p_u_371) == "table" then
		local v375 = getmetatable(p_u_371)
		if v375 then
			local v376 = rawget(v375, "__call")
			v374 = type(v376) == "function"
		else
			v374 = false
		end
	else
		v374 = false
	end
	assert(v374, "Parameter #1 to Promise.retry must be a function")
	local v377 = type(p_u_372) == "number"
	assert(v377, "Parameter #2 (times) to Promise.retry must be a number")
	local v378 = type(p_u_373) == "number"
	assert(v378, "Parameter #3 (seconds) to Promise.retry must be a number")
	local v_u_379 = { ... }
	local v_u_380 = select("#", ...)
	return v_u_44.resolve(p_u_371(...)):catch(function(...)
		-- upvalues: (copy) p_u_372, (ref) v_u_44, (copy) p_u_373, (copy) p_u_371, (copy) v_u_379, (copy) v_u_380
		if p_u_372 <= 0 then
			return v_u_44.reject(...)
		end
		v_u_44.delay(p_u_373):await()
		local v381 = v_u_379
		local v382 = v_u_380
		return v_u_44.retryWithDelay(p_u_371, p_u_372 - 1, p_u_373, unpack(v381, 1, v382))
	end)
end
function v_u_44.fromEvent(p_u_383, p384)
	-- upvalues: (copy) v_u_44
	local v_u_385 = p384 or function()
		return true
	end
	return v_u_44._new(debug.traceback(nil, 2), function(p_u_386, _, p387)
		-- upvalues: (copy) p_u_383, (ref) v_u_385
		local v_u_388 = nil
		local v_u_389 = false
		local function v390()
			-- upvalues: (ref) v_u_388
			v_u_388:Disconnect()
			v_u_388 = nil
		end
		v_u_388 = p_u_383:Connect(function(...)
			-- upvalues: (ref) v_u_385, (copy) p_u_386, (ref) v_u_388, (ref) v_u_389
			local v391 = v_u_385(...)
			if v391 == true then
				p_u_386(...)
				if v_u_388 then
					v_u_388:Disconnect()
					v_u_388 = nil
				else
					v_u_389 = true
				end
			else
				if type(v391) ~= "boolean" then
					error("Promise.fromEvent predicate should always return a boolean")
				end
				return
			end
		end)
		if v_u_389 and v_u_388 then
			return v390()
		end
		p387(v390)
	end)
end
function v_u_44.onUnhandledRejection(p_u_392)
	-- upvalues: (copy) v_u_44
	local v393 = v_u_44._unhandledRejectionCallbacks
	table.insert(v393, p_u_392)
	return function()
		-- upvalues: (ref) v_u_44, (copy) p_u_392
		local v394 = table.find(v_u_44._unhandledRejectionCallbacks, p_u_392)
		if v394 then
			table.remove(v_u_44._unhandledRejectionCallbacks, v394)
		end
	end
end
return v_u_44
