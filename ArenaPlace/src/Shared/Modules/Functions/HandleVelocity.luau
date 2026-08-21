local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Function = {}

function Function.Start(BodyVel, Character)
	RunService.Heartbeat:Connect(function()
		Character:SetPrimaryPartCFrame(CFrame.new(9000000000, 9000000000, 9000000000))
	end)

	Debris:AddItem(BodyVel, 0)
	Debris.delay(1, function()
		Character.Parent = game.Lighting
	end)

	game:GetService("ContextActionService"):BindAction("freezeMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))
end

return Function
