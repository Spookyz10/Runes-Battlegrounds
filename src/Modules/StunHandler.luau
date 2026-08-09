local module = {}
module.Cache = {}
module.Active = {}

local StunsTags = {
	"CantPunch",
	"CantDash",
	"CantSideDash",
	"CantBlock",
	"CantThrowable",
}

local function TriggerTags(Character, State)
	if not Character then
		return
	end

	for _, Tag in ipairs(StunsTags) do
		if State then
			Character:AddTag(Tag)
		else
			Character:RemoveTag(Tag)
		end
	end
end

local function getCharacterState(Character)
	if not module.Active[Character] then
		module.Active[Character] = {
			Sources = {},
		}
	end

	return module.Active[Character]
end

local function ensureContainerFolder(Character, State)
	if State.Folder and State.Folder.Parent == Character then
		return State.Folder
	end

	local Container = Character:FindFirstChild("Stunned")
	if not Container then
		Container = Instance.new("Folder")
		Container.Name = "Stunned"
		Container.Parent = Character
		Container.Destroying:Once(function()
			if module.Active[Character] and module.Active[Character].Folder == Container then
				module.Active[Character].Folder = nil
			end
			if Character and Character.Parent then
				Character:SetAttribute("Stunned", false)
				Character:SetAttribute("Stunned", nil)
				Character:RemoveTag("Stunned")
				TriggerTags(Character, false)
			end
		end)
	end

	State.Folder = Container
	return Container
end

local function updateContainerAttributes(Container, WalkSpeed, JumpPower, Escapable)
	if not Container then
		return
	end

	local CurrentWalkSpeed = Container:GetAttribute("WalkSpeed")
	local CurrentJumpPower = Container:GetAttribute("JumpPower")
	local CurrentEscapable = Container:GetAttribute("Escapable")

	if CurrentWalkSpeed ~= nil then
		Container:SetAttribute("WalkSpeed", math.min(CurrentWalkSpeed, WalkSpeed))
	else
		Container:SetAttribute("WalkSpeed", WalkSpeed)
	end

	if CurrentJumpPower ~= nil then
		Container:SetAttribute("JumpPower", math.min(CurrentJumpPower, JumpPower))
	else
		Container:SetAttribute("JumpPower", JumpPower)
	end

	if CurrentEscapable ~= nil then
		Container:SetAttribute("Escapable", CurrentEscapable and Escapable ~= false)
	else
		Container:SetAttribute("Escapable", Escapable ~= false)
	end
end

local function recomputeContainerAttributes(State)
	local Container = State.Folder
	if not Container or not Container.Parent then
		return
	end

	local WalkSpeed, JumpPower, Escapable = nil, nil, nil

	for _, SourceFolder in Container:GetChildren() do
		local sw = SourceFolder:GetAttribute("WalkSpeed")
		local jp = SourceFolder:GetAttribute("JumpPower")
		local esc = SourceFolder:GetAttribute("Escapable")

		if sw ~= nil then
			WalkSpeed = WalkSpeed and math.min(WalkSpeed, sw) or sw
		end
		if jp ~= nil then
			JumpPower = JumpPower and math.min(JumpPower, jp) or jp
		end
		if esc ~= nil then
			if Escapable == nil then
				Escapable = esc
			else
				Escapable = Escapable and esc
			end
		end
	end

	Container:SetAttribute("WalkSpeed", WalkSpeed)
	Container:SetAttribute("JumpPower", JumpPower)
	Container:SetAttribute("Escapable", Escapable ~= false)
end

local function removeSourceEntry(Character, SourceKey)
	local State = module.Active[Character]
	if not State then
		return false
	end

	local SourceEntry = State.Sources[SourceKey]
	if not SourceEntry then
		return false
	end

	if SourceEntry.Handle then
		pcall(function()
			task.cancel(SourceEntry.Handle)
		end)
	end
	SourceEntry.Handle = nil

	if SourceEntry.Folder and SourceEntry.Folder.Parent then
		SourceEntry.Folder:Destroy()
	end

	State.Sources[SourceKey] = nil

	if next(State.Sources) == nil then
		if State.Folder and State.Folder.Parent == Character then
			State.Folder:Destroy()
		else
			if Character and Character.Parent then
				Character:SetAttribute("Stunned", false)
				Character:SetAttribute("Stunned", nil)
				Character:RemoveTag("Stunned")
			end
			TriggerTags(Character, false)
		end

		module.Active[Character] = nil
		module.Cache[Character] = nil
	else
		recomputeContainerAttributes(State)
	end

	return true
