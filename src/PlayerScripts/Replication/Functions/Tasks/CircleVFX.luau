local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local FADE_DURATION = 0.4

local ACTIVE = {}

local Handlers = {}

function Handlers.Start(params)
	local id = params.id
	local position = params.position

	if not id or not position then
		return
	end

	if ACTIVE[id] then
		local old = ACTIVE[id]
		ACTIVE[id] = nil
		if old.Parent then
			old:Destroy()
		end
	end

	local CircleAsset = CharacterAssets.Eclipse.Lunar:FindFirstChild("CircleVFX")
	if not CircleAsset then
		return
	end

	local Clone = CircleAsset:Clone()
	local currentCFrame = Clone:GetPivot()
	Clone:PivotTo(CFrame.new(position) * currentCFrame.Rotation)
	Clone.Parent = workspace

	ACTIVE[id] = Clone
end

function Handlers.Stop(params)
	local id = params.id
	if not id then
		return
	end

	local Clone = ACTIVE[id]
	if not Clone then
		return
	end

	ACTIVE[id] = nil

	if not Clone.Parent then
		return
	end

	FadeOut.OutAndDestroy(Clone, FADE_DURATION)
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
