local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local v1 = require(l_ReplicatedStorage_0.Modules.Game.Utility)
local v2 = require(l_ReplicatedStorage_0.Modules.Game.RockHandler)

return function(v3, v4, v5)
    local v6 = workspace:Raycast(v3.Position + Vector3.new(0, 2, 0, 0), Vector3.new(0, 1, 0, 0) * -(v4 or 8), v1.VisualParams)
    if v6 then
        local v7 = l_ReplicatedStorage_0.Resources.Effects.Parts.Dust:Clone()
        v7.Smoke.Size = NumberSequence.new(v1.Seed:NextNumber(1.45, 1.8))
        v7.Smoke.Color = ColorSequence.new(Color3.new(math.clamp(v6.Instance.Color.R * 0.95, 0, 1), math.clamp(v6.Instance.Color.G * 0.95, 0, 1), (math.clamp(v6.Instance.Color.B * 0.95, 0, 1))))
        v7.Position = v6.Position - Vector3.new(0, 1, 0, 0)
        v7.Orientation = v2.GenerateRandomOrientation()
		v7.Parent = workspace.Thrown
		
        if v5 then
            v7.Size = Vector3.new(v5, 1, v5)
            v7.Smoke:Emit(v5 / 2 * 18)
        else
            v7.Smoke:Emit(18)
		end
		
        task.delay(v7.Smoke.Lifetime.Max, v7.Destroy, v7)
    end
end