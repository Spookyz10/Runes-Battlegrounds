--// Services \\--

local TS = game:GetService('TweenService')



--// Module \\--

local module = { CombatStateDuration = 10 }




--// Module Functions \\--

function module:DamagedLog(Damager: Model, Damaged: Model, Counterable: boolean, Type: string)
	if not Damaged or not Damager then return end
	
	
	local PreviousLog: ObjectValue = Damaged:FindFirstChild('DamagedLog')
	if PreviousLog then
		PreviousLog:Destroy()
	end
	
	
	local ActualLog = script.DamagedLog:Clone()
	ActualLog.Value = Damager
	ActualLog.TimeRemaining.Value = module.CombatStateDuration
	if Counterable == true then
		ActualLog:AddTag('Counterable')
	end
	if Damager:FindFirstChild("Dummy") then
		ActualLog:AddTag("Dummy")
	end
	if Type == 'M1' then
		ActualLog:AddTag('IsM1')
	end
	ActualLog.Parent = Damaged


	local TimeTween = TS:Create(ActualLog.TimeRemaining, TweenInfo.new(module.CombatStateDuration, Enum.EasingStyle.Linear), { Value = 0 })
	TimeTween.Completed:Connect(function()
		if ActualLog then
			ActualLog:Destroy()
		end
	end)

	TimeTween:Play()
	
	Damaged:SetAttribute('WasInCombat', true)
end

function module:DamagerLog(Damager: Model, Damaged: Model)
	if not Damaged or not Damager then return end
	
	
	local PreviousLog: ObjectValue = Damager:FindFirstChild('DamagerLog')
	if PreviousLog then
		PreviousLog:Destroy()
	end
	

	local ActualLog = script.DamagerLog:Clone()
	ActualLog.Parent = Damager
	ActualLog.Value = Damaged
	ActualLog.TimeRemaining.Value = module.CombatStateDuration

	if Damaged:FindFirstChild("Dummy") then
		ActualLog:AddTag("Dummy")
	end


	local TimeTween = TS:Create(ActualLog.TimeRemaining, TweenInfo.new(module.CombatStateDuration, Enum.EasingStyle.Linear), { Value = 0 })
	TimeTween.Completed:Connect(function()
		if ActualLog then
			ActualLog:Destroy()
		end
	end)

	TimeTween:Play()
end

return module
