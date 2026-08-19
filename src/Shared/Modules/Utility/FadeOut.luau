local RunService = game:GetService("RunService")

local FadeOut = {}

local function collectLeaves(instance)
	local leaves = {}

	local function push(inst)
		if inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
			table.insert(leaves, inst)
		elseif inst:IsA("BasePart") then
			table.insert(leaves, inst)
		end
	end

	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("BasePart") then
		push(instance)
	end

	for _, desc in instance:GetDescendants() do
		push(desc)
	end

	return leaves
end

local function snapshotOriginal(leaf)
	if leaf:GetAttribute("__FadeSnapshotDone") then
		return
	end
	leaf:SetAttribute("__FadeSnapshotDone", true)

	if leaf:IsA("ParticleEmitter") then
		local ks = leaf.Transparency.Keypoints
		local packed = {}
		for i, kp in ks do
			packed[i] = { Time = kp.Time, Value = kp.Value }
		end

		local serial = ""
		for i, kp in packed do
			serial = serial .. kp.Time .. "," .. kp.Value
			if i < #packed then
				serial = serial .. ";"
			end
		end
		leaf:SetAttribute("__OrigTransparency", serial)
		leaf:SetAttribute("__OrigBrightness", leaf.LightEmission)
	elseif leaf:IsA("Beam") then
		local ks = leaf.Transparency.Keypoints
		local packed = {}
		for i, kp in ks do
			packed[i] = { Time = kp.Time, Value = kp.Value }
		end
		local serial = ""
		for i, kp in packed do
			serial = serial .. kp.Time .. "," .. kp.Value
			if i < #packed then
				serial = serial .. ";"
			end
		end
		leaf:SetAttribute("__OrigTransparency", serial)
	elseif leaf:IsA("Trail") then
		leaf:SetAttribute("__OrigTransparency", leaf.Transparency)
	elseif leaf:IsA("BasePart") then
		leaf:SetAttribute("__OrigTransparency", leaf.Transparency)
	end

	leaf:SetAttribute("__FadeAlpha", 1)
end

local function deserializeKps(serial)
	local kps = {}
	for chunk in serial:gmatch("[^;]+") do
		local t, v = chunk:match("([^,]+),([^,]+)")
		table.insert(kps, { Time = tonumber(t), Value = tonumber(v) })
	end
	return kps
end

local function applyAlpha(leaf, alpha)
	leaf:SetAttribute("__FadeAlpha", alpha)

	if leaf:IsA("ParticleEmitter") then
		local serial = leaf:GetAttribute("__OrigTransparency")
		if not serial then
			return
		end
		local origKps = deserializeKps(serial)

		local newKps = {}
		for _, kp in origKps do
			local newVal = kp.Value + (1 - kp.Value) * (1 - alpha)
			table.insert(newKps, NumberSequenceKeypoint.new(kp.Time, newVal))
		end
		leaf.Transparency = NumberSequence.new(newKps)

		local origBrightness = leaf:GetAttribute("__OrigBrightness") or leaf.LightEmission
		leaf.LightEmission = origBrightness * alpha
	elseif leaf:IsA("Beam") then
		local serial = leaf:GetAttribute("__OrigTransparency")
		if not serial then
			return
		end
		local origKps = deserializeKps(serial)

		local newKps = {}
		for _, kp in origKps do
			local newVal = kp.Value + (1 - kp.Value) * (1 - alpha)
			table.insert(newKps, NumberSequenceKeypoint.new(kp.Time, newVal))
		end
		leaf.Transparency = NumberSequence.new(newKps)
	elseif leaf:IsA("Trail") then
		local origT = leaf:GetAttribute("__OrigTransparency")
		if origT == nil then
			return
		end
		leaf.Transparency = origT + (1 - origT) * (1 - alpha)
	elseif leaf:IsA("BasePart") then
		local origT = leaf:GetAttribute("__OrigTransparency")
		if origT == nil then
			return
		end

		leaf.Transparency = origT + (1 - origT) * (1 - alpha)
	end
end

local function animateFadeWithTokens(leaves, fromAlpha, toAlpha, duration, callback)
	if duration <= 0 then
		for _, leaf in leaves do
			snapshotOriginal(leaf)
			applyAlpha(leaf, toAlpha)
		end
		if callback then
			callback()
		end
		return
	end

	local myTokens = {}
	for _, leaf in leaves do
		snapshotOriginal(leaf)
		local newToken = (leaf:GetAttribute("__FadeToken") or 0) + 1
		leaf:SetAttribute("__FadeToken", newToken)
		myTokens[leaf] = newToken
	end

	local startTime = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		local t = math.clamp(elapsed / duration, 0, 1)
		local alpha = fromAlpha + (toAlpha - fromAlpha) * t

		for _, leaf in leaves do
			if not leaf or not leaf.Parent then
				continue
			end

			if leaf:GetAttribute("__FadeToken") ~= myTokens[leaf] then
				continue
			end
			applyAlpha(leaf, alpha)
		end

		if t >= 1 then
			conn:Disconnect()
			if callback then
				callback()
			end
		end
	end)
end

function FadeOut.Out(target, duration, callback)
	assert(typeof(target) == "Instance", "[FadeOut] target deve ser uma Instance")
	duration = duration or 0.5

	local leaves = collectLeaves(target)
	if #leaves == 0 then
		if callback then
			callback()
		end
		return
	end

	local fromAlpha = 1
	if leaves[1]:GetAttribute("__FadeAlpha") ~= nil then
		fromAlpha = leaves[1]:GetAttribute("__FadeAlpha")
	end

	animateFadeWithTokens(leaves, fromAlpha, 0, duration, callback)
end

function FadeOut.In(target, duration, callback)
	assert(typeof(target) == "Instance", "[FadeOut] target deve ser uma Instance")
	duration = duration or 0.5

	local leaves = collectLeaves(target)
	if #leaves == 0 then
		if callback then
			callback()
		end
		return
	end

	local fromAlpha = 0
	if leaves[1]:GetAttribute("__FadeAlpha") ~= nil then
		fromAlpha = leaves[1]:GetAttribute("__FadeAlpha")
	end

	animateFadeWithTokens(leaves, fromAlpha, 1, duration, callback)
end

function FadeOut.OutAndDestroy(target, fadeDuration, destroyDelay)
	print("[FadeOut] OutAndDestroy chamado para", target:GetFullName())
	destroyDelay = destroyDelay or 0
	FadeOut.Out(target, fadeDuration, function()
		if destroyDelay > 0 then
			task.delay(destroyDelay, function()
				if target and target.Parent then
					target:Destroy()
				end
			end)
		else
			if target and target.Parent then
				target:Destroy()
			end
		end
	end)
end

return FadeOut
