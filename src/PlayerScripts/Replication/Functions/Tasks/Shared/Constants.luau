local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Resources = RS:WaitForChild("Resources")
local RS_Modules = RS.Shared:WaitForChild("Modules")

local Utility = require(RS_Modules:WaitForChild("Utility"))
local ParticlesModule = Utility("Particles")

local CamShakePresets = require(RS_Modules.CamShakePresets)

local BoatTween = require(RS_Modules.BoatTween)
local VoxBreaker = require(RS_Modules.VoxBreaker)

local CharacterAssets = Resources:WaitForChild("CharacterAssets")

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map:WaitForChild("Arena"),
	workspace.Map:WaitForChild("Miscellaneous"),
}

local GroundRayParams = RaycastParams.new()
GroundRayParams.FilterType = Enum.RaycastFilterType.Include
GroundRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
}

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.IgnoreWater = true
ExcludeRayParams.FilterDescendantsInstances = { workspace.Debris }
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude

local MapOverlapParams = OverlapParams.new()
MapOverlapParams.RespectCanCollide = true
MapOverlapParams.FilterType = MapRayParams.FilterType
MapOverlapParams.FilterDescendantsInstances = { workspace.Map }

local DefaultFilter = { workspace.Live, workspace.Debris }

local R6Parts = {
	Head = true,
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
}

return {
	Debris = Debris,
	RS = RS,
	TS = TS,
	CollectionService = CollectionService,
	Lighting = Lighting,
	RunService = RunService,
	Players = Players,
	LocalPlayer = LocalPlayer,

	Resources = Resources,
	RS_Modules = RS_Modules,

	Utility = Utility,
	ParticlesModule = ParticlesModule,
	CamShakePresets = CamShakePresets,
	BoatTween = BoatTween,
	VoxBreaker = VoxBreaker,

	CharacterAssets = CharacterAssets,

	MapRayParams = MapRayParams,
	GroundRayParams = GroundRayParams,
	ExcludeRayParams = ExcludeRayParams,
	MapOverlapParams = MapOverlapParams,
	DefaultFilter = DefaultFilter,

	R6Parts = R6Parts,
}
