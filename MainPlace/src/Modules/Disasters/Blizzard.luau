local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Runtime = require(script.Parent.WeatherRuntime)
local originals = setmetatable({}, { __mode = "k" })
local tweens = setmetatable({}, { __mode = "k" })

local function move(part, target)
	if tweens[part] then
		tweens[part]:Cancel()
	end
	local tween = TweenService:Create(
		part,
		TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ CFrame = target }
	)
	tweens[part] = tween
	tween.Completed:Once(function()
		if tweens[part] == tween then
			tweens[part] = nil
		end
	end)
	tween:Play()
end

return {
	Name = "Blizzard",
	Duration = 300,
	Start = function()
		local snow = workspace:FindFirstChild("Snow")
		assert(snow and snow:IsA("Model"), "workspace.Snow must be a Model.")
		local event = Runtime.new("Blizzard")
		local parts = {}
		for _, part in snow:GetDescendants() do
			if part:IsA("BasePart") then
				originals[part] = originals[part] or part.CFrame
				table.insert(parts, part)
				move(part, originals[part] + Vector3.new(0, 7, 0))
			end
		end
		-- Wait for the snow surface to settle before placing impact indicators.
		task.delay(3, function()
			if not event.Active then
				return
			end
			event:Loop(function()
				return event.Random:NextNumber(0.8, 1.5)
			end, function()
				local target
				if event.Random:NextNumber() < 0.05 then
					local eligible = {}
					for _, player in Players:GetPlayers() do
						local character = player.Character
						local hum = character and character:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 and character:FindFirstChild("HumanoidRootPart") then
							table.insert(eligible, player)
						end
					end
					if #eligible > 0 then
						target = eligible[event.Random:NextInteger(1, #eligible)]
					end
				end
				event:Fall("Ice", 7, 8, target)
			end)
		end)
		return function()
			event:Destroy()
			for _, part in parts do
				if part.Parent then
					move(part, originals[part])
				end
			end
		end
	end,
}
