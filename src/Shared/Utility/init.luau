




local module = {}


module.Services = {
	Debris = game:GetService('Debris'),
	ReplicatedStorage = game:GetService('ReplicatedStorage'),
	RunService = game:GetService('RunService'),
	Tween = game:GetService('TweenService'),
	Players = game:GetService('Players'),
	Lighting = game:GetService('Lighting'),
	Sound = game:GetService('SoundService'),
	Collection = game:GetService('CollectionService'),
	UserInputService = game:GetService('UserInputService')
}
if module.Services.RunService:IsClient() then
	module.Idk = {
		Players = module.Services.Players.LocalPlayer,
		PlayerGui = module.Services.Players.LocalPlayer.PlayerGui
	}
end


module.Modules = {
	soundPlaying = require(script.soundplaying),
	RayCast = require(script.Raycast),
	animPlaying = require(script.animPlaying),
	Trove = require(script.Trove),
	CameraShaker = require(script.CameraShaker),
	GuiShakerModule = require(script.GuiShakerModule)
}





return module
