local RotationController = {}

local owners = {}
local Character, HumRP, Humanoid
local hadOwner = false

function RotationController:SetCharacter(char, humRP, humanoid)
	Character = char
	HumRP = humRP
	Humanoid = humanoid
	hadOwner = false
end

function RotationController:Request(name, priority, getDirectionFn)
	owners[name] = { priority = priority, getDirection = getDirectionFn }
end

function RotationController:Release(name)
	owners[name] = nil
end

function RotationController:HasOwner(name)
	return owners[name] ~= nil
end

function RotationController:Step()
	if not Character or not HumRP or not HumRP.Parent or not Humanoid then
		return
	end

	if Character:HasTag("CantRotate") then
		hadOwner = false
		return
	end

	local best, bestPriority = nil, -math.huge
	for _, data in owners do
		if data.priority > bestPriority then
			best, bestPriority = data, data.priority
		end
	end

	if not best then
		if hadOwner then
			Humanoid.AutoRotate = true
		end
		hadOwner = false
		return
	end

	hadOwner = true
	Humanoid.AutoRotate = false

	local dir = best.getDirection()
	if dir then
		local flatDir = Vector3.new(dir.X, 0, dir.Z)
		if flatDir.Magnitude > 0.001 then
			HumRP.CFrame = CFrame.new(HumRP.Position, HumRP.Position + flatDir)
		end
	end
end

return RotationController
