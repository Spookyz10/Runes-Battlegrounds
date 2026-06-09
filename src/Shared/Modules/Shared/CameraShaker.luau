--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// MODULES
local ClientModules = ReplicatedStorage.Shared.Modules.Shared
local Utility = require(ClientModules.Utility)

--// TYPES
type ClassImpl = {
	__index: ClassImpl,
	ClassName: "CameraShaker",
	Once: (self: ClassImpl, name: string, radius: number?, origin: Vector3?, magnitude: number?, fadeInTime: number?, fadeOutTime: number?) -> (),
	Start: (
		self: ClassImpl,
		name: string,
		radius: number?,
		origin: Vector3?,
		duration: number?,
		magnitude: number?,
		fadeInTime: number?,
		fadeOutTime: number?
	) -> (),
	Stop: (self: ClassImpl, name: string) -> (),
}
type Class = typeof(setmetatable(
	{} :: {
		Magnitude: number,
		Roughness: number,
		FadeInDuration: number,
		FadeOutDuration: number,
		PositionInfluence: Vector3,
		RotationInfluence: Vector3,
	},
	{} :: ClassImpl
))

--// CLASS
local Class: ClassImpl = {} :: ClassImpl
Class.ClassName = "CameraShaker"
Class.__index = Class

--// CONSTANTS
local RENDER_PRIORITY = Enum.RenderPriority.Camera.Value + 1
local POSITION_INFLUENCE = Vector3.new(0.15, 0.15, 0.15)
local ROTATION_INFLUENCE = Vector3.new(1, 1, 1)

--// VARIABLES
local camera = workspace.CurrentCamera

local zeroVector = Vector3.zero

local isActive = false

local activeShakes = {}
local Module = {}

--// FUNCTIONS
local function isInactive(shake: {})
	local fadeTime = shake.FadeTime
	local sustain = shake.Sustain

	if fadeTime < 1 and sustain and shake.FadeInDuration > 0 then
		return
	elseif not sustain and fadeTime > 0 then
		return
	elseif fadeTime > 0 or sustain then
		return
	else
		return true
	end
end

local function renderStep(deltaTime: number)
	local positionAdd = zeroVector
	local rotationAdd = zeroVector
	local cameraPosition = camera.CFrame.Position

	for name, shake in pairs(activeShakes) do
		if isInactive(shake) then
			activeShakes[name] = nil
		else
			local distanceMod = 1
			local origin, radius = shake.Origin, shake.Radius
			if origin and radius then
				local distance = (origin - cameraPosition).Magnitude
				if distance > radius then
					distanceMod = 0
				else
					distanceMod -= distance / radius
				end
			end

			local shaker = shake.Shaker
			local add = shaker:UpdateShake(shake, deltaTime)
			positionAdd += add * shaker.PositionInfluence * distanceMod
			rotationAdd += add * shaker.RotationInfluence * distanceMod
		end
	end

	if isActive and Utility.IsTableEmpty(activeShakes) then
		RunService:UnbindFromRenderStep("CameraShaker")
		isActive = false
	end

	camera.CFrame *= CFrame.new(positionAdd) * CFrame.fromEulerAnglesYXZ(
		math.rad(rotationAdd.X),
		math.rad(rotationAdd.Y),
		math.rad(rotationAdd.Z)
	)
end

--// CLASS FUNCTIONS
function Class:Once(name: string, radius: number?, origin: Vector3?, magnitude: number, fadeInTime: number?, fadeOutTime: number?)
	if activeShakes[name] then
		return
	end

	local sustain = if fadeInTime and fadeInTime > 0 then true else false
	local shake = {
		Radius = radius,
		Origin = origin,
		Shaker = self,
		Tick = Random.new():NextNumber(-100, 100),
		Magnitude = magnitude,
		FadeTime = if sustain then 0 else 1,
		FadeInDuration = fadeInTime,
		FadeOutDuration = fadeOutTime,
		Sustain = sustain,
	}
	activeShakes[name] = shake

	if not isActive then
		isActive = true
		RunService:BindToRenderStep("CameraShaker", RENDER_PRIORITY, renderStep)
	end

	return shake
