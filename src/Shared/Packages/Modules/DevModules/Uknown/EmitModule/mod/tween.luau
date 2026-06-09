-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = require("./logger")
local v_u_3 = require("./utility")
local v_u_4 = require("../obj/Bezier")
return {
	["fromParams"] = function(p_u_5, p_u_6, p_u_7, p_u_8, p_u_9, p_u_10, p11)
		-- upvalues: (copy) v_u_3, (copy) v_u_2, (copy) v_u_4, (copy) v_u_1
		local v12, v13 = pcall(function()
			-- upvalues: (ref) v_u_3, (copy) p_u_5
			return v_u_3.deserializePath(p_u_5)
		end)
		if not v12 then
			v_u_2.error((("failed to decode bezier path data with error: %*"):format(v13)))
		end
		local v_u_14 = v_u_4.new(v13, 0)
		local v_u_15 = 0
		local v_u_16 = nil
		local function v27(p17)
			-- upvalues: (copy) p_u_10, (ref) v_u_15, (copy) p_u_6, (copy) v_u_14, (copy) p_u_7, (copy) p_u_8, (ref) v_u_16, (copy) p_u_9
			if not p_u_10 and v_u_15 == 0 then
				local v18 = v_u_15 + p17
				local v19 = p_u_6
				local v20 = math.max(v19, 0)
				v_u_15 = math.clamp(v18, 0, v20)
			end
			local v21 = v_u_15 / p_u_6
			local v22 = p_u_7(1 - v_u_14:getEase((math.clamp(v21, 0, 1))).y, p17, v_u_15)
			if v22 ~= nil then
				local v23
				if p_u_6 == 0 then
					v23 = p_u_6 < v_u_15
				else
					v23 = p_u_6 <= v_u_15
				end
				
				if not v23 then
					if v22 then
						local v24 = v_u_15 + v22
						local v25 = p_u_6
						local v26 = math.max(v25, 0.001)
						v_u_15 = math.clamp(v24, 0, v26)
					end
					return
				end
			end
			if not (p_u_8 and p_u_8.Connected) then
				v_u_16()
				if p_u_9 then
					p_u_9(true)
				end
				return
			end
		end
		if not p11 then
			local v_u_28 = v_u_1.RenderStepped:Connect(v27)
			v_u_16 = function()
				-- upvalues: (ref) v_u_28
				v_u_28:Disconnect()
			end
			return v_u_28
		end
		local v_u_29 = v_u_3.getRanomId()
		v_u_1:BindToRenderStep(v_u_29, p11, v27)
		local v_u_30 = true
		v_u_16 = function()
			-- upvalues: (ref) v_u_30, (ref) v_u_1, (copy) v_u_29
			if v_u_30 then
				v_u_30 = false
				v_u_1:UnbindFromRenderStep(v_u_29)
			end
		end
		return v_u_16
	end,
	["timer"] = function(p_u_31, p_u_32, p_u_33, p34, p35)
		-- upvalues: (copy) v_u_1, (copy) v_u_3
		local v_u_36 = coroutine.running()
		local v_u_37 = 0
		local v_u_38 = nil
		local function v45(p39)
			-- upvalues: (copy) p_u_32, (ref) v_u_37, (copy) p_u_31, (copy) p_u_33, (ref) v_u_38, (copy) v_u_36
			local v40 = p_u_32(p39, v_u_37)
			if v40 ~= nil then
				local v41
				if p_u_31 == 0 then
					v41 = p_u_31 < v_u_37
				else
					v41 = p_u_31 <= v_u_37
				end
				if not v41 then
					if v40 then
						local v42 = v_u_37 + v40
						local v43 = p_u_31
						local v44 = math.max(v43, 0.001)
						v_u_37 = math.clamp(v42, 0, v44)
					end
					return
				end
			end
			if not (p_u_33 and p_u_33.Connected) then
				v_u_38()
				task.spawn(v_u_36)
				return
			end
		end
		local v46
		if p35 then
			local v_u_47 = v_u_3.getRanomId()
			v_u_1:BindToRenderStep(v_u_47, p35, v45)
			local v_u_48 = true
			v_u_38 = function()
				-- upvalues: (ref) v_u_48, (ref) v_u_1, (copy) v_u_47
				if v_u_48 then
					v_u_48 = false
					v_u_1:UnbindFromRenderStep(v_u_47)
				end
			end
			v46 = v_u_38
		else
			local v_u_49 = v_u_1.RenderStepped:Connect(v45)
			v_u_38 = function()
				-- upvalues: (copy) v_u_49
				v_u_49:Disconnect()
			end
			v46 = v_u_38
		end
		if p34 then
			table.insert(p34, v46)
		end
		coroutine.yield()
	end
}
