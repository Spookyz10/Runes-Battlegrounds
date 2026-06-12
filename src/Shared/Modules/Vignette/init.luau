local l_TweenService_0 = game:GetService("TweenService");
local l_Players_0 = game:GetService("Players");
local _ = require(script.Presets);
local l_LocalPlayer_0 = l_Players_0.LocalPlayer;
local l_FXScreen_0 = l_LocalPlayer_0.PlayerGui:WaitForChild("FXScreen");
return function(v5, v6, v7, v8) --[[ Line: 10 ]]
    -- upvalues: l_LocalPlayer_0 (copy), l_FXScreen_0 (copy), l_TweenService_0 (copy)
    if l_LocalPlayer_0:GetAttribute("Epileptic_Mode") then
        return;
    else
        local v9 = v8 and l_FXScreen_0.SmallPulse or l_FXScreen_0.Pulse;
        v9.ImageColor3 = v5;
        v9.ImageTransparency = v6;
        l_TweenService_0:Create(v9, TweenInfo.new(v7 or 1), {
            ImageTransparency = 1
        }):Play();
        return;
    end;
end;