local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Lunar.Awaken.Gravity

local activeGravity = {}

local Handlers = {}

function Handlers.start(params)
	local char = params.char
	local pos = params.pos
	if not char or not pos then
		return
	end

	if not activeGravity[char] then
		activeGravity[char] = {}
	end

	local gravityVFX = Assets.Gravity:Clone()
	gravityVFX.Parent = workspace
	gravityVFX.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)

	table.insert(activeGravity[char], gravityVFX)
end

function Handlers.End(params)
	local char = params.char
	if not char then
		return
	end

	local list = activeGravity[char]
	if not list then
		return
	end

	for _, vfx in ipairs(list) do
		if vfx and vfx.Parent then
			vfx:Destroy()
		end
	end

	activeGravity[char] = nil
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
