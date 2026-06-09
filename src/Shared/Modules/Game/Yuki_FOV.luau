local TS = game:GetService("TweenService")
local RNS = game:GetService("RunService")

local TweenModule = {
    Immune = false
}

local Usable = nil

local Camera = workspace.CurrentCamera

local function Cancel()
    if Usable ~= nil then
        Usable:Cancel()
        Usable = nil
    end
end

TweenModule.Tween = function(v6, v7, v8)
    if TweenModule.Immune then
        return
    else
        if v8 and Usable ~= nil then
            Usable:Cancel()
            Usable = nil
		end
		
        Usable = TS:Create(Camera, TweenInfo.new(table.unpack(v7)), {
            FieldOfView = v6 or 70
        })
		Usable:Play()
		
        Usable.Completed:Once(function()
            if Usable then
                Usable:Destroy()
                Usable = nil
            end
        end)
        return
    end
end

TweenModule.Set = function(v9)
    if TweenModule.Immune then
        return
    else
        if Usable ~= nil then
            Usable:Cancel()
            Usable = nil
		end
		
        Camera.FieldOfView = v9
        return
    end
end

TweenModule.Reset = function()
    if TweenModule.Immune then
        return
    else
        if Usable ~= nil then
            Usable:Cancel()
            Usable = nil
		end
		
        Camera.FieldOfView = 70
        return
    end
end

TweenModule.AnimateWithMoonFile = function(v10, v11, v12)
    TweenModule.Immune = true
    v12 = v12 or 0
    local v13 = tick()
    local v14 = nil
	local v15 = false
	
	local function Clean()
        if v15 then
            return
        else
            v15 = true
            v14:Disconnect()
            TweenModule.Immune = false
            if not v11 then
                TweenModule.Tween(70, {
                    0.5, 
                    Enum.EasingStyle.Quart, 
                    Enum.EasingDirection.Out
                })
            end
            return
        end
	end
	
	local v17 = #v10:GetChildren()
	
    v14 = RNS.PreRender:Connect(function()
        local v18 = math.ceil((tick() - v13) / 0.016666666666666666)
        if v17 <= v18 then
			return Clean()
        else
            Camera.FieldOfView = v10:FindFirstChild((("%*"):format(v18))).Value + v12
            return
        end
	end)
	
	return Clean
end

return TweenModule