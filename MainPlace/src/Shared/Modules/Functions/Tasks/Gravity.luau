local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Lunar.Awaken

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
	gravityVFX:PivotTo(CFrame.new(pos))

	table.insert(activeGravity[char], gravityVFX)
	game:GetService("Debris"):AddItem(gravityVFX, 30)
	local connection = char.AncestryChanged:Connect(function()
		if not char:IsDescendantOf(workspace) then
			gravityVFX:Destroy()
		end
	end)
	gravityVFX.Destroying:Once(function()
		connection:Disconnect()
		local list = activeGravity[char]
		local index = list and table.find(list, gravityVFX)
		if index then
			table.remove(list, index)
			if #list == 0 then
				activeGravity[char] = nil
			end
		end
	end)
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

	activeGravity[char] = nil
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
