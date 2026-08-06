local StatusEffectHandler = {}

local Definitions = {}
local Active = {}

local DEFAULT_SOURCE = "_default"

local function getSourceKey(Source)
	if Source == nil then
		return DEFAULT_SOURCE
	end
	return Source
end

function StatusEffectHandler:RegisterEffect(EffectId, Definition)
	Definitions[EffectId] = Definition
end

local function getCharacterEffects(Character)
	if not Active[Character] then
		Active[Character] = {}
		Character.Destroying:Connect(function()
			StatusEffectHandler:ClearAll(Character)
			Active[Character] = nil
		end)
	end
	return Active[Character]
end

function StatusEffectHandler:Apply(Character, EffectId, Params)
	if not Character or not Character.Parent then
		return
	end

	local Definition = Definitions[EffectId]
	if not Definition then
		warn("[StatusEffectHandler] Unknown effect: " .. tostring(EffectId))
		return
	end

	Params = Params or {}

	local Effects = getCharacterEffects(Character)
	if not Effects[EffectId] then
		Effects[EffectId] = {}
	end

	local Instances = Effects[EffectId]
	local SourceKey = getSourceKey(Params.Source)
	local Instance = Instances[SourceKey]

	if Instance then
		Instance.Stacks = math.min((Instance.Stacks or 1) + (Params.Stacks or 1), Definition.MaxStacks or math.huge)

		if Instance.ExpireHandle then
			pcall(task.cancel, Instance.ExpireHandle)
			Instance.ExpireHandle = nil
		end

		if Definition.OnStack then
			Definition.OnStack(Character, Instance.Data, Instance.Stacks, Params)
		end
	else
		Instance = {
			Stacks = Params.Stacks or 1,
			Data = Params.Data or {},
			Source = Params.Source,
			ExpireHandle = nil,
			TickHandle = nil,
		}
		Instances[SourceKey] = Instance

		if Definition.OnApply then
			Definition.OnApply(Character, Instance.Data, Instance.Stacks, Params)
		end

		if Definition.TickInterval then
			Instance.TickHandle = task.spawn(function()
				while Instances[SourceKey] == Instance do
					task.wait(Definition.TickInterval)
					if Instances[SourceKey] ~= Instance or not Character.Parent then
						break
					end
					if Definition.OnTick then
						Definition.OnTick(Character, Instance.Data, Instance.Stacks)
					end
				end
			end)
		end
	end

	local Duration = Params.Duration or Definition.Duration
	if Duration and Duration > 0 then
		Instance.ExpireHandle = task.delay(Duration, function()
			StatusEffectHandler:Remove(Character, EffectId, Params.Source)
		end)
	end

	return Instance
end

function StatusEffectHandler:Remove(Character, EffectId, Source)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	if not Instances then
		return
	end

	local SourceKey = getSourceKey(Source)
	local Instance = Instances[SourceKey]
	if not Instance then
		return
	end

	Instances[SourceKey] = nil

	if Instance.ExpireHandle then
		pcall(task.cancel, Instance.ExpireHandle)
	end
	if Instance.TickHandle then
		pcall(task.cancel, Instance.TickHandle)
	end

	local Definition = Definitions[EffectId]
	if Definition and Definition.OnExpire then
		Definition.OnExpire(Character, Instance.Data, Instance.Stacks, Source)
	end

	if next(Instances) == nil then
		Effects[EffectId] = nil
	end
end

function StatusEffectHandler:ConsumeStack(Character, EffectId, Amount, Source)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	local Instance = Instances and Instances[getSourceKey(Source)]
	if not Instance then
		return 0
	end

	Amount = Amount or 1
	Instance.Stacks -= Amount

	if Instance.Stacks <= 0 then
		StatusEffectHandler:Remove(Character, EffectId, Source)
		return 0
	end

	local Definition = Definitions[EffectId]
	if Definition and Definition.OnStack then
		Definition.OnStack(Character, Instance.Data, Instance.Stacks, {})
	end

	return Instance.Stacks
end

function StatusEffectHandler:Has(Character, EffectId, Source)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	if not Instances then
		return false
	end

	if Source == nil then
		return next(Instances) ~= nil
	end

	return Instances[getSourceKey(Source)] ~= nil
end

function StatusEffectHandler:GetStacks(Character, EffectId, Source)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	if not Instances then
		return 0
	end

	local Instance = Instances[getSourceKey(Source)]
	return Instance and Instance.Stacks or 0
end

function StatusEffectHandler:GetData(Character, EffectId, Source)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	local Instance = Instances and Instances[getSourceKey(Source)]
	return Instance and Instance.Data
end

function StatusEffectHandler:GetSources(Character, EffectId)
	local Sources = {}

	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	if not Instances then
		return Sources
	end

	for _, Instance in Instances do
		table.insert(Sources, Instance.Source)
	end

	return Sources
end

function StatusEffectHandler:CountSources(Character, EffectId)
	local Effects = Active[Character]
	local Instances = Effects and Effects[EffectId]
	if not Instances then
		return 0
	end

	local count = 0
	for _ in Instances do
		count += 1
	end
	return count
end

function StatusEffectHandler:ClearAll(Character)
	local Effects = Active[Character]
	if not Effects then
		return
	end

	for EffectId, Instances in Effects do
		for _, Instance in Instances do
			StatusEffectHandler:Remove(Character, EffectId, Instance.Source)
		end
	end
end

return StatusEffectHandler
