local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local ACTIVE = {}

local Handlers = {}

function Handlers.Start(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local SunquakeAsset = CharacterAssets.Eclipse.Solar:FindFirstChild("Sunquake")
	if not SunquakeAsset then
		return
	end

	Handlers.Stop({ char = Character })
	local Clone = SunquakeAsset:Clone()
	Clone.Parent = workspace
	Clone.WorldPosition = HumRP.Position + Vector3.new(0, -3, 0)

	ParticlesModule.Emit(Clone)
	ACTIVE[Character] = Clone
	Debris:AddItem(Clone, 5)
	Clone.Destroying:Once(function()
		if ACTIVE[Character] == Clone then
			ACTIVE[Character] = nil
		end
	end)
end

function Handlers.Stop(Params)
	local Character = Params.char
	if not Character then
		return
	end

	local Clone = ACTIVE[Character]
	if Clone and Clone.Parent then
		Clone:Destroy()
	end
	ACTIVE[Character] = nil
end

return function(Params)
	local Handler = Handlers[Params.func or "Start"]
	if Handler then
		Handler(Params)
	end
end
