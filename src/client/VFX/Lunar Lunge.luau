local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LunarLungeVFX = {}

local VFXAssets = ReplicatedStorage.Assets.VFX["Lunar Lunge"]

local function emitAll(attachment)
	for _, desc in attachment:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			desc:Emit(desc:GetAttribute("EmitCount") or 1)
		end
	end
end

local activeTrail = nil

function LunarLungeVFX.dash(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local trail = VFXAssets.Trail:Clone()
	trail.Parent = root
	activeTrail = trail
end

function LunarLungeVFX.impact(character, direction)
	-- Remove trail
	if activeTrail then
		activeTrail.Parent = nil
		activeTrail = nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Emite Slash no attackerRoot
	local slash = VFXAssets.Slash:Clone()
	slash.Parent = root
	slash.CFrame = root.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = slash
	weld.Part1 = root
	weld.Parent = slash
	emitAll(slash)
	Debris:AddItem(slash, 3)
end

function LunarLungeVFX.hit(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local hit = VFXAssets.Hit:Clone()
	hit.Parent = root
	emitAll(hit)
	Debris:AddItem(hit, 3)
end

function LunarLungeVFX.blocked(character, direction)
	-- sem efeito no blocked
end

function LunarLungeVFX.handle(phase, character, ...)
	local handler = LunarLungeVFX[phase]
	if handler then
		handler(character, ...)
	else
		warn("LunarLungeVFX: fase desconhecida:", phase)
	end
end

return LunarLungeVFX
