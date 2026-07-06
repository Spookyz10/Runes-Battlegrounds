local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Resources = game:GetService("ReplicatedStorage"):WaitForChild("Resources")
return function(Params)
	local Ring = Resources.Misc.Ring:Clone()
	Ring.Parent = workspace.Thrown
	Ring.CFrame = Params.CF

	for Prop, Value in Params.FirstProps do
		if Ring[Prop] then
			Ring[Prop] = Value
		end
	end

	local EasinStyle = Enum.EasingStyle[Params.TN_Info.Style]
	local EasinDirection = Enum.EasingDirection[Params.TN_Info.Direction]

	TweenService:Create(Ring, TweenInfo.new(Params.TN_Info.Time, EasinStyle, EasinDirection), Params.FinalProps):Play()
	Debris:AddItem(Ring, Params.LF or Params.TN_Info.Time)
end
