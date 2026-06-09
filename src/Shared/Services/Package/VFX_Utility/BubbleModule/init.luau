local v_u_1 = game:GetService("TweenService")
local v_u_2 = workspace.Thrown

return {
	["CreateBubble"] = function(p3, p4, p5, p6, p7)
		local v8 = script.Mesh:Clone()
		v8.CFrame = p3
		v8.Anchored = true
		v8.CanCollide = false
		v8.Massless = true
		v8.Parent = v_u_2
		v8.Material = Enum.Material.Glass
		v8.Size = p4
		v8.Transparency = p5
		local v9 = Instance.new("Highlight")
		v9.Enabled = false
		v9.Parent = v8
		game.Debris:addItem(v8, p7)
		v_u_1:Create(v8, TweenInfo.new(p7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {
			["Transparency"] = 1,
			["Size"] = p6
		}):Play()
	end
}