end

function Class:Start(
	name: string,
	radius: number?,
	origin: Vector3?,
	duration: number?,
	magnitude: number,
	fadeInTime: number?,
	fadeOutTime: number?
)
	if activeShakes[name] then
		return
	end

	local startTime = os.clock()
	local shake = {
		StartTime = startTime,
		Radius = radius,
		Origin = origin,
		Shaker = self,
		Tick = Random.new():NextNumber(-100, 100),
		Magnitude = magnitude,
		FadeTime = if fadeInTime and fadeInTime > 0 then 0 else 1,
	}
	self:StartFadeIn(shake, fadeInTime)
	activeShakes[name] = shake

	if not isActive then
		isActive = true
		RunService:BindToRenderStep("CameraShaker", RENDER_PRIORITY, renderStep)
	end

	if duration then
		local currentShake = activeShakes[name]
		if currentShake and currentShake.StartTime == startTime then
			self:Stop(name, shake, fadeOutTime)
		end
	end

	return shake
end

function Class:Stop(name: string?, shake: {}?, fadeOutTime: number?)
	shake = shake or activeShakes[name]
	if shake and shake.FadeOutDuration == 0 then
		self:StartFadeOut(shake, fadeOutTime)
	end
end

function Class:UpdateShake(shake: {}, deltaTime: number)
	local magnitude = shake.Magnitude or self.Magnitude
	local fadeTime = self:UpdateFadeTime(shake, deltaTime)
	local _tick = self:UpdateTick(shake, fadeTime, deltaTime)

	return Vector3.new(math.noise(_tick, 0) * 0.5, math.noise(0, _tick) * 0.5, math.noise(0, 0, _tick) * 0.5)
		* magnitude
		* fadeTime
end

function Class:UpdateTick(shake: {}, fadeTime: number, deltaTime: number)
	local _tick = shake.Tick
	if shake.Sustain then
		_tick += deltaTime * self.Roughness
	else
		_tick += deltaTime * self.Roughness * fadeTime
	end

	shake.Tick = _tick
	return _tick
end

function Class:UpdateFadeTime(shake: {}, deltaTime: number)
	local fadeInDuration = self.FadeInDuration
	local fadeOutDuration = self.FadeOutDuration
	local sustain = shake.Sustain

	local fadeTime = shake.FadeTime
	if fadeInDuration > 0 and sustain then
		if fadeTime < 1 then
			fadeTime += deltaTime / fadeInDuration
		elseif fadeOutDuration > 0 then
			shake.Sustain = false
		end
	end

	if not sustain and fadeOutDuration > 0 then
		fadeTime -= deltaTime / fadeOutDuration
	end

	shake.FadeTime = fadeTime
	return fadeTime
end

function Class:StartFadeIn(shake: {}, fadeInTime: number?)
	fadeInTime = fadeInTime or self.FadeInDuration
	if fadeInTime == 0 then
		shake.FadeTime = 1
	end
	shake.FadeInDuration = fadeInTime
	shake.FadeOutDuration = 0
	shake.Sustain = true
end

function Class:StartFadeOut(shake: {}, fadeOutTime: number?)
	fadeOutTime = fadeOutTime or self.FadeOutDuration
	if fadeOutTime == 0 then
		shake.FadeTime = 0
	end
	shake.FadeOutDuration = fadeOutTime
	shake.FadeInDuration = 0
	shake.Sustain = false
end

--// MODULE FUNCTIONS
function Module.new(
	magnitude: number,
	roughness: number,
	fadeInDuration: number?,
	fadeOutDuration: number?,
	posInfluence: Vector3?,
	rotInfluence: Vector3?
): Class
	return setmetatable({
		Magnitude = magnitude,
		Roughness = roughness,
		FadeInDuration = fadeInDuration or 0,
		FadeOutDuration = fadeOutDuration or 0,
		PositionInfluence = posInfluence or POSITION_INFLUENCE,
		RotationInfluence = rotInfluence or ROTATION_INFLUENCE,
	}, Class)
end

return Module
