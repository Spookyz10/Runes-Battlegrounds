local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local ACTIVE = {}

local Handlers = {}

function Handlers.Start(Params)
	local Solar = CharacterAssets.Eclipse.Solar.Awaken
	local ImpactAsset = Solar:FindFirstChild("CataclysmWindup")
	if not ImpactAsset then
		return
	end

	local Character = Params.char
	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.CFrame = Params.CFrame or Params.cframe

	ParticlesModule.Emit(Clone)

	if Character then
		ACTIVE[Character] = ACTIVE[Character] or {}
		table.insert(ACTIVE[Character], Clone)
	end

	Debris:AddItem(Clone, 6)
end

function Handlers.Stop(Params)
	local Character = Params.char
	if not Character then
		return
	end

	local List = ACTIVE[Character]
	if not List then
		return
	end

	for _, Clone in ipairs(List) do
		if Clone and Clone.Parent then
			Clone:Destroy()
		end
	end

	ACTIVE[Character] = nil
end

return function(Params)
	local Handler = Handlers[Params.func or "Start"]
	if Handler then
		Handler(Params)
	end
end
