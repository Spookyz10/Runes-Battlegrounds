local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local FADE_DURATION = 0.4

local ACTIVE = {}

local Handlers = {}

local function stopEntry(id)
	local Data = ACTIVE[id]
	if not Data then
		return
	end

	ACTIVE[id] = nil

	if Data.Connection then
		Data.Connection:Disconnect()
		Data.Connection = nil
	end

	return Data
end

function Handlers.Start(params)
	local id = params.id
	local Char = params.char
	local Offset = params.offset or CFrame.new()

	if not id or not Char then
		return
	end

	local OldData = stopEntry(id)
	if OldData and OldData.Clone and OldData.Clone.Parent then
		OldData.Clone:Destroy()
	end

	local HumRP = Char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local CircleAsset = CharacterAssets.Eclipse.Lunar:FindFirstChild("CircleVFX")
	if not CircleAsset then
		return
	end

	local Clone = CircleAsset:Clone()
	local BaseRotation = Clone:GetPivot().Rotation

	local function updatePosition()
		local TargetCFrame = HumRP.CFrame * Offset
		Clone:PivotTo(CFrame.new(TargetCFrame.Position) * BaseRotation)
	end

	updatePosition()
	Clone.Parent = workspace

	local Data = { Clone = Clone, Connection = nil }
	ACTIVE[id] = Data

	Data.Connection = RunService.RenderStepped:Connect(function()
		if not HumRP.Parent or not Char.Parent then
			if Data.Connection then
				Data.Connection:Disconnect()
				Data.Connection = nil
			end
			return
		end

		updatePosition()
	end)
end

function Handlers.Stop(params)
	local id = params.id
	if not id then
		return
	end

	local Data = stopEntry(id)
	if not Data then
		return
	end

	local Clone = Data.Clone
	if not Clone or not Clone.Parent then
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
