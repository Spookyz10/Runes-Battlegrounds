local Master = {}
local TweenService = game:GetService("TweenService")

function Master.BeamAppearMaster(Beam, dely, t, EasingStyle, EasingDirec)
	local Width125 = Beam.Width1
	local Width0 = Beam.Width0
	Beam.Width0 = 0
	Beam.Width1 = 0
	local Twinfo = TweenInfo.new(t, EasingStyle, EasingDirec)
	local Twinfo2 = TweenInfo.new(0.25, EasingStyle, EasingDirec)
	local AppearTween0 = TweenService:Create(Beam, Twinfo, { Width0 = Width0})
	local AppearTween1 = TweenService:Create(Beam, Twinfo, { Width1 = Width125})
	AppearTween0:Play()
	task.delay(dely, function()
		Beam.Enabled = true
		AppearTween1:Play()
	end)

end
function Master.BeamDisappear(Beam, dely, t, EasingStyle, EasingDirec)
	local Twinfo = TweenInfo.new(t, EasingStyle, EasingDirec)
	local Twinfo2 = TweenInfo.new(0.15, EasingStyle, EasingDirec)
	local AppearTween0 = TweenService:Create(Beam, Twinfo, { Width0 = 0})
	local AppearTween1 = TweenService:Create(Beam, Twinfo, { Width1 = 0})
	AppearTween0:Play()
	task.delay(dely, function()
		AppearTween1:Play()
	end)

end
return Master
