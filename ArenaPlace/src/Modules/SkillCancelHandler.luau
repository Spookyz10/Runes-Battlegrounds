local SkillCancelHandler = {}

local CombatEvents = require(script.Parent.CombatEvents)

local Active = {} -- [Character] = cancelFn

function SkillCancelHandler:Register(Character, cancelFn)
	Active[Character] = cancelFn
end

function SkillCancelHandler:Unregister(Character, cancelFn)
	if Active[Character] == cancelFn then
		Active[Character] = nil
	end
end

CombatEvents.DamageDealt:Connect(function(_, Damaged, _, _)
	local fn = Active[Damaged]
	if fn then
		Active[Damaged] = nil
		task.spawn(fn)
	end
end)

return SkillCancelHandler
