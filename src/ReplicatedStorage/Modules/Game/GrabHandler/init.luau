local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local v3 = setmetatable({}, {
    __mode = "k"
})

local v4 = {}
local v5 = require(RS.Modules.Game.Utility)
local v6 = require(script.Presets)

v4.Set = function(v7, v8, v9, v10)
    if v7 == nil or v7.Parent == nil or v8 == nil or v8.Parent == nil then
        return
    elseif v7 == v8 then
        return
    else
        local v11 = v10 and v6[v10]
        local v12 = v11 and v11.RenderPriority or v5.CharacterRenderPriority
		local v13 = false
		
        if v11 then
            v13 = v11.NoY == true
		end
		
        v3[v7] = {
            Offset = v9 or CFrame.identity, 
            BoundTo = v8
		}
		
        local l_Y_0 = v8.CFrame.Y
        if v13 then
            local v15 = workspace:Raycast(v8.Position, Vector3.new(-0, -20, -0, -0), v5.VisualParams)
            if v15 then
                l_Y_0 = v15.Position.Y
            end
		end
		
        RNS:BindToRenderStep(tostring(v3[v7]), v12, function()
            if v8 == nil or v8.Parent == nil then
                return v4.Remove(v7)
            else
                local v16 = v3[v7]
                if v16 and v16.BoundTo and v16.Offset then
                    local l_Offset_0 = v16.Offset
                    local l_CFrame_0 = v16.BoundTo.CFrame
                    if v13 then
                        v7.CFrame = (l_CFrame_0.Rotation + l_CFrame_0.Position * Vector3.new(1, 0, 1, 0) + Vector3.new(0, 1, 0, 0) * (l_Y_0 - 2)) * l_Offset_0
                        return
                    else
                        v7.CFrame = l_CFrame_0 * l_Offset_0
                    end
                end
                return
            end
        end)
        return
    end
end

v4.SetBound = function(v19, v20)
    if v19 == nil or v3[v19] == nil then
        return
    else
        v3[v19].BoundTo = v20
        return
    end
end

v4.SetOffset = function(v21, v22)
    if v21 == nil or v3[v21] == nil then
        return
    else
        v3[v21].Offset = v22
        return
    end
end

v4.Remove = function(v23)
    if v23 == nil or v3[v23] == nil then
        return
    else
        RNS:UnbindFromRenderStep((tostring(v3[v23])))
        table.clear(v3[v23])
        v3[v23] = nil
        return
    end
end

return v4