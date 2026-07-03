local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets
local Debris = Constants.Debris

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if not data then
		return
	end

	if data.moonConn then
		data.moonConn:Disconnect()
		data.moonConn = nil
	end
	if data.moonLaunchConn then
		data.moonLaunchConn:Disconnect()
		data.moonLaunchConn = nil
	end

	local impactPosition = Params.position or (data.moon and data.moon.Position)

	if data.moon and data.moon.Parent then
		data.moon:Destroy()
		data.moon = nil
	end

	State.lunarData[Character] = nil

	if impactPosition then
		local ImpactAsset = CharacterAssets.Eclipse.Lunar.Awaken:FindFirstChild("Impact")
		if ImpactAsset then
			local ImpactClone = ImpactAsset:Clone()
			ImpactClone.Anchored = true
			ImpactClone.CFrame = CFrame.new(impactPosition)
			ImpactClone.Parent = workspace

			for _, child in ImpactClone:GetDescendants() do
				if child:IsA("ParticleEmitter") then
					if child.Name == "Multiple" then
						for i = 1, 5 do
							task.delay((i - 1) * 0.2, function()
								if child and child.Parent then
									child:Emit(child:GetAttribute("EmitCount") or 1)
								end
							end)
						end
					else
						child:Emit(child:GetAttribute("EmitCount") or 1)
					end
				end
			end

			Debris:AddItem(ImpactClone, 5)
		end
	end

	State.lunarNightCount = math.max(0, State.lunarNightCount - 1)
	if State.lunarNightCount <= 0 then
		State:tweenToDay()
	end
end
