local v_u_11 = {}


local v_u_12 = {}
local v_u_13 = {}

v_u_11.TRY_RETURN = 1
v_u_11.TRY_BREAK = 2
v_u_11.TRY_CONTINUE = 3


function v_u_11.try(p41, p42, p43)
	local v44, v45, v46 = pcall(p41)
	local v47

	if v44 then
		v47 = nil
	else
		v47 = v45
		v45 = nil
	end

	local v48 = nil
	local v49, v50, v51, v52

	if v44 or not p42 then
		v49 = v48
		v50 = v46
		v51 = v45
		v52 = true
	else
		v52, v49, v50 = pcall(p42, v47)
		if v52 then
			v51 = v49
			v49 = v48
		else
			v51 = nil
		end
		
		if not v51 then
			v50 = v46
			v51 = v45
		end
	end
	
	local v53, v54
	if p43 then
		v53, v54 = p43()
		if not v53 then
			v54 = v50
			v53 = v51
		end
	else
		v54 = v50
		v53 = v51
	end
	
	if v53 ~= v_u_11.TRY_RETURN and (v53 ~= v_u_11.TRY_BREAK and v53 ~= v_u_11.TRY_CONTINUE) then
		if not v52 then
			error(v49, 2)
		end
		if not (v44 or p42) then
			error(v47, 2)
		end
	end
	
	return v53, v54
end

return v_u_11
