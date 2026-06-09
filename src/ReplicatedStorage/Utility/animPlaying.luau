
local module_upvr = {
	animTable = {};
}
function module_upvr.Load(arg1, arg2, arg3, arg4, arg5, arg6, arg7,var4) -- Line 8
	--[[ Upvalues[1]:
		[1]: module_upvr (readonly)
	]]
	if arg3 == nil then
	else
		if arg2 == nil then return end
		local class_Humanoid = arg2:FindFirstChildOfClass("Humanoid")
		if class_Humanoid == nil then
			local class_AnimationController = arg2:FindFirstChildOfClass("AnimationController")
			if class_AnimationController then
				class_Humanoid = class_AnimationController
			else
				do
					return
				end
			
			end
		end
		if class_Humanoid then
			if not module_upvr.animTable[arg2] then
				module_upvr.animTable[arg2] = {}
			end
			local var5_upvw
			if not class_Humanoid:FindFirstChildOfClass("Animator") then
				var5_upvw = Instance.new("Animator", class_Humanoid)
			else
				var5_upvw = class_Humanoid:FindFirstChildOfClass("Animator")
			end
			local any_LoadAnimation_result1 = var5_upvw:LoadAnimation(arg3)
			module_upvr.animTable[arg2][arg3.Name] = any_LoadAnimation_result1
			local Action = Enum.AnimationPriority.Action
			if arg5 == nil then
				Action = any_LoadAnimation_result1.Priority or Action
			else
				Action = arg5
			end
			if var4 == nil then
				var4 = any_LoadAnimation_result1.Looped
			end
			any_LoadAnimation_result1.Looped = var4
			any_LoadAnimation_result1.Priority = Action
			any_LoadAnimation_result1:AdjustSpeed(arg7 or 1)
			any_LoadAnimation_result1.Stopped:Once(function() -- Line 52
				--[[ Upvalues[4]:
					[1]: var5_upvw (read and write)
					[2]: arg3 (readonly)
					[3]: module_upvr (copied, readonly)
					[4]: arg2 (readonly)
				]]
				for _, v in ipairs(var5_upvw:GetPlayingAnimationTracks()) do
					if v.Animation and v.Animation.AnimationId == arg3.AnimationId then
						if module_upvr.animTable[arg2][v.Name] then
							module_upvr.animTable[arg2][v.Name]:Destroy()
							module_upvr.animTable[arg2][v.Name] = nil
						end
						v:Destroy()
						v = nil
					end
				end
			end)
			return any_LoadAnimation_result1
		end
	end
end
function module_upvr.loadAnimation(arg1, arg2, arg3, arg4, arg5, arg6, arg7) -- Line 72
	--[[ Upvalues[1]:
		[1]: module_upvr (readonly)
	]]
	local any_Load_result1 = module_upvr:Load(arg2, arg3, arg4, arg5, arg6, arg7)
	if not any_Load_result1 then return end
	return any_Load_result1
end
function module_upvr.getAnimations(arg1, arg2) -- Line 78
	--[[ Upvalues[1]:
		[1]: module_upvr (readonly)
	]]
	if not module_upvr.animTable[arg2] then
		module_upvr.animTable[arg2] = {}
	end
	return module_upvr.animTable[arg2]
end
return module_upvr