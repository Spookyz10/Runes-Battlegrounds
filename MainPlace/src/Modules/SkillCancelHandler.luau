local SkillCancelHandler = {}

local CombatEvents = require(script.Parent.CombatEvents)
local CharacterLifetime = require(script.Parent.CharacterLifetime)

local Active = {} -- [Character] = cancelFn
local Lifetimes = {}

function SkillCancelHandler:Register(Character, cancelFn)
	if Lifetimes[Character] then
		Lifetimes[Character]()
	end
	Active[Character] = cancelFn
	Lifetimes[Character] = CharacterLifetime.Watch(Character, function()
		if Active[Character] == cancelFn then
			self:Unregister(Character, cancelFn)
			cancelFn()
		end
	end)
end

function SkillCancelHandler:Unregister(Character, cancelFn)
	if Active[Character] == cancelFn then
		Active[Character] = nil
		if Lifetimes[Character] then
			Lifetimes[Character]()
			Lifetimes[Character] = nil
		end
	end
end

CombatEvents.DamageDealt:Connect(function(_, Damaged, _, _)
	local fn = Active[Damaged]
	if fn then
		SkillCancelHandler:Unregister(Damaged, fn)
		task.spawn(fn)
	end
end)

return SkillCancelHandler
