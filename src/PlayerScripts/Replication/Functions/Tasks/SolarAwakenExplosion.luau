local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local FADE_DURATION = 1.2

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

	local ExplosionAsset = CharacterAssets.Eclipse.Solar.Awaken:FindFirstChild("Explosion")
	if not ExplosionAsset then
		return
	end

	local ExplosionClone = ExplosionAsset:Clone()
	local currentCFrame = ExplosionClone:GetPivot()
	ExplosionClone:PivotTo(CFrame.new(position) * currentCFrame.Rotation)
	ExplosionClone.Parent = workspace

	ACTIVE[id] = ExplosionClone
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
	Debris:AddItem(Clone, FADE_DURATION + 1)
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