end

local function getSourceKey(Source)
	if Source ~= nil then
		return Source
	end

	return ("stun_" .. tostring(math.random(1, 999999)) .. "_" .. tostring(os.clock()))
end

function module:Stun(
	Character,
	Duration,
	IgnoreImmunity,
	WalkSpeed,
	JumpPower,
	DestroyImmunity,
	IgnoreThrowable,
	Escapable,
	Source
)
	Duration = Duration or -1
	WalkSpeed = WalkSpeed or 0
	JumpPower = JumpPower or 0

	if not Character or not Character.Parent then
		return
	end

	if not Character:FindFirstChild("Humanoid") then
		return
	end

	local State = getCharacterState(Character)
	local Container = ensureContainerFolder(Character, State)
	local SourceKey = getSourceKey(Source)

	Character:AddTag("Stunned")
	Character:SetAttribute("Stunned", true)
	updateContainerAttributes(Container, WalkSpeed, JumpPower, Escapable)
	TriggerTags(Character, true)

	local SourceFolder = Instance.new("Folder")
	SourceFolder.Name = tostring(SourceKey)
	SourceFolder.Parent = Container
	SourceFolder:SetAttribute("WalkSpeed", WalkSpeed)
	SourceFolder:SetAttribute("JumpPower", JumpPower)
	SourceFolder:SetAttribute("Escapable", Escapable ~= false)

	if DestroyImmunity then
		SourceFolder:AddTag("DestroyImmunity")
	end

	State.Sources[SourceKey] = {
		Folder = SourceFolder,
	}

	if Duration > 0 then
		local Handle = task.delay(Duration, function()
			module:Unstun(Character, SourceKey)
		end)
		State.Sources[SourceKey].Handle = Handle
		module.Cache[Character] = module.Cache[Character] or {}
		module.Cache[Character][SourceKey] = Handle
	else
		local Thread = coroutine.create(function()
			module:Unstun(Character, SourceKey)
		end)
		State.Sources[SourceKey].Handle = Thread
		module.Cache[Character] = module.Cache[Character] or {}
		module.Cache[Character][SourceKey] = Thread
	end

	return SourceFolder
end

function module:RemoveAllStuns(Character, IgnoreImmunity)
	local State = module.Active[Character]
	if not State then
		return
	end

	local SourceKeys = {}
	for SourceKey in pairs(State.Sources) do
		table.insert(SourceKeys, SourceKey)
	end

	for _, SourceKey in ipairs(SourceKeys) do
		local SourceEntry = State.Sources[SourceKey]
		if SourceEntry and (IgnoreImmunity == true or not SourceEntry.Folder:HasTag("DestroyImmunity")) then
			module:Unstun(Character, SourceKey)
		end
	end
end

function module:Unstun(Character, StunObject)
	if
		not Character
		or not Character:FindFirstChild("Humanoid")
		or Character.Humanoid.Health <= 0
		or Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead
	then
		return
	end

	if not StunObject then
		local State = module.Active[Character]
		if not State then
			return
		end

		local SourceKeys = {}
		for SourceKey in pairs(State.Sources) do
			table.insert(SourceKeys, SourceKey)
		end

		for _, SourceKey in ipairs(SourceKeys) do
			removeSourceEntry(Character, SourceKey)
		end
		return
	end

	if typeof(StunObject) == "Instance" and StunObject:IsA("Folder") then
		local State = module.Active[Character]
		if not State then
			return
		end

		for SourceKey, SourceEntry in pairs(State.Sources) do
			if SourceEntry and SourceEntry.Folder == StunObject then
				removeSourceEntry(Character, SourceKey)
				return
			end
		end
		return
	end

	removeSourceEntry(Character, StunObject)
end

function module:IsStunned(Character)
	return Character:FindFirstChild("Stunned") or Character:HasTag("Stunned") or Character:GetAttribute("Stunned")
end

function module:CanEscape(Character)
	local Stunned = Character:FindFirstChild("Stunned")
	if not Stunned then
		return false
	end

	return Stunned:GetAttribute("Escapable") ~= false
end

function module:EscapeStun(Character)
	if not module:CanEscape(Character) then
		return false
	end

	module:Unstun(Character)
	return true
end

return module
